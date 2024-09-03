library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package snn_tts_support_pkg is

  constant NF  : integer :=  4;  -- number of incoming features as signals
  constant NHL : integer := 10;	 -- number of hidden layer neurons	
  constant NOL : integer :=  3;  -- number of output layer neurons
  constant NBS : integer :=  6;  -- number of bits of signed signal vector
  constant FBS : integer :=  2;  -- number of fraction bits of the signal vector
  constant NBW : integer :=  6;  -- number of bits of signed weight vector
  constant FBW : integer :=  4;  -- number of fraction bits of the weight vector

  -- All arrays for the input layer
  type f_array   is array(0 to NF-1) of std_ulogic_vector(0 to NBS-1); -- feature array
  type spikes_IL is array(0 to NF-1) of std_ulogic; -- spikes to encode the features
   
  -- All arrays for the hidden layer
  type spikes_HL is array(0 to NHL-1) of std_ulogic; -- spikes to encode the output of the hidden layer
  type receiver_HL is array(0 to NF-1) of std_ulogic_vector(0 to NBW-1);
  type w_array_HL_neuron is array(0 to NF-1) of std_ulogic_vector(0 to NBW-1); -- all weights for one hidden layer neuron
  type w_array_HL is array(0 to NHL-1) of w_array_HL_neuron; -- weight array for the hidden layer
  type b_array_HL is array(0 to NHL-1) of std_ulogic_vector(0 to NBW-1); -- bias array for the hidden layer
    
  -- All arrays for the output layer
  type spikes_OL is array(0 to NOL-1) of std_ulogic; -- spikes to encode the output of the output layer
  type receiver_OL is array(0 to NHL-1) of std_ulogic_vector(0 to NBW-1);
  type w_array_OL_neuron is array(0 to NHL-1) of std_ulogic_vector(0 to NBW-1); -- all weights for one output layer neuron
  type w_array_OL is array(0 to NOL-1) of w_array_OL_neuron; -- weight array for the output layer
  type b_array_OL is array(0 to NOL-1) of std_ulogic_vector(0 to NBW-1); -- bias array for the output layer
  
  
end package snn_tts_support_pkg;


package body snn_tts_support_pkg is

end package body snn_tts_support_pkg;
