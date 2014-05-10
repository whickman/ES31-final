
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:56:33 05/10/2014 
-- Design Name: 
-- Module Name:    vga_color - Behavioral 
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

entity vga_color is
    Port ( row : in  STD_LOGIC_VECTOR (9 downto 0);
           column : in  STD_LOGIC_VECTOR (9 downto 0);
           color : in  STD_LOGIC_VECTOR (7 downto 0));
end vga_color;

architecture Behavioral of vga_color is

begin


end Behavioral;

