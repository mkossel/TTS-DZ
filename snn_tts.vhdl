library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snn_tts_support_pkg.all;

-------------------------------------------------------------------------------

entity snn_tts is 
        
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
    reset_network    : in std_ulogic;
    reset_spike_out  : out std_ulogic;
    
    f_in       : in  f_array;     -- incoming signal, features of the data           
    w_HL_in    : in  w_array_HL;  -- weights for hidden layer
    w_OL_in    : in  w_array_OL;  -- weights for output layer
    bias_HL_in : in  b_array_HL;  -- bias for hidden layer
    bias_OL_in : in  b_array_OL;  -- bias for output layer
    
    label_out  : out std_ulogic_vector(0 to NOL-1)  -- output predicted label
    );

end snn_tts;

architecture snn_tts of snn_tts is 
  
  signal n_counter     : std_ulogic_vector(0 to NBS-1);
  signal c_counter     : std_ulogic_vector(0 to NBS-1);
  signal cycle_counter : std_ulogic_vector(0 to NBS-1);
  signal reset_spike   : std_ulogic;
  
  signal n_active_layers : std_ulogic_vector(0 to 3);
  signal c_active_layers : std_ulogic_vector(0 to 3);
  
  signal spikes_IL_out : spikes_IL; -- spike signal between input layer and hidden layer
  signal spikes_HL_out : spikes_HL; -- spike signal between hidden layer and output layer 
  signal spikes_OL_out : spikes_OL; -- spike signal output of output layer
  
  signal n_label  : std_ulogic_vector(0 to NOL-1);
  signal c_label  : std_ulogic_vector(0 to NOL-1);

  signal n_label_out  : std_ulogic_vector(0 to NOL-1);
  signal c_label_out  : std_ulogic_vector(0 to NOL-1);  
  
  signal fce  : std_ulogic;
  signal hldn : std_ulogic;
  signal lck  : std_ulogic;
  
  signal lck_reset : std_ulogic;
  signal e_reset   : std_ulogic;

  signal lck_label : std_ulogic;
  signal e_label   : std_ulogic;
  
  constant zero_vector : std_ulogic_vector(0 to NBS-1) := (others => '0');  

  component snn_tts_inputlayer_neuron is
    port (
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
      
      valid_signal : in  std_ulogic;
      
      reset_spike   : in  std_ulogic; 
      cycle_counter : in  std_ulogic_vector(0 to NBS-1);
      
      feature_in      : in  std_ulogic_vector(0 to NBS-1);                
      transmitter_out : out std_ulogic   -- outgoing spike signal                
    );
  end component;
  
  component snn_tts_layer1_neuron is
    port (
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
      
      valid_signal : in std_ulogic;
            
      reset_spike  : in std_ulogic;
      cycle_counter : in std_ulogic_vector(0 to NBS-1);
      
      spikes_in     : in spikes_IL;  -- incoming spikes of the TTS encoded signal
      weights_in    : in w_array_HL_neuron;
      bias_in	    : in std_ulogic_vector(0 to NBW-1);
                
      transmitter_out : out std_ulogic   -- outgoing spike signal                
    );
  end component;
  
  component snn_tts_outputlayer_neuron is
    port (
      gckn : in std_ulogic;    -- toggles: global clock (N)

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

      valid_signal : in std_ulogic;
            
      reset_spike   : in std_ulogic;
      cycle_counter : in std_ulogic_vector(0 to NBS-1);
      
      spikes_in  : in spikes_HL;  -- incoming spikes of the TTS encoded signal
      weights_in : in w_array_OL_neuron;
      bias_in	 : in std_ulogic_vector(0 to NBW-1);
                
      transmitter_out : out std_ulogic   -- outgoing spike signal
    );
  end component; 

