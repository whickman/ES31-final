--Will Hickman
--ENGS 31 Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
    Port ( br_tick16 : in  STD_LOGIC;
           data_in : in  STD_LOGIC;
           clk : in STD_LOGIC;
           shift : out STD_LOGIC;
           clr : out  STD_LOGIC;
           load : out  STD_LOGIC;
           rx_done_tick : out  STD_LOGIC);
end controller;

architecture Behavioral of controller is

    signal tick_counter, counter, lastShift,next_lastShift : integer := 0;
    signal last_br : std_logic := '0';

    type state_type is (waiting,data,shifting,loading,done);
    signal state, nextState : state_type := waiting;

begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=nextState;
			lastShift<=next_lastShift;
        end if;
    end process;

    state_logic : process(state,data_in,counter,lastShift)
    begin
        clr<='0';
        load<='0';
        rx_done_tick<='0';
        shift<='0';
		next_lastShift<=lastShift;
		nextState<=state;
        case (state) is
            when waiting =>
                if (data_in='0') then
                    clr<='1';
                    nextState<=data;
                end if;
            when data =>
                if (counter>10) then
                    nextState<=loading;
                    next_lastShift<=0;
                elsif (lastShift /= counter) then
                    next_lastShift<=counter;
                    nextState<=shifting;
                end if;
            when shifting =>      
                shift<='1';
                nextState<=data;
            when loading =>
                load<='1';
                nextState<=done;
            when done =>
                rx_done_tick<='1';
                nextState<=waiting;
            when others => 
				nextState<=waiting;
        end case;
    end process;

    count_process : process(clk)
    begin
		if rising_edge(clk) then
			  if ((br_tick16 = '1') and (last_br = '0')) then
					if (state=data) then
						 tick_counter<=tick_counter+1;
						 if ((tick_counter=7) and (counter=0)) then
							  counter<=1;
							  tick_counter<=0;
						 elsif (tick_counter=15) then
							  counter<=counter+1;
							  tick_counter<=0;
						 end if;
					else
						 counter<=0;
						 tick_counter<=0;
					end if;
			  end if;
			  last_br<=br_tick16;
		 end if;
    end process;

end Behavioral;

