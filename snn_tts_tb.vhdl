library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snn_tts_support_pkg.all;
use work.snn_tts_dataset_pkg.all;
use work.snn_tts_weights_biases_pkg.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity snn_tts_tb is

end entity snn_tts_tb;
 
architecture behavioral of snn_tts_tb is    
    
  -- component ports
  signal e : std_ulogic;
  signal e_weights : std_ulogic;
  signal reset_nn : std_ulogic;
  
  signal f_in      : f_array;
  signal w_HL      : w_array_HL;
  signal w_OL      : w_array_OL;   
  signal bias_HL   : b_array_HL;
  signal bias_OL   : b_array_OL;
  
  signal label_out : std_ulogic_vector(0 to NOL-1);
  signal reset_spike_out  : std_ulogic;
  
  signal gckn        : std_ulogic := '1';
  constant cycle     : time       := 800 ps;
  constant halfcycle : time       := cycle/2;
  
  signal label_integer : integer; --introduced by MKO to access accuracy of prediction
  signal label_of_fin  : integer; --introduced by MKO to access accuracy of prediction
  signal var_delay01_label_of_fin  : integer; --introduced by MKO to access accuracy of prediction
  signal var_delay02_label_of_fin  : integer; --introduced by MKO to access accuracy of prediction 
  signal var_delay03_label_of_fin  : integer; --introduced by MKO to access accuracy of prediction 
  signal var_delay04_label_of_fin  : integer; --introduced by MKO to access accuracy of prediction       
  signal labels_do_match : integer; --introduced by MKO to access accuracy of prediction
  signal var_start_count : integer; --introduced by MKO to access accuracy of prediction
  signal var_count_value : integer; --introduced by MKO to access accuracy of prediction
  signal var_error_counter : integer:=0; --introduced by MKO to access accuracy of prediction
  signal var_label_count : integer:=0; --introduced by MKO to access accuracy of prediction 
  signal var_accuracy : real:=0.0; --introduced by MKO to access accuracy of prediction   


