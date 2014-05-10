----------------------------------------------------------------------------------
-- Company:        ENGS 31 
-- Engineer:       Will Hickman
-- 
-- Create Date:    22:58:45 04/26/2014 
-- Design Name: 
-- Module Name:    shift_reg - Behavioral 
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

entity shift_reg is
    Port ( data_in : in  STD_LOGIC;
           shift : in  STD_LOGIC;
           clr : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  --test : out STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (7 downto 0):=(others=>'1'));
end shift_reg;

architecture Behavioral of shift_reg is
signal reg : std_logic_vector(9 downto 0) := (others=>'1');
begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            if (clr='1') then
                reg<=(others=>'1');
            elsif (shift='1') then
                reg<=data_in & reg(9 downto 1);
            else NULL;
            end if;
        end if;
    end process;
    
    data_out<=reg(8 downto 1);
	 --test<=reg(8);

end Behavioral;

