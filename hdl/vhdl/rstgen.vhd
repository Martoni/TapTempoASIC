------------------------------------------------------------
-- The TapTempo Project
-- Creation Date : 28/11/2020
-- Author(s) : Fabien Marteau <mail@fabienm.eu>
------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
library work;
use work.taptempo_pkg.all;

entity rstgen is
    port (
        -- clock input
        clk_i : in std_logic;
        -- rst output
        rst_o : out std_logic
    );
end entity rstgen;

architecture rstgen_1 of rstgen is
    signal rst_count : natural range 0 to 4 := 0;
begin

    rst_o <= '1' when (rst_count < 4) else '0';

    rstgen_p : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if (rst_count < 4) then
                rst_count <= rst_count + 1;
            end if;
        end if;
    end process rstgen_p;

end architecture rstgen_1;
