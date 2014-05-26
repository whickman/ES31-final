--Will Hickman
--ENGS 31 Final Project

--A general, 8-bit register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

