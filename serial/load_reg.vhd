--Will Hickman
--ENGS 31 Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity load_reg is
    Port ( data_in: in  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           load : in  STD_LOGIC;
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

end Behavioral;

