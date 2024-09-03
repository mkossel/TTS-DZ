library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snn_tts_support_pkg.all;

entity behavioral_dff is
    generic (
        n : integer := 1  
    );
    port (
        clk : in std_ulogic;
        d : in std_ulogic_vector(0 to n-1);
        q :  out std_ulogic_vector(0 to n-1)
    );
end behavioral_dff;

architecture behavioral_dff of behavioral_dff is
begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            q <= d  after 50 ps;
        end if;
    end process;
end behavioral_dff;
