----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:11:34 05/03/2014 
-- Design Name: 
-- Module Name:    output_selector - Behavioral 
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

entity output_selector is
    Port ( clk : in STD_LOGIC;
           rx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           mem_data : in  STD_LOGIC_VECTOR (7 downto 0);
           output_sel : in  STD_LOGIC;
           output_data : out  STD_LOGIC_VECTOR (7 downto 0));
end output_selector;

architecture Behavioral of output_selector is

begin
	output_data <= rx_data when output_sel='0' else mem_data;
--    clocked_process : process(clk)
--    begin
--        if rising_edge(clk) then
--            if (output_sel='0') then
--                output_data<=rx_data;
--            else
--                output_data<=mem_data;
--            end if;
--        end if;
--    end process;


end Behavioral;

