library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- declaration
package taptempo_pkg is

    constant CLK_PER_NS : natural;
    constant BPM_MAX : natural;
    constant BPM_SIZE : natural;
    constant TP_CYCLE : natural;
    constant BTN_PER_MAX : natural;
    constant BTN_PER_SIZE : natural;
    constant BTN_PER_MIN : natural;
    constant MIN_US : natural;

    constant ZEROS : std_logic_vector(31 downto 0);

    -- Usefull function for register size
    function log2ceil(m : integer) return integer;

end package taptempo_pkg;

-- body
package body taptempo_pkg is

    constant CLK_PER_NS : natural := 40;
    constant BPM_MAX : natural := 250;
    constant TP_CYCLE : natural := 5120;
    -- constant MIN_NS : natural := 60000000000;
    constant MIN_US : natural := 60_000_000;
    constant BPM_SIZE : natural := log2ceil(BPM_MAX + 1);
    constant BTN_PER_MAX : natural := 1000*(MIN_US/TP_CYCLE);
    constant BTN_PER_SIZE : natural := log2ceil(BTN_PER_MAX + 1);
    constant BTN_PER_MIN : natural := 1000*(MIN_US/TP_CYCLE)/BPM_MAX;

    constant ZEROS : std_logic_vector(31 downto 0) := x"00000000";

    function log2ceil(m : integer) return integer is
    begin
      for i in 0 to integer'high loop
            if 2 ** i >= m then
                return i;
            end if;
        end loop;
    end function log2ceil;

end package body;
