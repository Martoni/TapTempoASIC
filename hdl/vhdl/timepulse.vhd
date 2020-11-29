-- The TapTempo Project
-- Created on    : 28/11/2020
-- Author        : Fabien Marteau <mail@fabienm.eu>
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.taptempo_pkg.all;

Entity timepulse is
    port(
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- timepulse output
        tp_o : out std_logic
    );
end entity timepulse;

architecture timepulse_1 of timepulse is
    signal counter : natural range 0 to MAX_COUNT + 1;
begin

    tp_o <= '1' when (counter = 0) else '0';

    counter_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            counter <= 0;
        elsif rising_edge(clk_i) then
            if (counter < MAX_COUNT) then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;
        end if;
    end process counter_p;
end architecture timepulse_1;

