----------------------------------------------------------------------------------
-- Company:         ENGS 31 
-- Engineer:        Will Hickman
-- 
-- Create Date:    23:14:31 04/26/2014 
-- Design Name: 
-- Module Name:    load_reg - Behavioral 
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

entity load_reg is
    Port ( data_in: in  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           load : in  STD_LOGIC;
			  --test : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
end load_reg;

architecture Behavioral of load_reg is
signal output : std_logic_vector(7 downto 0) := (others=>'1');
begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            if (load='1') then
                output<=data_in;
            else NULL;
            end if;
        end if;
    end process;

    data_out<=output;
	 --test<=output(7);

end Behavioral;

