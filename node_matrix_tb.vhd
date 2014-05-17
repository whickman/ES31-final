--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:42:33 05/16/2014
-- Design Name:   
-- Module Name:   /home/will/Code/VHDL/final/node_matrix_tb.vhd
-- Project Name:  misc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: node_matrix
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY node_matrix_tb IS
END node_matrix_tb;
 
ARCHITECTURE behavior OF node_matrix_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT node_matrix
    PORT(
         clk : IN  std_logic;
         disp_loc_in : IN  std_logic_vector(7 downto 0);
         shift_state : IN  std_logic_vector(1 downto 0);
         data_tick : IN  std_logic;
         serial_in : IN  std_logic_vector(7 downto 0);
         data_in : IN  std_logic_vector(7 downto 0);
         reset_in : IN  std_logic;
         in_path : OUT  std_logic_vector(1 downto 0);
         weight_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal disp_loc_in : std_logic_vector(7 downto 0) := (others => '0');
   signal shift_state : std_logic_vector(1 downto 0) := (others => '0');
   signal data_tick : std_logic := '0';
   signal serial_in : std_logic_vector(7 downto 0) := (others => '0');
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal reset_in : std_logic := '0';
   signal count : unsigned(7 downto 0) := (others=>'0');

 	--Outputs
   signal in_path : std_logic_vector(1 downto 0);
   signal weight_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: node_matrix PORT MAP (
          clk => clk,
          disp_loc_in => disp_loc_in,
          shift_state => shift_state,
          data_tick => data_tick,
          serial_in => serial_in,
          data_in => data_in,
          reset_in => reset_in,
          in_path => in_path,
          weight_out => weight_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
      shift_state<="00";
      for I in 0 to 255 loop
        serial_in<=std_logic_vector(count);
        data_in<=std_logic_vector(count);
        count<=count+"01";
        data_tick<='1';
        wait for clk_period;
        data_tick<='0';
        wait for clk_period;
      -- insert stimulus here 
    end loop;

    shift_state<="01";
    serial_in<="11111111";
    data_tick<='1';
    wait for clk_period;
    shift_state<="10";
    serial_in<="00000000";
    data_tick<='1';
    wait for clk_period;
    shift_state<="11";
    data_tick<='0';
    wait for clk_period;
    data_tick<='1';
    shift_state<="00";
    wait for clk_period;
    count<=(others=>'0');
    for I in 0 to 255 loop
        disp_loc_in<=std_logic_vector(count);
        data_tick<='1';
        count<=count+"01";
        wait for clk_period;
        data_tick<='0';
        wait for clk_period;
    end loop;
    wait;
   end process;

END;
