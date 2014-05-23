--Will Hickman
--ENGS 31 Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity double_flop_sync is
    Port ( async_in : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           async_out : out  STD_LOGIC);
end double_flop_sync;

architecture Behavioral of double_flop_sync is
signal val : std_logic_vector (1 downto 0) := (others=>'1');
begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            async_out<=val(1);
            val<=val(0) & async_in;
        end if;
    end process;

end Behavioral;

