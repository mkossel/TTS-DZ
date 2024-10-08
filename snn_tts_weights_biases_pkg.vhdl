library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package snn_tts_weights_biases_pkg is

  -- weights hidden layer --
  type weights_HL_vector is array (0 to 3) of std_ulogic_vector(0 to 5);
  type weights_HL_array is array (0 to 9) of weights_HL_vector;  
  constant weights_HL : weights_HL_array := (
        ( "001001", "001010", "111100", "110110"),  -- (0): [ 0.5625  0.625  -0.25   -0.625 ]   real values: [ 0.56443214  0.62897128 -0.2581394  -0.63886768]
        ( "001011", "111101", "111100", "111101"),  -- (1): [ 0.6875 -0.1875 -0.25   -0.1875]   real values: [ 0.70403385 -0.19055735 -0.24839784 -0.20883079]
        ( "110110", "111101", "000010", "001001"),  -- (2): [-0.625  -0.1875  0.125   0.5625]   real values: [-0.64027494 -0.19385475  0.12458247  0.58392215]
        ( "111000", "001000", "111000", "000010"),  -- (3): [-0.5     0.5    -0.5     0.125 ]   real values: [-0.47367612  0.51902795 -0.47925103  0.10448104]
        ( "110111", "110111", "000011", "110111"),  -- (4): [-0.5625 -0.5625  0.1875 -0.5625]   real values: [-0.53283244 -0.56416273  0.18218595 -0.53248036]
        ( "000111", "110110", "001100", "010000"),  -- (5): [ 0.4375 -0.625   0.75    1.    ]   real values: [ 0.41168469 -0.61702091  0.76997805  0.974567  ]
        ( "111111", "111110", "001011", "000000"),  -- (6): [-0.0625 -0.125   0.6875  0.    ]   real values: [-0.04759748 -0.15084279  0.69958144 -0.0196865 ]
        ( "000100", "110010", "001111", "011010"),  -- (7): [ 0.25   -0.875   0.9375  1.625 ]   real values: [ 0.27743301 -0.84648818  0.91938794  1.62858176]
        ( "001101", "001011", "110001", "101110"),  -- (8): [ 0.8125  0.6875 -0.9375 -1.125 ]   real values: [ 0.82760614  0.68355834 -0.91967201 -1.12798941]
        ( "111100", "000000", "111110", "000010")   -- (9): [-0.25    0.     -0.125   0.125 ]   real values: [-0.27342811  0.02397382 -0.14947277  0.1172204 ]
        );
	
  -- biases hidden layer --
  type biases_HL_vector is array (0 to 9) of std_ulogic_vector(0 to 5); 
  constant biases_HL : biases_HL_vector := ( "000111", "000100", "000000", "000000", "000000", "110110", "111010", "111010", "001010", "000000");  
  -- [ 0.4375  0.25    0.      0.      0.     -0.625  -0.375  -0.375   0.625  0.    ]   real values: [ 0.4435366094112396 0.2311095893383026 0.0 0.0 0.0 -0.6203048825263977 -0.3804432153701782 -0.372809499502182 0.613123893737793 0.0  ]
  

  -- weights output layer --
  type weights_OL_vector is array (0 to 9) of std_ulogic_vector(0 to 5);
  type weights_OL_array is array (0 to 2) of weights_OL_vector;  
  constant weights_OL : weights_OL_array := (
        ( "001000", "000111", "111100", "111010", "110111", "110000", "111010", "110000", "011000", "000101"),  -- (0): [ 0.5     0.4375 -0.25   -0.375  -0.5625 -1.     -0.375  -1.      1.5    0.3125]   real values: [ 0.50706267  0.41606125 -0.2590642  -0.3526026  -0.58153099 -1.02304268 -0.36179411 -0.98597175  1.52065063  0.33047605]
        ( "001011", "001010", "111011", "001010", "000001", "111001", "110111", "000010", "000010", "111011"),  -- (1): [ 0.6875  0.625  -0.3125  0.625   0.0625 -0.4375 -0.5625  0.125   0.125 -0.3125]   real values: [ 0.67761981  0.63552946 -0.32347474  0.6209265   0.05692106 -0.43432039 -0.55743742  0.12044821  0.15219755 -0.28212503]
        ( "110000", "000100", "000010", "000111", "110111", "000100", "001100", "001010", "101000", "111110")   -- (2): [-1.      0.25    0.125   0.4375 -0.5625  0.25    0.75    0.625  -1.5   -0.125 ]   real values: [-0.989797    0.2248435   0.13220942  0.42212081 -0.53845721  0.28033954  0.75175864  0.60383815 -1.48336387 -0.09707433]
        );

  -- biases output layer --	
  type biases_OL_vector is array (0 to 2) of std_ulogic_vector(0 to 5); 
  constant biases_OL : biases_OL_vector := ( "000101", "000100", "111001");  -- [ 0.3125  0.25   -0.4375]   real values: [ 0.2986317574977875  0.2707380950450897 -0.4682842195034027]


end package snn_tts_weights_biases_pkg;


package body snn_tts_weights_biases_pkg is



end package body snn_tts_weights_biases_pkg;
