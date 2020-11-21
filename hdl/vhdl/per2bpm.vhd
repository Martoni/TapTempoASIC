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
        btn_per_i : std_logic_vector(BTN_PER_SIZE-1 downto 0);
        btn_per_valid : std_logic;
        -- outputs
        bpm_o : std_logic_vector(BPM_SIZE-1 downto 0);
        bpm_valid : std_logic
    );
end entity;

Architecture per2bpm_1 of per2bpm is
    constant DIVIDENTWITH : natural := log2ceil(1 + (MIN_US/TP_CYCLE)*1000);
    constant REGWIDTH : natural := BTN_PER_SIZE + DIVIDENTWITH;

    signal divisor : std_logic_vector(REGWIDTH-1 downto 0);
    signal remainder : std_logic_vector(REGWIDTH-1 downto 0);
    signal quotient : std_logic_vector(REGWIDTH-1 downto 0);
    signal ctrlcnt : std_logic_vector(log2ceil(REGWIDTH+1) downto 0);

    type t_state is (s_init, s_compute, s_result);
    signal state_reg : t_state;

begin
   
    div_sm : process(clk_i, rst_i)
    begin
        case state_reg is
            when s_init => 
                if (btn_per_valid = '1') then
                    state_reg <= s_compute;
                end if;
            when s_compute =>
                if (ctrlcnt = 0) then
                    state_reg <= s_result;
                end if;
            when s_result =>
                state_reg <= s_init;
        end case;
    end process div_sm;

    div_process : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            divisor <= 0;
            remainder <= 0;
            quotient <= 0;
            ctrlcnt <= REGWIDTH;
        elsif rising_edge(clk_i) then
            if(state_reg = s_init) then
                if(to_integer(unsigned(btn_per_i)) < BTN_PER_MIN) then
                    divisor <= 
            elsif

        end if;
    end process div_process;

end Architecture per2bpm_1;
