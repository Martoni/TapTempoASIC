-- The TapTempo Project
-- Created on    : 20/11/2020
-- Author        : Fabien Marteau <mail@fabienm.eu>
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.taptempo_pkg.all;

Entity debounce is
    generic(
        PULSE_PER_NS : natural := 5120;
        DEBOUNCE_PER_NS: natural := 20_971_520);
    port (
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- inputs
        tp_i : in std_logic;
        btn_i: in std_logic;
        -- outputs
        btn_o : out std_logic
    );
end entity;

Architecture debounce_1 of debounce is

    constant MAX_COUNT : natural := ((DEBOUNCE_PER_NS/TP_CYCLE)-1);
    constant MAX_COUNT_SIZE : natural := log2ceil(MAX_COUNT);
    signal counter : natural range 0 to MAX_COUNT;

    type t_state is (s_wait_low, s_wait_high, s_cnt_high, s_cnt_low);
    signal state_reg : t_state;
begin

counter_p : process(clk_i, rst_i)
begin
    if rst_i = '1' then
        counter <= 0;
    elsif rising_edge(clk_i) then
        if (state_reg = s_cnt_high) or (state_reg = s_cnt_low) then
            counter <= counter + 1;
        else
            counter <= 0;
        end if;
    end if;
end process counter_p;

main_sm : process(clk_i, rst_i)
begin
    if rst_i = '1' then
        state_reg <= s_wait_low;
    elsif rising_edge(clk_i) then
        case state_reg is
            when s_wait_low => 
                if(btn_i = '1') then
                    state_reg <= s_cnt_high;
                end if;
            when s_wait_high =>
                if(btn_i = '0') then
                    state_reg <= s_cnt_low;
                end if;
            when s_cnt_high =>
                if(counter >= MAX_COUNT-1) then
                    state_reg <= s_wait_high;
                end if;
            when s_cnt_low =>
                if(counter >= MAX_COUNT-1) then
                    state_reg <= s_wait_low;
                end if;
        end case;
    end if;
end process main_sm;

btn_o <= '1' when ((state_reg = s_cnt_high) or (state_reg = s_wait_high)) else '0';

end architecture debounce_1;

