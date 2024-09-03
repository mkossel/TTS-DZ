library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity behavioral_lcb is
    port (
        clkin : in std_ulogic;
        en : in std_ulogic;
        clkout : out std_ulogic
    );
end behavioral_lcb;

architecture behavioral_lcb of behavioral_lcb is
    signal en_latched : std_ulogic;
begin
    process(clkin)
    begin
        if(clkin = '0') then 
            en_latched <= en;
        end if;
    end process;
    clkout <= clkin and en_latched;
end behavioral_lcb;
