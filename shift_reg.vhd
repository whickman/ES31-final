--Will Hickman
--ENGS 31 Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg is
    Port ( data_in : in  STD_LOGIC;
           shift : in  STD_LOGIC;
           clr : in  STD_LOGIC;
           clk : in  STD_LOGIC;
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

end Behavioral;

