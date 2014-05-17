--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:46:25 05/11/2014
-- Design Name:   
-- Module Name:   /home/will/Code/VHDL/final/node_test.vhd
-- Project Name:  misc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: node
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
--USE ieee.numeric_std.ALL;
 
ENTITY node_test IS
END node_test;
 
ARCHITECTURE behavior OF node_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT node
    PORT(
         clk : IN  std_logic;
         weight : IN  std_logic_vector(7 downto 0);
         in_ping_start : IN  std_logic;
         in_ping_N : IN  std_logic;
         in_ping_E : IN  std_logic;
         in_ping_S : IN  std_logic;
         in_ping_W : IN  std_logic;
         reset : IN  std_logic;
         out_ping : OUT  std_logic;
         pinged_by : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal weight : std_logic_vector(7 downto 0) := (others => '0');
   signal in_ping_start : std_logic := '0';
   signal in_ping_N : std_logic := '0';
   signal in_ping_E : std_logic := '0';
   signal in_ping_S : std_logic := '0';
   signal in_ping_W : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal out_ping,oping2 : std_logic;
   signal pinged_by : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: node PORT MAP (
          clk => clk,
          weight => weight,
          in_ping_start => in_ping_start,
          in_ping_N => in_ping_N,
          in_ping_E => in_ping_E,
          in_ping_S => in_ping_S,
          in_ping_W => in_ping_W,
          reset => reset,
          out_ping => out_ping,
          pinged_by => pinged_by
        );
   uut2: node PORT MAP (
          clk => clk,
          weight => "00001000",
          in_ping_start => '0',
          in_ping_N => '0',
          in_ping_E => '0',
          in_ping_S => '0',
          in_ping_W => out_ping,
          reset => '0',
          out_ping => oping2,
          pinged_by => open
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
      weight<="00011111";
      in_ping_e<='1';
      wait for clk_period;
      in_ping_e<='0';
      wait for clk_period*50;
      reset<='1';
      wait for clk_period;
      reset<='0';
      -- insert stimulus here 

      wait;
   end process;

END;
