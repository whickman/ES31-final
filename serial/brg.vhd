--Will Hickman
--ENGS 31 Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity brg is
    Port ( clk : in  STD_LOGIC;
           br_tick16 : out  STD_LOGIC);
end brg;

architecture Behavioral of brg is

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

