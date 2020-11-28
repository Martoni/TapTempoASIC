-- The TapTempo Project
-- Created on    : 28/11/2020
-- Author        : Fabien Marteau <mail@fabienm.eu>
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.taptempo_pkg.all;

Entity percount is
    port(
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- time plulse
        tp_i : in std_logic;
        -- input button
        btn_i : in std_logic;
        -- output period
        btn_per_o : out std_logic_vector(BTN_PER_SIZE-1 downto 0);
        btn_per_valid : out std_logic);
end entity;

architecture percount_1 of percount is
    signal counter : natural range 0 to BTN_PER_MAX;
    signal counter_valid : std_logic;
    
    signal btn_old : std_logic;
    signal btn_fall : std_logic;
begin

    -- continus assignation
    btn_per_valid <= counter_valid;
    btn_per_o <= std_logic_vector(to_unsigned(counter, BTN_PER_SIZE));
    btn_fall <= btn_old and (not btn_i);
    
    btn_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            btn_old <= '0';
        elsif rising_edge(clk_i) then
            btn_old <= btn_i;
        end if;
    end process btn_p;

    counter_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            counter <= 0;
        elsif rising_edge(clk_i) then
            if btn_fall = '1' then
                counter_valid <= '1';
            elsif counter_valid = '1' then
                counter <= 0;
                counter_valid <= '0';
            elsif tp_i = '1' and (counter < BTN_PER_MAX) then
                counter <= counter + 1;
            end if;
        end if;
    end process counter_p;

end architecture percount_1;