begin
   
   e_reset <= reset_spike and e;
   
   -------- Validation Check ---------
   n_active_layers(0) <= '0' when reset_network = '1' else
                         '1' when f_in(0) /= zero_vector and reset_spike = '1' else
                         '1' when f_in(1) /= zero_vector and reset_spike = '1' else
                         '1' when f_in(2) /= zero_vector and reset_spike = '1' else
                         '1' when f_in(3) /= zero_vector and reset_spike = '1' else
                         '0';

    n_active_layers(1 to 3) <= (others => '0') when reset_network = '1' else
                               c_active_layers(0 to 2);
   
   -------- Reset clock & Counter ---------     		
   n_counter <= std_ulogic_vector(unsigned(c_counter) - 1) when c_active_layers(0) = '1' else
   		std_ulogic_vector(unsigned(c_counter) - 1) when c_active_layers(1) = '1' else
		std_ulogic_vector(unsigned(c_counter) - 1) when c_active_layers(2) = '1' else
		std_ulogic_vector(unsigned(c_counter) - 1) when c_active_layers(3) = '1' else
   		(others => '0');
   
   cycle_counter <= n_counter;
   
   reset_spike <= '1' when reset_network = '1' else
                  '1' when n_counter = zero_vector else
                  '0';
	   	    
   reset_spike_out <= reset_spike;

   -------- Input layer ---------
   -- Neuron 0 input layer
   neuron_0_IL : snn_tts_inputlayer_neuron
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e      => e,
      dlylck => dlylck,
      mpw1n  => mpw1n,
      mpw2n  => mpw2n,
      mpw3n  => mpw3n,
      
      valid_signal => c_active_layers(0),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
       
      feature_in      => f_in(0), -- sending feature signal to the neuron     
      transmitter_out => spikes_IL_out(0)  -- receiving output signal from the neuron
      );
      
   -- Neuron 1 input layer
   neuron_1_IL : snn_tts_inputlayer_neuron
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e      => e,
      dlylck => dlylck,
      mpw1n  => mpw1n,
      mpw2n  => mpw2n,
      mpw3n  => mpw3n,
      
      valid_signal => c_active_layers(0),
            
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
       
      feature_in      => f_in(1), -- sending feature signal to the neuron      
      transmitter_out => spikes_IL_out(1)     -- receiving output signal from the neuron
      );

   -- Neuron 2 input layer
   neuron_2_IL : snn_tts_inputlayer_neuron
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e      => e,
      dlylck => dlylck,
      mpw1n  => mpw1n,
      mpw2n  => mpw2n,
      mpw3n  => mpw3n,
      
      valid_signal => c_active_layers(0),
            
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
       
      feature_in      => f_in(2), -- sending feature signal to the neuro      
      transmitter_out => spikes_IL_out(2)     -- receiving output signal from the neuron
      );
      
   -- Neuron 3 input layer
   neuron_3_IL : snn_tts_inputlayer_neuron
    port map(
      gckn   => gckn,
      ckoffn => ckoffn,
      hld    => hld,
      se     => se,
      edis   => edis,
      
      e      => e,
      dlylck => dlylck,
      mpw1n  => mpw1n,
      mpw2n  => mpw2n,
      mpw3n  => mpw3n,
      
      valid_signal => c_active_layers(0),
           
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
       
      feature_in      => f_in(3), -- sending feature signal to the neuron     
      transmitter_out => spikes_IL_out(3)     -- receiving output signal from the neuron
      );

   -------- Hidden layer ---------
   -- Neuron 0 hidden layer
   neuron_0_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
          
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(0),       -- sending weights to the neuron
      bias_in    => bias_HL_in(0),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(0)     -- receiving output signal from the neuron
      );
      
   -- Neuron 1 hidden layer
   neuron_1_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
          
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(1),       -- sending weights to the neuron
      bias_in    => bias_HL_in(1),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(1)     -- receiving output signal from the neuron
      );

   -- Neuron 2 hidden layer
   neuron_2_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
          
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(2),       -- sending weights to the neuron
      bias_in    => bias_HL_in(2),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(2)     -- receiving output signal from the neuron
      );
      
   -- Neuron 3 hidden layer
   neuron_3_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
          
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(3), -- sending weights to the neuron
      bias_in    => bias_HL_in(3), -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(3)     -- receiving output signal from the neuron
      );
      
   -- Neuron 4 hidden layer
   neuron_4_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
         
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(4),       -- sending weights to the neuron
      bias_in    => bias_HL_in(4),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(4)     -- receiving output signal from the neuron
      );
      
   -- Neuron 5 hidden layer
   neuron_5_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
       
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(5),       -- sending weights to the neuron
      bias_in    => bias_HL_in(5),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(5)     -- receiving output signal from the neuron
      );

   -- Neuron 6 hidden layer
   neuron_6_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
          
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(6),       -- sending weights to the neuron
      bias_in    => bias_HL_in(6),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(6)     -- receiving output signal from the neuron
      );
      
   -- Neuron 7 hidden layer
   neuron_7_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
       
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(7),       -- sending weights to the neuron
      bias_in    => bias_HL_in(7),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(7)     -- receiving output signal from the neuron
      );

   -- Neuron 8 hidden layer
   neuron_8_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike   => reset_spike,
      cycle_counter => cycle_counter,
         
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(8),       -- sending weights to the neuron
      bias_in    => bias_HL_in(8),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(8)     -- receiving output signal from the neuron
      );
      
   -- Neuron 9 hidden layer
   neuron_9_HL : snn_tts_layer1_neuron
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
      
      valid_signal => c_active_layers(1),
      
      reset_spike  => reset_spike,
      cycle_counter => cycle_counter,
          
      spikes_in  => spikes_IL_out, -- sending spike signal to the neuron
      weights_in => w_HL_in(9),       -- sending weights to the neuron
      bias_in    => bias_HL_in(9),    -- sending bias to the neuron
      
      transmitter_out  => spikes_HL_out(9)     -- receiving output signal from the neuron
      );
		       
   -------- Output layer ---------
   -- Neuron 0 output layer
   neuron_0_OL : snn_tts_outputlayer_neuron
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
      
      valid_signal => c_active_layers(2),
      
      reset_spike  => reset_spike,
      cycle_counter => cycle_counter,
         
      spikes_in  => spikes_HL_out, -- sending spike signal to the neuron
      weights_in => w_OL_in(0),    -- sending weights to the neuron
      bias_in    => bias_OL_in(0), -- sending bias to the neuron
      
      transmitter_out  => spikes_OL_out(0)  -- receiving output signal from the neuron
      );   
      
   -- Neuron 1 output layer
   neuron_1_OL : snn_tts_outputlayer_neuron
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
      
      valid_signal => c_active_layers(2),
      
      reset_spike  => reset_spike,
      cycle_counter => cycle_counter,
          
      spikes_in  => spikes_HL_out, -- sending spike signal to the neuron
      weights_in => w_OL_in(1),       -- sending weights to the neuron
      bias_in    => bias_OL_in(1),    -- sending bias to the neuron
      
      transmitter_out  => spikes_OL_out(1)     -- receiving output signal from the neuron
      );

   -- Neuron 2 output layer
   neuron_2_OL : snn_tts_outputlayer_neuron
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
      
      valid_signal => c_active_layers(2),
      
      reset_spike  => reset_spike,
       cycle_counter => cycle_counter,
         
      spikes_in  => spikes_HL_out, -- sending spike signal to the neuron
      weights_in => w_OL_in(2),    -- sending weights to the neuron
      bias_in    => bias_OL_in(2), -- sending bias to the neuron
      
      transmitter_out => spikes_OL_out(2)  -- receiving output signal from the neuron
      );
      
   -------- Class label --------- 
   n_label <= (others => '0') when reset_network = '1' else
              "100" when spikes_OL_out(0) = '1' else
	      "010" when spikes_OL_out(1) = '1' else
	      "001" when spikes_OL_out(2) = '1' else
	      (others => '0');

   e_label <= '1' and e when reset_spike = '1' else
              '1' and e when c_label = "000" and c_active_layers(2) = '1'  else
              '0';

   n_label_out <= c_label;
               
   label_out <= c_label_out;
		 
------------------------------------------------------------------------------------------------------

    reset_counter_reg : entity work.behavioral_dff
        generic map (n => NBS)
        port map (
            clk  => lck,
            d    => n_counter,
            q    => c_counter
        );
    
    active_layers_reg : entity work.behavioral_dff
        generic map (n => 4)
        port map (
            clk  => lck_reset,
            d    => n_active_layers(0 to 3),
            q    => c_active_layers(0 to 3)
        );
    
    label_reg : entity work.behavioral_dff
        generic map (n => NOL)
        port map (
            clk  => lck_label,
            d    => n_label,
            q    => c_label
        );
    
    label_out_reg : entity work.behavioral_dff
        generic map (n => NOL)
        port map (
            clk  => lck_reset,
            d    => n_label_out,
            q    => c_label_out
        );
   
------------------------------------------------------------------------------------------------------

    bidi_lcb : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en     => e,       
            clkout => lck
        );   
    
    bidi_lcb_reset : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en     => e_reset,
            clkout => lck_reset
        );    
    
    bidi_lcb_label : entity work.behavioral_lcb
        port map (
            clkin  => gckn,
            en     => e_label,
            clkout => lck_label
        ); 

end snn_tts;
