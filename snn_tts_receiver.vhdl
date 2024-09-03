library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snn_tts_support_pkg.all;

-------------------------------------------------------------------------------

entity snn_tts_receiver is

  port (
    -------------------------------------------------------------
    -- clock and test IOs, supply
    -------------------------------------------------------------
    gckn : in std_ulogic;  -- toggles: global clock (N)

    ckoffn : in std_ulogic;  -- dc, 1: lck off (N)
    hld    : in std_ulogic;  -- ac, 0: test hold
    se     : in std_ulogic;  -- ac, 0: scan enable
    edis   : in std_ulogic;  -- dc, 0: force enable lck

    e         : in std_ulogic;  -- ac, 1: enable lck
    e_weights : in std_ulogic;  -- 1: enables weights to load
    dlylck    : in std_ulogic;  -- dc, 0: delay lck
    mpw1n     : in std_ulogic;  -- dc, 1: modify pulse width (N)
    mpw2n     : in std_ulogic;  -- dc, 1: modify pulse width (N)
    mpw3n     : in std_ulogic;  -- dc, 1: modify pulse width (N)

    -------------------------------------------------------------
    -- functional IOs
    -------------------------------------------------------------
    
    reset_spike : in std_ulogic; -- resets the receiver

    spike_in     : in  std_ulogic; -- incoming spike of the TTS encoded signal
    weight_in    : in  std_ulogic_vector(0 to NBW-1);
    receiver_out : out std_ulogic_vector(0 to NBW-1)  -- outgoing weight                
    );

end snn_tts_receiver;

architecture snn_tts_receiver of snn_tts_receiver is

  signal n_weight : std_ulogic_vector(0 to NBW-1);
  signal c_weight : std_ulogic_vector(0 to NBW-1);
  signal n_switch : std_ulogic; -- works as switch when spike arrives
  signal c_switch : std_ulogic;

  signal fce  : std_ulogic;
  signal hldn : std_ulogic;
  signal lck  : std_ulogic;
  
  signal lck_weights : std_ulogic;

begin
  
  -- weight register
  n_weight <= weight_in;

  -- signal changes to 1  when spike comes in. Works as a switch.
  n_switch <= '0' when reset_spike = '1' else
              '1' when spike_in = '1' else
              c_switch;

  -- sends out weight as long as switch is closed        
  receiver_out <= c_weight when n_switch = '1' else
                  (others => '0');

------------------------------------------------------------------------------------------------------

    weight_reg : entity work.behavioral_dff
        generic map (n => NBW)
        port map (
            clk => lck_weights,
            d   => n_weight,
            q   => c_weight
        );
    
    switch_reg : entity work.behavioral_dff_1bit
        port map (
            clk  => lck,
            d => n_switch,
            q => c_switch
        );


------------------------------------------------------------------------------------------------------

    bidi_lcb_weights : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en     => e_weights, 
            clkout => lck_weights
        );
    
    bidi_lcb : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en     => e,       
            clkout => lck
        ); 

end snn_tts_receiver;
