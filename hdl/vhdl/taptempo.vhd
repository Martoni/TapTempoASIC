-- The TapTempo Project
-- Created on    : 28/11/2020
-- Author        : Fabien Marteau <mail@fabienm.eu>
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.taptempo_pkg.all;

Entity taptempo is
    port(
        clk_i : in std_logic;
        btn_i : in std_logic;
        pwm_o : in std_logic);
end entity taptempo;

architecture taptempo_1 of taptempo is
begin
end architecture taptempo_1;
