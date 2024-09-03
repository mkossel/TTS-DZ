library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity behavioral_dff_1bit is
    port (
        clk : in std_ulogic;
        d : in std_ulogic;
        q :  out std_ulogic
    );
end behavioral_dff_1bit;

architecture behavioral_dff_1bit of behavioral_dff_1bit is
begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            q <= d  after 50 ps;
        end if;
    end process;
end behavioral_dff_1bit;
