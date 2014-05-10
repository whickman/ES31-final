----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:00:15 05/10/2014 
-- Design Name: 
-- Module Name:    node_matrix - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity node_matrix is
    Port ( clk : in  STD_LOGIC;
           color : out  STD_LOGIC_VECTOR (7 downto 0);
           location : out  STD_LOGIC_VECTOR (7 downto 0));
end node_matrix;

architecture Behavioral of node_matrix is
    type grid_array is array (0 to 15) of std_logic_vector(15 downto 0);
    signal ping_array,backtrace_array : grid_array := (others=>'0');
begin


end Behavioral;

