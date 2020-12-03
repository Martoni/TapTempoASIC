-- The TapTempo Project
-- Created on    : 21/11/2020
-- Author        : Fabien Marteau <mail@fabienm.eu>
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.taptempo_pkg.all;

Entity per2bpm is
    port(
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- inputs
        btn_per_i : in std_logic_vector(BTN_PER_SIZE-1 downto 0);
        btn_per_valid : in std_logic;
        -- outputs
        bpm_o : out std_logic_vector(BPM_SIZE-1 downto 0);
        bpm_valid : out std_logic
    );
end entity;

Architecture per2bpm_1 of per2bpm is
    constant DIVIDENTWIDTH : natural := log2ceil(1 + (MIN_US/TP_CYCLE)*1000);
    constant REGWIDTH : natural := BTN_PER_SIZE + DIVIDENTWIDTH;

    signal divisor : std_logic_vector(REGWIDTH-1 downto 0);
    signal remainder : std_logic_vector(REGWIDTH-1 downto 0);

    signal quotient : std_logic_vector(REGWIDTH-1 downto 0);
    signal ctrlcnt : natural range 0 to DIVIDENTWIDTH + 1;

    type t_state is (s_init, s_compute, s_result);
    signal state_reg : t_state;

begin

    div_process : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            divisor <= (others => '0');
            remainder <= (others => '0');
            quotient <= (others => '0');
            ctrlcnt <= DIVIDENTWIDTH;
            state_reg <= s_init;
        elsif rising_edge(clk_i) then
            case state_reg is 
                when s_init =>
                    if(to_integer(unsigned(btn_per_i)) < BTN_PER_MIN) then
                        divisor <= std_logic_vector(
                            to_unsigned(BTN_PER_MIN, BTN_PER_SIZE)) & ZEROS(DIVIDENTWIDTH-1 downto 0);
                    else
                        divisor <= btn_per_i & ZEROS(DIVIDENTWIDTH-1 downto 0);
                    end if;
                    remainder <= std_logic_vector(to_unsigned((MIN_US/TP_CYCLE)*1000, REGWIDTH));
                    quotient <= (others => '0');
                    ctrlcnt <= DIVIDENTWIDTH;
                    if (btn_per_valid = '1') then
                        state_reg <= s_compute;
                    end if;
                when s_compute =>
                    if(unsigned(divisor) <= unsigned(remainder)) then
                        remainder <= std_logic_vector(unsigned(remainder) - unsigned(divisor));
                        quotient <= quotient(REGWIDTH-2 downto 0) & "1";
                    else
                        quotient <= quotient(REGWIDTH-2 downto 0) & "0";
                    end if;
                    divisor <= "0" & divisor(REGWIDTH-1 downto 1);

                    if (ctrlcnt = 0) then
                        state_reg <= s_result;
                    else
                        ctrlcnt <= ctrlcnt - 1;
                        state_reg <= s_compute;
                    end if;
                when s_result =>
                    state_reg <= s_init;
                when others =>
                    state_reg <= s_init;

            end case;
        end if;
    end process div_process;

bpm_o <= quotient(BPM_SIZE-1 downto 0);
bpm_valid <= '1' when state_reg = s_result else '0';
end Architecture per2bpm_1;
