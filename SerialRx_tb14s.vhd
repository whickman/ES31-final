--------------------------------------------------------------------------------
-- Course:	 		Engs 31 14S
-- Engineer:        Will Hickman
-- Design Name:   
-- Module Name:   SerialRx_tb.vhd
-- Project Name:  Lab5
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lab5top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
 
ENTITY SerialRx_tb IS
END SerialRx_tb;
 
ARCHITECTURE behavior OF SerialRx_tb IS 
 
COMPONENT lab6
    PORT(
         Clk25 : IN  std_logic;
         TXD : IN  std_logic;
         empty_switch_raw : IN std_logic;
         reverse_switch : IN std_logic;
         RXD : OUT  std_logic;
         LED : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk25 : std_logic := '0';
   signal TXD : std_logic := '1';
   signal empty_switch_raw : std_logic := '0';
   signal reverse_switch : std_logic := '0';


 	--Outputs
   signal RXD : std_logic;
   signal LED : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant Clk25_period : time := 40ns;
	
	-- Data definitions
--	constant bit_time : time := 104us;		-- 9600 baud
	constant bit_time : time := 8.68us;		-- 115,200 baud
	constant TxData : std_logic_vector(7 downto 0) := "01101001";
	constant TxData2 : std_logic_vector(7 downto 0) := "00001000";
	
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
   uut: lab6 PORT MAP (
          Clk25 => Clk25,
          empty_switch_raw=>empty_switch_raw,
          reverse_switch=>reverse_switch,
          TXD => TXD,
          RXD => RXD,
          LED => LED
        );

   -- Clock process definitions
   Clk25_process :process
   begin
		Clk25 <= '0';
		wait for Clk25_period/2;
		Clk25 <= '1';
		wait for Clk25_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
		wait for 50 us;
		wait for 10.25*Clk25_period;		
		
		
		wait for bit_time;
	
        for I in 0 to 8 loop
		  
				TXD <= '0';		-- Start bit
            for bitcount in 0 to 7 loop
                TXD <= TxData(bitcount);
                wait for bit_time;
            end loop;
            
            TXD <= '1';		-- Stop bit
            wait for 100 us;	

            TXD <= '0';		-- Start bit
            wait for bit_time;
            
            for bitcount in 0 to 7 loop
                TXD <= TxData2(bitcount);
                wait for bit_time;
            end loop;

		    TXD <= '1';		-- Stop bit		
            wait for 100 us;	
        end loop;
        reverse_switch<='1';	
        wait for 800 us;
        empty_switch_raw<='1';
		  wait for 100000*Clk25_period;
		  empty_switch_raw<='0';
        wait;
   end process;
END;
