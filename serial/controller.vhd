--Will Hickman
--ENGS 31 Final Project

--------------------SERIAL RECEIVER CONTROLLER--------------------
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

    signal tick_counter, counter, last_shift,next_last_shift : integer := 0;
    signal last_br : std_logic := '0';

    type state_type is (waiting,data,shifting,loading,done);
    signal state, next_state : state_type := waiting;

begin

    --Change state and register on the clock
    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
			last_shift<=next_last_shift;
        end if;
    end process;

    --Next-state logic
    state_logic : process(state,data_in,counter,last_shift)
    begin
        clr<='0';
        load<='0';
        rx_done_tick<='0';
        shift<='0';
		next_last_shift<=last_shift;
		next_state<=state;
        case (state) is
            when waiting =>
                --If the start tick is received, start receiving the byte
                if (data_in='0') then
                    clr<='1';
                    next_last_shift<=counter;
                    next_state<=data;
                end if;
            when data =>
                --If we've reached the end of the byte, signal loading
                if ((counter>=10) and (data_in='1')) then
                    next_state<=loading;
                    next_last_shift<=0;
                --Otherwise if we've counted to 16, shift the bit in
                elsif (last_shift /= counter) then
                    next_last_shift<=counter;
                    next_state<=shifting;
                end if;
            --Signal the shift when shifting
            when shifting =>      
                shift<='1';
                next_state<=data;
            --Signal the load when loading
            when loading =>
                load<='1';
                next_state<=done;
            --Send the done tick and return to waiting
            when done =>
                rx_done_tick<='1';
                next_state<=waiting;
            when others => 
				next_state<=waiting;
        end case;
    end process;

    --Count the baudrate ticks to determine when shifting and things happen
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

