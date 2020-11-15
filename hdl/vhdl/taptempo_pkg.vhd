-- declaration
package taptempo_pkg is
    
function log2ceil(m : integer) return integer;

end package taptempo_pkg;

-- body
package body taptempo_pkg is

    function log2ceil(m : integer) return integer is
    begin
      for i in 0 to integer'high loop
            if 2 ** i >= m then
                return i;
            end if;
        end loop;
    end function log2ceil;

end package body;
