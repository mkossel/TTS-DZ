library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snn_tts_support_pkg.all;

-------------------------------------------------------------------------------

entity snn_tts_inputlayer_neuron is 
        
  port (
    -------------------------------------------------------------
    -- clock and test IOs, supply
    -------------------------------------------------------------
    gckn   : in std_ulogic;  -- toggles: global clock (N)

    ckoffn : in std_ulogic;  -- dc, 1: lck off (N)
    hld    : in std_ulogic;  -- ac, 0: test hold
    se     : in std_ulogic;  -- ac, 0: scan enable
    edis   : in std_ulogic;  -- dc, 0: force enable lck

    e      : in std_ulogic;  -- ac, 1: enable lck
    dlylck : in std_ulogic;  -- dc, 0: delay lck
    mpw1n  : in std_ulogic;  -- dc, 1: modify pulse width (N)
    mpw2n  : in std_ulogic;  -- dc, 1: modify pulse width (N)
    mpw3n  : in std_ulogic;  -- dc, 1: modify pulse width (N)

    -------------------------------------------------------------
    -- functional IOs
    -------------------------------------------------------------
    valid_signal : in  std_ulogic;
     
    reset_spike   : in  std_ulogic; 
    cycle_counter : in  std_ulogic_vector(0 to NBS-1);
    feature_in    : in  std_ulogic_vector(0 to NBS-1);
                
    transmitter_out : out std_ulogic   -- outgoing spike signal                
    );
 
end snn_tts_inputlayer_neuron;

architecture snn_tts_inputlayer_neuron of snn_tts_inputlayer_neuron is
  
  signal n_feature    : std_ulogic_vector(0 to NBS-1); -- input of data register for feature data
  signal c_feature    : std_ulogic_vector(0 to NBS-1); -- output of data register for feature data
  
  signal fce  : std_ulogic;
  signal hldn : std_ulogic;
  
  signal lck_reset : std_ulogic;
  signal e_reset   : std_ulogic;

begin

  e_reset <= reset_spike and e;
  
  -------- Transmitter --------- 
  -- Register
  n_feature <= feature_in;
  
  -- Comparator 
  transmitter_out <= '1' when valid_signal = '1' 
                         and reset_spike = '0' 
			 and  c_feature = cycle_counter 
                     else
                     '0';

------------------------------------------------------------------------------------------------------

    feature_reg : entity work.behavioral_dff
        generic map (n => NBS)
        port map (
            clk  => lck_reset,
            d    => n_feature,
            q    => c_feature
        );
      
------------------------------------------------------------------------------------------------------

    bidi_lcb_reset : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en      => e_reset, 
            clkout => lck_reset
        ); 
		
end snn_tts_inputlayer_neuron;