begin  -- architecture behavioral

  -- component instantiation
  DUT : entity work.snn_tts_wrapper
    port map (
      gckn        => gckn,
      ckoffn      => '1',
      hld         => '0',
      se          => '0',
      edis        => '0',
      e           => e,
      e_weights   => e_weights,
      dlylck      => '0',
      mpw1n       => '1',
      mpw2n       => '1',
      mpw3n       => '1',

      reset_nn    => reset_nn,
      
      f0_in          => f_in(0),
      f1_in          => f_in(1),
      f2_in          => f_in(2),
      f3_in          => f_in(3),
                  
      w00_hl_in      => w_HL(0)(0),
      w01_hl_in      => w_HL(0)(1),
      w02_hl_in      => w_HL(0)(2),
      w03_hl_in      => w_HL(0)(3),
      
      w10_hl_in      => w_HL(1)(0),
      w11_hl_in      => w_HL(1)(1),
      w12_hl_in      => w_HL(1)(2),
      w13_hl_in      => w_HL(1)(3),
      
      w20_hl_in      => w_HL(2)(0),
      w21_hl_in      => w_HL(2)(1),
      w22_hl_in      => w_HL(2)(2),
      w23_hl_in      => w_HL(2)(3),
      
      w30_hl_in      => w_HL(3)(0),
      w31_hl_in      => w_HL(3)(1),
      w32_hl_in      => w_HL(3)(2),
      w33_hl_in      => w_HL(3)(3),
      
      w40_hl_in      => w_HL(4)(0),
      w41_hl_in      => w_HL(4)(1),
      w42_hl_in      => w_HL(4)(2),
      w43_hl_in      => w_HL(4)(3),
      
      w50_hl_in      => w_HL(5)(0),
      w51_hl_in      => w_HL(5)(1),
      w52_hl_in      => w_HL(5)(2),
      w53_hl_in      => w_HL(5)(3),
      
      w60_hl_in      => w_HL(6)(0),
      w61_hl_in      => w_HL(6)(1),
      w62_hl_in      => w_HL(6)(2),
      w63_hl_in      => w_HL(6)(3),
      
      w70_hl_in      => w_HL(7)(0),
      w71_hl_in      => w_HL(7)(1),
      w72_hl_in      => w_HL(7)(2),
      w73_hl_in      => w_HL(7)(3),
      
      w80_hl_in      => w_HL(8)(0),
      w81_hl_in      => w_HL(8)(1),
      w82_hl_in      => w_HL(8)(2),
      w83_hl_in      => w_HL(8)(3),
      
      w90_hl_in      => w_HL(9)(0),
      w91_hl_in      => w_HL(9)(1),
      w92_hl_in      => w_HL(9)(2),
      w93_hl_in      => w_HL(9)(3),
      
      w00_ol_in      => w_OL(0)(0),
      w01_ol_in      => w_OL(0)(1),
      w02_ol_in      => w_OL(0)(2),
      w03_ol_in      => w_OL(0)(3),
      w04_ol_in      => w_OL(0)(4),
      w05_ol_in      => w_OL(0)(5),
      w06_ol_in      => w_OL(0)(6),
      w07_ol_in      => w_OL(0)(7),
      w08_ol_in      => w_OL(0)(8),
      w09_ol_in      => w_OL(0)(9),
      
      w10_ol_in      => w_OL(1)(0),
      w11_ol_in      => w_OL(1)(1),
      w12_ol_in      => w_OL(1)(2),
      w13_ol_in      => w_OL(1)(3),
      w14_ol_in      => w_OL(1)(4),
      w15_ol_in      => w_OL(1)(5),
      w16_ol_in      => w_OL(1)(6),
      w17_ol_in      => w_OL(1)(7),
      w18_ol_in      => w_OL(1)(8),
      w19_ol_in      => w_OL(1)(9),
      
      w20_ol_in      => w_OL(2)(0),
      w21_ol_in      => w_OL(2)(1),
      w22_ol_in      => w_OL(2)(2),
      w23_ol_in      => w_OL(2)(3),
      w24_ol_in      => w_OL(2)(4),
      w25_ol_in      => w_OL(2)(5),
      w26_ol_in      => w_OL(2)(6),
      w27_ol_in      => w_OL(2)(7),
      w28_ol_in      => w_OL(2)(8),
      w29_ol_in      => w_OL(2)(9),
      
      bias0_hl_in    => bias_HL(0),
      bias1_hl_in    => bias_HL(1),
      bias2_hl_in    => bias_HL(2),
      bias3_hl_in    => bias_HL(3),
      bias4_hl_in    => bias_HL(4),
      bias5_hl_in    => bias_HL(5),
      bias6_hl_in    => bias_HL(6),
      bias7_hl_in    => bias_HL(7),
      bias8_hl_in    => bias_HL(8),
      bias9_hl_in    => bias_HL(9),
      
      bias0_ol_in    => bias_OL(0),
      bias1_ol_in    => bias_OL(1),
      bias2_ol_in    => bias_OL(2),
      
      label_out  => label_out,
      reset_spike_out => reset_spike_out
      );
 
  -- clock generation
  gckn <= not gckn after halfcycle;




  -- Evaluation of accurarcy (introduced by MKO)
  eval_result : process(f_in, label_out, gckn)    
  begin  
     label_integer <= 2 when label_out(0 to 2) = "001" else
                      1 when label_out(0 to 2) = "010" else
		      0 when label_out(0 to 2) = "100" else
		      9 when label_out(0 to 2) = "000";
     if rising_edge(label_out(0)) or falling_edge(label_out(0))
        or rising_edge(label_out(1)) or falling_edge(label_out(1))
	or rising_edge(label_out(2)) or falling_edge(label_out(2))
     then
        var_start_count <=1;
	var_count_value <=0;
     end if;
     
     if rising_edge(f_in(0)(0)) or falling_edge(f_in(0)(0))
        or rising_edge(f_in(0)(1)) or falling_edge(f_in(0)(1))
        or rising_edge(f_in(0)(2)) or falling_edge(f_in(0)(2))
        or rising_edge(f_in(0)(3)) or falling_edge(f_in(0)(3))
        or rising_edge(f_in(0)(4)) or falling_edge(f_in(0)(4))
        or rising_edge(f_in(0)(5)) or falling_edge(f_in(0)(5))	
	or
	rising_edge(f_in(1)(0)) or falling_edge(f_in(1)(0))
        or rising_edge(f_in(1)(1)) or falling_edge(f_in(1)(1))
        or rising_edge(f_in(1)(2)) or falling_edge(f_in(1)(2))
        or rising_edge(f_in(1)(3)) or falling_edge(f_in(1)(3))
        or rising_edge(f_in(1)(4)) or falling_edge(f_in(1)(4))
        or rising_edge(f_in(1)(5)) or falling_edge(f_in(1)(5))
	or
	rising_edge(f_in(2)(0)) or falling_edge(f_in(2)(0))
        or rising_edge(f_in(2)(1)) or falling_edge(f_in(2)(1))
        or rising_edge(f_in(2)(2)) or falling_edge(f_in(2)(2))
        or rising_edge(f_in(2)(3)) or falling_edge(f_in(2)(3))
        or rising_edge(f_in(2)(4)) or falling_edge(f_in(2)(4))
        or rising_edge(f_in(2)(5)) or falling_edge(f_in(2)(5))	
	or
	rising_edge(f_in(3)(0)) or falling_edge(f_in(3)(0))
        or rising_edge(f_in(3)(1)) or falling_edge(f_in(3)(1))
        or rising_edge(f_in(3)(2)) or falling_edge(f_in(3)(2))
        or rising_edge(f_in(3)(3)) or falling_edge(f_in(3)(3))
        or rising_edge(f_in(3)(4)) or falling_edge(f_in(3)(4))
        or rising_edge(f_in(3)(5)) or falling_edge(f_in(3)(5))						
     then 
        var_label_count <= var_label_count + 1;
	--delay feature value for comparison with label_out
	var_delay04_label_of_fin <= var_delay03_label_of_fin;	
	var_delay03_label_of_fin <= var_delay02_label_of_fin;
	var_delay02_label_of_fin <= var_delay01_label_of_fin;
	var_delay01_label_of_fin <= label_of_fin;		
     end if;
     
     
     
     -- sampling of label signals after 4 clock edges
     if rising_edge(gckn) or falling_edge(gckn) then
        if var_start_count = 1 then
	   var_count_value <= var_count_value + 1;
	   if var_count_value = 4 then
              if label_integer = var_delay04_label_of_fin then
	         labels_do_match <= 0;
	      else
	         labels_do_match <= 1;
		 var_error_counter <= var_error_counter + 1;
		 if var_label_count >0 then
		    -- instantaneous calculation of accuracy (please record end value in SimVision)
		    var_accuracy <= (real(var_label_count)-real(var_error_counter))/real(var_label_count)*100.0;
		 end if;
	      end if;
	      var_start_count <= 0;	      	   
	   end if;
	end if;
     end if;
     		      
  end process eval_result; 
 

  -- waveform generation
  sim_neuron : process  
  
  begin
    
    e <= '0';

    wait for 2*cycle;
     
    e_weights <= '1';
    reset_nn  <= '1';

    wait for  2*cycle;

    -- load weight --
       
    gen_w_HL_init: for i in 0 to (NF-1) loop
      for i2 in 0 to (NHL-1) loop
       	 w_HL(i2)(i) <= weights_HL(i2)(i);
      end loop;
    end loop gen_w_HL_init;
       
    gen_w_OL_init: for i in 0 to (NHL-1) loop
      for i2 in 0 to (NOL-1) loop
       	w_OL(i2)(i) <= weights_OL(i2)(i);
      end loop;
    end loop gen_w_OL_init;    
       
    gen_b_HL_init: for i in 0 to (NHL-1) loop
      bias_HL(i) <= biases_HL(i);
    end loop gen_b_HL_init;
       
    gen_b_OL_init: for i in 0 to (NOL-1) loop
      bias_OL(i) <= biases_OL(i);
    end loop gen_b_OL_init;
 
    wait for  2*cycle;
    e_weights <= '0';

    wait for  2*cycle;
    reset_nn  <= '0';
    e <=  '1';
    
    -- new data --
    
    gen_data: for idx in 0 to 149 loop
      label_of_fin <= feature_label_value(idx); --added by MKO
      for i in 0 to (NF-1) loop
       	f_in(i) <= feature_data(idx)(i);
      end loop;
      wait for 64*cycle;
    end loop gen_data;
    
    -- new data --
    
    gen_f_zero1: for i in 0 to (NF-1) loop
      f_in(i) <= "000000";
    end loop gen_f_zero1;
    
    wait for 64*cycle;
    
    wait for 64*cycle;
    
    wait for 64*cycle;
    
    wait for 2*cycle;
    e <= '0';
    
    wait for 2*cycle;
                
    --wait;           -- forever
    std.env.stop;     -- immediately stops the simulator

  end process sim_neuron;

end architecture behavioral;
