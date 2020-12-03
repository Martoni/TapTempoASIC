------------------------------------------------------------
-- Author(s) : Fabien Marteau <mail@fabienm.eu>
-- The TapTempo Project
-- Creation Date : 15/11/2020
------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
library work;
use work.taptempo_pkg.all;

entity pwmgen is
    generic(BPM_MAX : natural := 250);
    port (
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- timepulse
        tp_i : in std_logic;
        -- input value
        bpm_i : in std_logic_vector(BPM_SIZE-1 downto 0);
        bpm_valid : in std_logic;
        -- output
        pwm_o : out std_logic);
end entity;

architecture pwmgen_1 of pwmgen is
    signal count : natural range 0 to BPM_MAX;
    signal pwmthreshold : natural range 0 to BPM_MAX;
    signal bpm_reg : natural range 0 to BPM_MAX;
begin

-- Latching bpm_i on bpm_valid
bpm_latch_p : process(clk_i, rst_i)
begin
    if rst_i = '1' then
        bpm_reg <= 0;
        pwmthreshold <= 0;
    elsif rising_edge(clk_i) then
        if bpm_valid = '1' then
            bpm_reg <= to_integer(unsigned(bpm_i));
        end if;
        if(count = BPM_MAX) then
            pwmthreshold <= bpm_reg;
        end if;
    end if;
end process bpm_latch_p;

-- count
count_p : process(clk_i, rst_i)
begin
    if rst_i = '1' then
        count <= BPM_MAX;
    elsif rising_edge(clk_i) then
        if(tp_i = '1') then
            if (count = 0) then
                count <= BPM_MAX;
            else
                count <= count - 1;
            end if ;
        end if ;
    end if;
end process count_p;

-- pwm output
pwm_o <= '1' when (count < pwmthreshold) else '0';

end architecture pwmgen_1;
