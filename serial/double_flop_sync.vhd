----------------------------------------------------------------------------------
-- Company:         ENGS 31 
-- Engineer:        Will Hickman
-- 
-- Create Date:    22:52:59 04/26/2014 
-- Design Name: 
-- Module Name:    double_flop_sync - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity double_flop_sync is
    Port ( async_in : in  STD_LOGIC;
           clk : in  STD_LOGIC;
--			  test : out STD_LOGIC;
--			  test2 : out STD_LOGIC;
           async_out : out  STD_LOGIC);
end double_flop_sync;

architecture Behavioral of double_flop_sync is
signal output : std_logic;
signal val : std_logic_vector (1 downto 0) := (others=>'1');
begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            output<=val(1);
            val<=val(0) & async_in;
        end if;
    end process;
	 
	 async_out<=output;

end Behavioral;

