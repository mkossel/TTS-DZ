library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snn_tts_support_pkg.all;

entity snn_tts_wrapper is

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

    reset_nn : in std_ulogic;
    
    reset_spike_out : out std_ulogic;

    -------------------------------------------------------------
    -- functional IOs
    -------------------------------------------------------------
    -- incoming signal, features of the data | x-dim: NBS=6, y-dim: NF=4
    f0_in : in std_ulogic_vector(0 to NBS-1); 
    f1_in : in std_ulogic_vector(0 to NBS-1);
    f2_in : in std_ulogic_vector(0 to NBS-1);
    f3_in : in std_ulogic_vector(0 to NBS-1);

    -- hidden layer consisting of 10 neurons
    -- weights for hidden layer | x-dim: NBW=6, y-dim: NF=4, z-dim: NHL=10
    w00_hl_in : in std_ulogic_vector(0 to NBW-1);
    w01_hl_in : in std_ulogic_vector(0 to NBW-1);
    w02_hl_in : in std_ulogic_vector(0 to NBW-1);
    w03_hl_in : in std_ulogic_vector(0 to NBW-1);

    w10_hl_in : in std_ulogic_vector(0 to NBW-1);
    w11_hl_in : in std_ulogic_vector(0 to NBW-1);
    w12_hl_in : in std_ulogic_vector(0 to NBW-1);
    w13_hl_in : in std_ulogic_vector(0 to NBW-1);

    w20_hl_in : in std_ulogic_vector(0 to NBW-1);
    w21_hl_in : in std_ulogic_vector(0 to NBW-1);
    w22_hl_in : in std_ulogic_vector(0 to NBW-1);
    w23_hl_in : in std_ulogic_vector(0 to NBW-1);

    w30_hl_in : in std_ulogic_vector(0 to NBW-1);
    w31_hl_in : in std_ulogic_vector(0 to NBW-1);
    w32_hl_in : in std_ulogic_vector(0 to NBW-1);
    w33_hl_in : in std_ulogic_vector(0 to NBW-1);

    w40_hl_in : in std_ulogic_vector(0 to NBW-1);
    w41_hl_in : in std_ulogic_vector(0 to NBW-1);
    w42_hl_in : in std_ulogic_vector(0 to NBW-1);
    w43_hl_in : in std_ulogic_vector(0 to NBW-1);

    w50_hl_in : in std_ulogic_vector(0 to NBW-1);
    w51_hl_in : in std_ulogic_vector(0 to NBW-1);
    w52_hl_in : in std_ulogic_vector(0 to NBW-1);
    w53_hl_in : in std_ulogic_vector(0 to NBW-1);

    w60_hl_in : in std_ulogic_vector(0 to NBW-1);
    w61_hl_in : in std_ulogic_vector(0 to NBW-1);
    w62_hl_in : in std_ulogic_vector(0 to NBW-1);
    w63_hl_in : in std_ulogic_vector(0 to NBW-1);

    w70_hl_in : in std_ulogic_vector(0 to NBW-1);
    w71_hl_in : in std_ulogic_vector(0 to NBW-1);
    w72_hl_in : in std_ulogic_vector(0 to NBW-1);
    w73_hl_in : in std_ulogic_vector(0 to NBW-1);

    w80_hl_in : in std_ulogic_vector(0 to NBW-1);
    w81_hl_in : in std_ulogic_vector(0 to NBW-1);
    w82_hl_in : in std_ulogic_vector(0 to NBW-1);
    w83_hl_in : in std_ulogic_vector(0 to NBW-1);

    w90_hl_in : in std_ulogic_vector(0 to NBW-1);
    w91_hl_in : in std_ulogic_vector(0 to NBW-1);
    w92_hl_in : in std_ulogic_vector(0 to NBW-1);
    w93_hl_in : in std_ulogic_vector(0 to NBW-1);

    -- output layer consisting of 3 neurons
    -- weights for output layer | x-dim: NBW=6, y-dim: NHL=10, z-dim: NOL=3
    w00_ol_in : in std_ulogic_vector(0 to NBW-1);
    w01_ol_in : in std_ulogic_vector(0 to NBW-1);
    w02_ol_in : in std_ulogic_vector(0 to NBW-1);
    w03_ol_in : in std_ulogic_vector(0 to NBW-1);
    w04_ol_in : in std_ulogic_vector(0 to NBW-1);
    w05_ol_in : in std_ulogic_vector(0 to NBW-1);
    w06_ol_in : in std_ulogic_vector(0 to NBW-1);
    w07_ol_in : in std_ulogic_vector(0 to NBW-1);
    w08_ol_in : in std_ulogic_vector(0 to NBW-1);
    w09_ol_in : in std_ulogic_vector(0 to NBW-1);

    w10_ol_in : in std_ulogic_vector(0 to NBW-1);
    w11_ol_in : in std_ulogic_vector(0 to NBW-1);
    w12_ol_in : in std_ulogic_vector(0 to NBW-1);
    w13_ol_in : in std_ulogic_vector(0 to NBW-1);
    w14_ol_in : in std_ulogic_vector(0 to NBW-1);
    w15_ol_in : in std_ulogic_vector(0 to NBW-1);
    w16_ol_in : in std_ulogic_vector(0 to NBW-1);
    w17_ol_in : in std_ulogic_vector(0 to NBW-1);
    w18_ol_in : in std_ulogic_vector(0 to NBW-1);
    w19_ol_in : in std_ulogic_vector(0 to NBW-1);

    w20_ol_in : in std_ulogic_vector(0 to NBW-1);
    w21_ol_in : in std_ulogic_vector(0 to NBW-1);
    w22_ol_in : in std_ulogic_vector(0 to NBW-1);
    w23_ol_in : in std_ulogic_vector(0 to NBW-1);
    w24_ol_in : in std_ulogic_vector(0 to NBW-1);
    w25_ol_in : in std_ulogic_vector(0 to NBW-1);
    w26_ol_in : in std_ulogic_vector(0 to NBW-1);
    w27_ol_in : in std_ulogic_vector(0 to NBW-1);
    w28_ol_in : in std_ulogic_vector(0 to NBW-1);
    w29_ol_in : in std_ulogic_vector(0 to NBW-1);

    -- bias for hidden layer consisting of 10 neurons
    -- bias for hidden layer | x-dim: NBW=6, y-dim: NHL=10 
    bias0_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias1_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias2_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias3_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias4_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias5_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias6_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias7_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias8_hl_in : in std_ulogic_vector(0 to NBW-1);
    bias9_hl_in : in std_ulogic_vector(0 to NBW-1);

    -- bias for output layer consisting of 3 neurons
    -- bias for output layer | x-dim: NBW=6, y-dim: NOL=3     
    bias0_ol_in : in std_ulogic_vector(0 to NBW-1);
    bias1_ol_in : in std_ulogic_vector(0 to NBW-1);
    bias2_ol_in : in std_ulogic_vector(0 to NBW-1);

    -- output predicted label:
    -- 000: Iris setosa | 010: Iris versicolor | 001: Iris virginica 
    label_out : out std_ulogic_vector(0 to NOL-1)

    -- number of inputs: 534 (=12+24+240+180+60+18)
    -- number of outputs: 3
    );

