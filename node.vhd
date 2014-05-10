----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:39:14 05/09/2014 
-- Design Name: 
-- Module Name:    node - Behavioral 
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

entity node is
    Port ( clk : in  STD_LOGIC;
           weight : in  STD_LOGIC_VECTOR (7 downto 0);
           in_ping_start: in  STD_LOGIC;
           in_ping_N,in_ping_E,in_ping_S,in_ping_W : in  STD_LOGIC;
           is_end: in  STD_LOGIC;
           out_ping_N,out_ping_E,out_ping_S,out_ping_W: out  STD_LOGIC;
           pinged_by : out  STD_LOGIC_VECTOR (1 downto 0);
           end_signal : out STD_LOGIC);
end node;

architecture Behavioral of node is
signal enabled : std_logic := '0';
signal counter : integer := 0;
begin


    en_process(ping_start,ping_N,ping_E,ping_S,ping_W)
    begin
        enabled<='0';
        if ((ping_start='1') or (ping_N='1') or 
        (ping_E='1') or (ping_S='1') or (ping_W='1')) then
            enabled<='1';
        end if;
    end process;

end Behavioral;

