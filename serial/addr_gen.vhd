----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:41:32 05/08/2014 
-- Design Name: 
-- Module Name:    addr_gen - Behavioral 
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

entity addr_gen is
    Port ( clk : in STD_LOGIC;
			  incw : in  STD_LOGIC;
			  incr : in  STD_LOGIC;
           decr : in  STD_LOGIC;
			  revr : in STD_LOGIC;
			  eq : out STD_LOGIC;
           addr : out  STD_LOGIC_VECTOR (4 downto 0);
           addw : out  STD_LOGIC_VECTOR (4 downto 0));
end addr_gen;

architecture Behavioral of addr_gen is
    signal addws,addrs,swap : unsigned(4 downto 0) := (others=>'0');
begin

clocked_process : process(clk)
begin
	if (rising_edge(clk)) then
		
		if (incw='1') then
			addws<=addws+"00001";
		elsif (incr='1') then
			addrs<=addrs+"00001";
		elsif (decr='1') then
			addrs<=addrs-"00001";
		elsif (revr='1') then
			addrs<=addws-"00001";
			addws<=addrs;
		end if;
	end if;
end process;

eq_process : process(addrs,addws)
begin
		eq<='0';
		if (addrs=addws) then
			 eq<='1';
		end if;
	end process;
	
addr<=std_logic_vector(addrs);
addw<=std_logic_vector(addws);

end Behavioral;