end snn_tts_wrapper;

architecture snn_tts_wrapper of snn_tts_wrapper is

  signal f_in       : f_array;    -- incoming signal, features of the data           
  signal w_HL_in    : w_array_HL; -- weights for hidden layer
  signal w_OL_in    : w_array_OL; -- weights for output layer
  signal bias_HL_in : b_array_HL; -- bias for hidden layer
  signal bias_OL_in : b_array_OL; -- bias for output layer

  component snn_tts is
    port (
      gckn : in std_ulogic;  -- toggles: global clock (N)

      ckoffn : in std_ulogic;  -- dc, 1: lck off (N)
      hld    : in std_ulogic;  -- ac, 0: test hold
      se     : in std_ulogic;  -- ac, 0: scan enable
      edis   : in std_ulogic;  -- dc, 0: force enable lck

      e         : in std_ulogic;  -- ac, 1: enable lck
      e_weights : in std_ulogic; 
      dlylck    : in std_ulogic;  -- dc, 0: delay lck
      mpw1n     : in std_ulogic;  -- dc, 1: modify pulse width (N)
      mpw2n     : in std_ulogic;  -- dc, 1: modify pulse width (N)
      mpw3n     : in std_ulogic;  -- dc, 1: modify pulse width (N)

      reset_network : in  std_ulogic;
      
      reset_spike_out  : out std_ulogic;

      f_in       : in  f_array;     -- incoming signal, features of the data           
      w_HL_in    : in  w_array_HL;  -- weights for hidden layer -> type w_array_HL_neuron is array(0 to NF-1) of std_ulogic_vector(0 to NBW-1); -> with NF=4 and NBW=6
      w_OL_in    : in  w_array_OL;  -- weights for output layer
      bias_HL_in : in  b_array_HL;  -- bias for hidden layer
      bias_OL_in : in  b_array_OL;  -- bias for output layer
      label_out  : out std_ulogic_vector(0 to NOL-1) ---- number of output layer neurons NOL=3
      );
  end component;

