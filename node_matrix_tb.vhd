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
         data_tick : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         in_path : OUT  std_logic;
         weight_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
    constant comm_header : std_logic_vector(7 downto 0) := "01010111";
    constant comm_cell_w : std_logic_vector(7 downto 0) := "00000001";
    constant comm_beg_addr : std_logic_vector(7 downto 0) := "00000010";
    constant comm_end_addr : std_logic_vector(7 downto 0) := "00000011";
    constant comm_prog_beg : std_logic_vector(7 downto 0) := "00000100";
    constant comm_prog_end : std_logic_vector(7 downto 0) := "00000101";

   --Inputs
   signal clk : std_logic := '0';
   signal disp_loc_in : std_logic_vector(7 downto 0) := (others => '0');
   signal data_tick : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal count,jcount : unsigned(7 downto 0) := (others=>'0');

 	--Outputs
   signal in_path : std_logic;
   signal weight_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: node_matrix PORT MAP (
          clk => clk,
          disp_loc_in => disp_loc_in,
          data_tick => data_tick,
          data_in => data_in,
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

    wait for clk_period/2;
    jcount<=(others=>'0');
    for J in 0 to 1 loop
         --send the end address
         data_in<=comm_header;
         data_tick<='1';
         wait for clk_period;
         data_tick<='0';
         wait for 8*clk_period;
         data_in<=comm_end_addr;
         data_tick<='1';
         wait for clk_period;
         data_tick<='0';
         wait for 8*clk_period;
         data_in<="00000010";
         data_tick<='1';
         wait for clk_period;
         data_tick<='0';
         wait for 8*clk_period;

         --send the start address
         data_in<=comm_header;
         data_tick<='1';
         wait for clk_period;
         data_tick<='0';
         wait for 8*clk_period;
         data_in<=comm_beg_addr;
         data_tick<='1';
         wait for clk_period;
         data_tick<='0';
         wait for 8*clk_period;
         data_in<="00000001";
         data_tick<='1';
         wait for clk_period;
         data_tick<='0';
         wait for 8*clk_period;


         --send the weights
     for I in 0 to 255 loop
          data_in<=comm_header;
          data_tick<='1';
          wait for clk_period;
          data_tick<='0';
          wait for 8*clk_period;

          data_in<=comm_cell_w;
          data_tick<='1';
          wait for clk_period;
          data_tick<='0';
          wait for 8*clk_period;

          data_in<=std_logic_vector(count);
          data_tick<='1';
          wait for clk_period;
          data_tick<='0';
          wait for 8*clk_period;
          if (J=0) then
            data_in<=std_logic_vector(count);
          else 
            data_in<=std_logic_vector("11111111"-count);
            end if;
          data_tick<='1';
          wait for clk_period;
          data_tick<='0';
          count<=count+"01";
          wait for 8*clk_period;
                  -- insert stimulus here 
     end loop;
    
     --send the start signal
     data_in<=comm_header;
     data_tick<='1';
     wait for clk_period;
     data_tick<='0';
     wait for 8*clk_period;
     data_in<=comm_prog_beg;
     data_tick<='1';
     wait for clk_period;
     data_tick<='0';
     wait for clk_period;

     --send display indices
     count<=(others=>'0');
     disp_loc_in<=std_logic_vector(count);
     wait for 3*clk_period;
     for I in 0 to 255 loop
          count<=count+"01";
          wait for clk_period;
          disp_loc_in<=std_logic_vector(count);
          wait for 3*clk_period;
     end loop;

     --send the end signal
     data_in<=comm_header;
     data_tick<='1';
     wait for clk_period;
     data_tick<='0';
     wait for clk_period;
     data_in<=comm_prog_end;
     data_tick<='1';
     wait for clk_period;
     data_tick<='0';
     wait for clk_period;
     wait for 300*clk_period;
 end loop;
 wait;
   end process;

END;
