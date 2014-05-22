----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:43:10 05/16/2014 
-- Design Name: 
-- Module Name:    weight_reg - Behavioral 
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

entity weight_reg is
    Port ( clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           clear : in STD_LOGIC;
           enable : in STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end weight_reg;

architecture Behavioral of weight_reg is

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