begin

  -------- Mapping to wrapper ---------
  mapping : snn_tts
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

      reset_network    => reset_nn,
      reset_spike_out  => reset_spike_out,

      f_in       => f_in,
      w_HL_in    => w_HL_in,
      w_OL_in    => w_OL_in,
      bias_HL_in => bias_HL_in,
      bias_OL_in => bias_OL_in,
      label_out  => label_out
      );

  f_in(0) <= f0_in;
  f_in(1) <= f1_in;
  f_in(2) <= f2_in;
  f_in(3) <= f3_in;

  w_HL_in(0)(0)(0 to NBW-1) <= w00_hl_in;
  w_HL_in(0)(1)(0 to NBW-1) <= w01_hl_in;
  w_HL_in(0)(2)(0 to NBW-1) <= w02_hl_in;
  w_HL_in(0)(3)(0 to NBW-1) <= w03_hl_in;

  w_HL_in(1)(0)(0 to NBW-1) <= w10_hl_in;
  w_HL_in(1)(1)(0 to NBW-1) <= w11_hl_in;
  w_HL_in(1)(2)(0 to NBW-1) <= w12_hl_in;
  w_HL_in(1)(3)(0 to NBW-1) <= w13_hl_in;

  w_HL_in(2)(0)(0 to NBW-1) <= w20_hl_in;
  w_HL_in(2)(1)(0 to NBW-1) <= w21_hl_in;
  w_HL_in(2)(2)(0 to NBW-1) <= w22_hl_in;
  w_HL_in(2)(3)(0 to NBW-1) <= w23_hl_in;

  w_HL_in(3)(0)(0 to NBW-1) <= w30_hl_in;
  w_HL_in(3)(1)(0 to NBW-1) <= w31_hl_in;
  w_HL_in(3)(2)(0 to NBW-1) <= w32_hl_in;
  w_HL_in(3)(3)(0 to NBW-1) <= w33_hl_in;

  w_HL_in(4)(0)(0 to NBW-1) <= w40_hl_in;
  w_HL_in(4)(1)(0 to NBW-1) <= w41_hl_in;
  w_HL_in(4)(2)(0 to NBW-1) <= w42_hl_in;
  w_HL_in(4)(3)(0 to NBW-1) <= w43_hl_in;

  w_HL_in(5)(0)(0 to NBW-1) <= w50_hl_in;
  w_HL_in(5)(1)(0 to NBW-1) <= w51_hl_in;
  w_HL_in(5)(2)(0 to NBW-1) <= w52_hl_in;
  w_HL_in(5)(3)(0 to NBW-1) <= w53_hl_in;

  w_HL_in(6)(0)(0 to NBW-1) <= w60_hl_in;
  w_HL_in(6)(1)(0 to NBW-1) <= w61_hl_in;
  w_HL_in(6)(2)(0 to NBW-1) <= w62_hl_in;
  w_HL_in(6)(3)(0 to NBW-1) <= w63_hl_in;

  w_HL_in(7)(0)(0 to NBW-1) <= w70_hl_in;
  w_HL_in(7)(1)(0 to NBW-1) <= w71_hl_in;
  w_HL_in(7)(2)(0 to NBW-1) <= w72_hl_in;
  w_HL_in(7)(3)(0 to NBW-1) <= w73_hl_in;

  w_HL_in(8)(0)(0 to NBW-1) <= w80_hl_in;
  w_HL_in(8)(1)(0 to NBW-1) <= w81_hl_in;
  w_HL_in(8)(2)(0 to NBW-1) <= w82_hl_in;
  w_HL_in(8)(3)(0 to NBW-1) <= w83_hl_in;

  w_HL_in(9)(0)(0 to NBW-1) <= w90_hl_in;
  w_HL_in(9)(1)(0 to NBW-1) <= w91_hl_in;
  w_HL_in(9)(2)(0 to NBW-1) <= w92_hl_in;
  w_HL_in(9)(3)(0 to NBW-1) <= w93_hl_in;

  w_OL_in(0)(0)(0 to NBW-1) <= w00_ol_in;
  w_OL_in(0)(1)(0 to NBW-1) <= w01_ol_in;
  w_OL_in(0)(2)(0 to NBW-1) <= w02_ol_in;
  w_OL_in(0)(3)(0 to NBW-1) <= w03_ol_in;
  w_OL_in(0)(4)(0 to NBW-1) <= w04_ol_in;
  w_OL_in(0)(5)(0 to NBW-1) <= w05_ol_in;
  w_OL_in(0)(6)(0 to NBW-1) <= w06_ol_in;
  w_OL_in(0)(7)(0 to NBW-1) <= w07_ol_in;
  w_OL_in(0)(8)(0 to NBW-1) <= w08_ol_in;
  w_OL_in(0)(9)(0 to NBW-1) <= w09_ol_in;

  w_OL_in(1)(0)(0 to NBW-1) <= w10_ol_in;
  w_OL_in(1)(1)(0 to NBW-1) <= w11_ol_in;
  w_OL_in(1)(2)(0 to NBW-1) <= w12_ol_in;
  w_OL_in(1)(3)(0 to NBW-1) <= w13_ol_in;
  w_OL_in(1)(4)(0 to NBW-1) <= w14_ol_in;
  w_OL_in(1)(5)(0 to NBW-1) <= w15_ol_in;
  w_OL_in(1)(6)(0 to NBW-1) <= w16_ol_in;
  w_OL_in(1)(7)(0 to NBW-1) <= w17_ol_in;
  w_OL_in(1)(8)(0 to NBW-1) <= w18_ol_in;
  w_OL_in(1)(9)(0 to NBW-1) <= w19_ol_in;

  w_OL_in(2)(0)(0 to NBW-1) <= w20_ol_in;
  w_OL_in(2)(1)(0 to NBW-1) <= w21_ol_in;
  w_OL_in(2)(2)(0 to NBW-1) <= w22_ol_in;
  w_OL_in(2)(3)(0 to NBW-1) <= w23_ol_in;
  w_OL_in(2)(4)(0 to NBW-1) <= w24_ol_in;
  w_OL_in(2)(5)(0 to NBW-1) <= w25_ol_in;
  w_OL_in(2)(6)(0 to NBW-1) <= w26_ol_in;
  w_OL_in(2)(7)(0 to NBW-1) <= w27_ol_in;
  w_OL_in(2)(8)(0 to NBW-1) <= w28_ol_in;
  w_OL_in(2)(9)(0 to NBW-1) <= w29_ol_in;

  bias_HL_in(0)(0 to NBW-1) <= bias0_hl_in;
  bias_HL_in(1)(0 to NBW-1) <= bias1_hl_in;
  bias_HL_in(2)(0 to NBW-1) <= bias2_hl_in;
  bias_HL_in(3)(0 to NBW-1) <= bias3_hl_in;
  bias_HL_in(4)(0 to NBW-1) <= bias4_hl_in;
  bias_HL_in(5)(0 to NBW-1) <= bias5_hl_in;
  bias_HL_in(6)(0 to NBW-1) <= bias6_hl_in;
  bias_HL_in(7)(0 to NBW-1) <= bias7_hl_in;
  bias_HL_in(8)(0 to NBW-1) <= bias8_hl_in;
  bias_HL_in(9)(0 to NBW-1) <= bias9_hl_in;

  bias_OL_in(0)(0 to NBW-1) <= bias0_ol_in;
  bias_OL_in(1)(0 to NBW-1) <= bias1_ol_in;
  bias_OL_in(2)(0 to NBW-1) <= bias2_ol_in;

end snn_tts_wrapper;
