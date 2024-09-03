library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package snn_support_pkg is
  
  constant GCKN_PERIOD  : time    := 400 ps; -- 2.5GHz
  constant CELAT_PULSE  : time    := 10 ps;
  constant CELAT_DELAY  : time    := 2 ps; 
  
  
  constant ADDR_LENGTH  : integer :=  4;     -- highest value is 15 
  constant LUT_WIDTH  	: integer :=  5;     -- highest value is 16
  constant BITS_OBS_INT : integer := 6;      -- the interval is 0-63, highest value to be represented is 63

end package snn_support_pkg;


package body snn_support_pkg is

end package body snn_support_pkg;
