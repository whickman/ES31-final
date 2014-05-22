----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:30:50 05/11/2014 
-- Design Name: 
-- Module Name:    reg_8b - Behavioral 
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

entity reg_8b is
    Port ( clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           clear : in STD_LOGIC;
           enable : in STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end reg_8b;

architecture Behavioral of reg_8b is

begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            if (clear='1') then
                data_out<=(others=>'0');
            elsif (enable='1') then
                data_out<=data_in;
            end if;
        end if;
    end process;

end Behavioral;
