--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:41:48 05/12/2014
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
         row_in : IN  std_logic_vector(3 downto 0);
         col_in : IN  std_logic_vector(3 downto 0);
         shift_state : IN  std_logic_vector(1 downto 0);
         data_tick : IN  std_logic;
         serial_row_in : IN  std_logic_vector(3 downto 0);
         serial_col_in : IN  std_logic_vector(3 downto 0);
         data_in : IN  std_logic_vector(7 downto 0);
         reset_in : IN  std_logic;
         in_path : OUT  std_logic_vector(1 downto 0);
         weight_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal row_in : std_logic_vector(3 downto 0) := (others => '0');
   signal col_in : std_logic_vector(3 downto 0) := (others => '0');
   signal shift_state : std_logic_vector(1 downto 0) := (others => '0');
   signal data_tick : std_logic := '0';
   signal serial_row_in : std_logic_vector(3 downto 0) := (others => '0');
   signal serial_col_in : std_logic_vector(3 downto 0) := (others => '0');
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal reset_in : std_logic := '0';

   --Others
   signal Ivect : std_logic_vector(7 downto 0);

 	--Outputs
   signal in_path : std_logic_vector(1 downto 0);
   signal weight_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: node_matrix PORT MAP (
          clk => clk,
          row_in => row_in,
          col_in => col_in,
          shift_state => shift_state,
          data_tick => data_tick,
          serial_row_in => serial_row_in,
          serial_col_in => serial_col_in,
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

      -- insert stimulus here 

      shift_state<="00";
      for I in 0 to 255 loop
          Ivect<=std_logic_vector(to_unsigned(I,8));
          data_in<=Ivect;
          serial_row_in<=Ivect(7 downto 4);
          serial_col_in<=Ivect(3 downto 0);
          data_tick<='1';
          wait for clk_period;
          data_tick<='0';
          wait for clk_period;
      end loop;

      wait;
   end process;

END;
