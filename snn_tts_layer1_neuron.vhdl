library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snn_tts_support_pkg.all;

-------------------------------------------------------------------------------

entity snn_tts_layer1_neuron is 
        
  port (
    -------------------------------------------------------------
    -- clock and test IOs, supply
    -------------------------------------------------------------
    gckn   : in std_ulogic;  -- toggles: global clock (N)

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
    valid_signal : in  std_ulogic;
      
    reset_spike   : in  std_ulogic;
    cycle_counter : in  std_ulogic_vector(0 to NBS-1);
    
    spikes_in     : in  spikes_IL;  -- incoming spikes of the TTS encoded signal
    weights_in    : in  w_array_HL_neuron;
    bias_in	  : in  std_ulogic_vector(0 to NBW-1);
                
    transmitter_out : out std_ulogic   -- outgoing spike signal                
    );

end snn_tts_layer1_neuron;

architecture snn_tts_layer1_neuron of snn_tts_layer1_neuron is
  
  constant roundUp    : std_ulogic_vector(0 to NBS+NBW-1) := (NBW+NBS-FBW => '1', others => '0');
  constant slope_init : std_ulogic_vector(0 to NBW+NBS-1) := (0 to NBW+NBS-1 => '0');
  
  signal receivers_out : receiver_HL;
  
  signal slope      : std_ulogic_vector(0 to NBW+NBS-1);
  
  signal n_membranPot : std_ulogic_vector(0 to NBW+NBS-1);
  signal c_membranPot : std_ulogic_vector(0 to NBW+NBS-1);
  
  signal n_bias     : std_ulogic_vector(0 to NBW+NBS-1);
  signal c_bias     : std_ulogic_vector(0 to NBW+NBS-1);
  signal membranPot : std_ulogic_vector(0 to NBW+NBS-1);

  signal n_quantPot : std_ulogic_vector(0 to NBS-1);
  signal c_quantPot : std_ulogic_vector(0 to NBS-1);
  
  signal fce  : std_ulogic;
  signal hldn : std_ulogic;
  signal lck  : std_ulogic;
  
  signal lck_reset   : std_ulogic;
  signal e_reset     : std_ulogic;
  signal lck_weights : std_ulogic;

  component snn_tts_receiver is
    port (
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
    
      reset_spike : in std_ulogic;  -- reset spike to set receiver back
      
      spike_in     : in  std_ulogic;  -- incoming spikes of the TTS encoded signal
      weight_in    : in  std_ulogic_vector(0 to NBW-1);              
      receiver_out : out std_ulogic_vector(0 to NBW-1)                   
    );
  end component;

begin

  e_reset <= reset_spike and e;
  
  -------- Receivers ---------
  receiver_0 : snn_tts_receiver
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e         => e,
      e_weights => e_weights,
      dlylck    => dlylck,
      mpw1n     => mpw1n,
      mpw2n     => mpw2n,
      mpw3n     => mpw3n,
                  
      reset_spike  => reset_spike,
       
      spike_in     => spikes_in(0),   
      weight_in    => weights_in(0),
      receiver_out => receivers_out(0)    
      );
    
  receiver_1 : snn_tts_receiver
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e         => e,
      e_weights => e_weights,
      dlylck    => dlylck,
      mpw1n     => mpw1n,
      mpw2n     => mpw2n,
      mpw3n     => mpw3n,
                  
      reset_spike  => reset_spike,
      
      spike_in     => spikes_in(1),   
      weight_in    => weights_in(1),
      receiver_out => receivers_out(1)    
      );
      
  receiver_2 : snn_tts_receiver
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e         => e,
      e_weights => e_weights,
      dlylck    => dlylck,
      mpw1n     => mpw1n,
      mpw2n     => mpw2n,
      mpw3n     => mpw3n,
                  
      reset_spike  => reset_spike,
          
      spike_in     => spikes_in(2),    
      weight_in    => weights_in(2),
      receiver_out => receivers_out(2)    
      );
    
  receiver_3 : snn_tts_receiver
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e         => e,
      e_weights => e_weights,
      dlylck    => dlylck,
      mpw1n     => mpw1n,
      mpw2n     => mpw2n,
      mpw3n     => mpw3n,
                  
      reset_spike  => reset_spike,
       
      spike_in     => spikes_in(3),   
      weight_in    => weights_in(3),
      receiver_out => receivers_out(3)    
      );
  
  -------- adder tree ---------
  slope <= std_ulogic_vector(signed(slope_init) + signed(receivers_out(0)) + signed(receivers_out(1)) + signed(receivers_out(2)) + signed(receivers_out(3)));
			     

  -------- integrator  ---------  
  n_membranPot <= (others => '0') when reset_spike = '1' else
  		  std_ulogic_vector(signed(slope) + signed(c_membranPot));
		  
  
  -------- adder for bias ---------
  n_bias <= (0 to NBS-FBS-1 => '1') & bias_in & (0 to FBS-1 => '0') when bias_in(0) = '1' else
            (0 to NBS-FBS-1 => '0') & bias_in & (0 to FBS-1 => '0');
	    
   
  -- add bias to potential and round half up 
  membranPot <= std_ulogic_vector(signed(c_bias) + signed(c_membranPot) + signed(roundUp));
 
  -------- Transmitter ---------
  -- Quantizer
  n_quantPot <= (others => '0') when membranPot(0) = '1' else -- reLU
                (others => '1') when membranPot(1) = '1' else -- clipping
	        membranPot(2 to 7);
  
  -- Comparator 
  transmitter_out <= '1' when valid_signal = '1' and  reset_spike = '0' and  c_quantPot = cycle_counter else
  		     '0';

------------------------------------------------------------------------------------------------------

    membranPot_reg : entity work.behavioral_dff
        generic map (n => NBW+NBS)
        port map (
            clk  => lck,
            d    => n_membranPot,
            q    => c_membranPot
        );
    
    
    bias_reg : entity work.behavioral_dff
        generic map (n => NBW+NBS)
        port map (
            clk  => lck_weights,
            d    => n_bias,
            q    => c_bias
        );
    
    quantPot_reg : entity work.behavioral_dff
        generic map (n => NBS)
        port map (
            clk  => lck_reset,
            d    => n_quantPot,
            q    => c_quantPot
        );
    

------------------------------------------------------------------------------------------------------

    bidi_lcb : entity work.behavioral_lcb
        port map (
            clkin => gckn,
            en      => e,      
            clkout    => lck
        );   
    
    bidi_lcb_reset : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en     => e_reset,    
            clkout => lck_reset
        );    
        
    bidi_lcb_weights : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en      => e_weights,
            clkout => lck_weights
        );
  		
end snn_tts_layer1_neuron;
