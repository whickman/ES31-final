--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:03:35 05/19/2014
-- Design Name:   
-- Module Name:   O:/final//solver_tb.vhd
-- Project Name:  misc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: solver
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
 
ENTITY solver_tb IS
END solver_tb;
 
ARCHITECTURE behavior OF solver_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT solver
    PORT(
         clk_real : IN  std_logic;
         TXD : IN  std_logic;
         red : OUT  std_logic_vector(2 downto 0);
         green : OUT  std_logic_vector(2 downto 0);
         blue : OUT  std_logic_vector(1 downto 0);
         hs : OUT  std_logic;
         vs : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_real : std_logic := '0';
   signal TXD : std_logic := '0';

 	--Outputs
   signal red : std_logic_vector(2 downto 0);
   signal green : std_logic_vector(2 downto 0);
   signal blue : std_logic_vector(1 downto 0);
   signal hs : std_logic;
   signal vs : std_logic;

	constant bit_time : time := 8.68us;
	constant comm_header : std_logic_vector(7 downto 0) := "01010111";
    constant comm_cell_w : std_logic_vector(7 downto 0) := "00000001";
    constant comm_beg_addr : std_logic_vector(7 downto 0) := "00000010";
    constant comm_end_addr : std_logic_vector(7 downto 0) := "00000011";
    constant comm_prog_beg : std_logic_vector(7 downto 0) := "00000100";
    constant comm_prog_end : std_logic_vector(7 downto 0) := "00000101";
	 signal count : unsigned(7 downto 0) := (others=>'0');
	
   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: solver PORT MAP (
          clk_real => clk_real,
          TXD => TXD,
          red => red,
          green => green,
          blue => blue,
          hs => hs,
          vs => vs
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk_real <= '0';
		wait for clk_period/2;
		clk_real <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

		count<=(others=>'0');
		
		for I in 0 to 255 loop
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_header(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_cell_w(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= std_logic(count(bitcount));
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= std_logic(count(bitcount));
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			count<=count+"01";

					  -- insert stimulus here 
		 end loop;

			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_header(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_beg_addr(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= '0';
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_header(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_end_addr(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= '1';
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_header(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;
			
			TXD <= '0';		-- Start bit
			wait for bit_time;
			for bitcount in 0 to 7 loop
				TXD <= comm_prog_beg(bitcount);
				wait for bit_time;
			end loop;
			TXD <= '1';		-- Stop bit
			wait for bit_time;

      wait;
   end process;

END;
