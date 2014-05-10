----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:36:44 04/27/2014 
-- Design Name: 
-- Module Name:    brg - Behavioral 
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

entity brg is
    Port ( clk : in  STD_LOGIC;
           br_tick16 : out  STD_LOGIC);
end brg;

architecture Behavioral of brg is

--constant BAUDRATE : integer := 9600;
constant BAUDRATE : integer := 115200;
constant CLOCKSPEED : integer := 25000000;
constant M : integer := (CLOCKSPEED/(BAUDRATE*16)-1);
signal counter : integer := 0;
signal tick : std_logic := '0';

begin

    clock_process : process(clk)
    begin
        if rising_edge(clk) then
            counter<=counter+1;
            if (counter=M) then
                tick<='1';
            elsif (tick='1') then
                tick<='0';
                counter<=0;
            else NULL;
            end if;
        end if;
    end process;

    br_tick16<=tick;

end Behavioral;

