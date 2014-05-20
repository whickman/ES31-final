----------------------------------------------------------------------------------
-- Company:         ENGS 31 
-- Engineer:        Will Hickman
-- 
-- Create Date:    20:02:59 05/02/2014 
-- Design Name: 
-- Module Name:    mem_controller - Behavioral 
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

entity mem_controller is
    Port ( clk : in  STD_LOGIC;
           rx_done_tick : in  STD_LOGIC;
           empty_switch : in  STD_LOGIC;
           reverse_switch : in  STD_LOGIC;
           tx_done : in STD_LOGIC;
			  eq : in STD_LOGIC;
           tx_start_tick : out  STD_LOGIC;
           output_selector : out  STD_LOGIC;
           incw : out STD_LOGIC;
			  incr : out STD_LOGIC;
			  decr : out STD_LOGIC;
			  revr : out STD_LOGIC;
           write_en : out  STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR(1 downto 0));
end mem_controller;

architecture Behavioral of mem_controller is

    --Signal declarations
    type stateType is (empty, writing, trans_w, inc_w, waiting, full, rev_reading, reading, trans_r, change_r, dec_r, inc_r);
    signal state,nextState : stateType := empty;
    
begin

    --Assign the next state and check for equality of addresses
    --(Combines two blocks from the lab's block diagram)
    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=nextState;
        end if;
    end process;

    --Next-state logic
    state_process : process(state,rx_done_tick,tx_done,empty_switch,reverse_switch,eq)
    begin
        --Default the outputs to low and the next state to the current state
        tx_start_tick<='0';
        output_selector<='0';
        write_en<='0';
        LED<=(others=>'0');
        nextState<=state;
		  incw<='0';
		  incr<='0';
		  decr<='0';
		  revr<='0';

        case state is
            --If empty, transition to writing when there's an input signal
            when empty =>
                LED(1)<='1';
                if (rx_done_tick='1') then
                    nextState<=writing;
                end if;
            --When writing, echo the input and enable writng and move on to the next phase
            when writing =>
                tx_start_tick<='1';
                write_en<='1';
                nextState<=inc_w;
            --Then increment the address and move to the next phase
            when inc_w =>
                incw<='1';
                nextState<=trans_w;
            --If the read address and write address are equal go to full state
            --Otherwise, go to the waiting state
            when trans_w =>
                nextState<=waiting;
                if (eq='1') then
                    nextState<=full;
                end if;
            --If the empty switch is pressed, go to the reading state (also set the address to the last value written if we're reading in reverse)
            --Otherwise if we get an input, go to the writing state
            when waiting =>
                if (empty_switch='1') then
                    nextState<=reading;
                    if (reverse_switch='1') then
                        nextState<=rev_reading;
                    end if;
                elsif (rx_done_tick='1') then
                    nextState<=writing;
                end if;
            --Wait in the full state until someone presses the empty switch, do the same thing with the reading address as in the waiting state
            when full =>
                LED(0)<='1';
                if (empty_switch='1') then
                    nextState<=reading;
                    if (reverse_switch='1') then
                        nextState<=rev_reading;
                    end if;
                end if;
				when rev_reading =>
					revr<='1';
					nextState<=reading;
            --Send the output start tick and select the memory output then transition to the next state
            when reading =>
                tx_start_tick<='1';
                output_selector<='1';
                nextstate<=change_r;
            --Increment or decrement the read address
            when change_r =>
				   output_selector<='1';
                if (tx_done='1') then
						 if ((eq='1') and (reverse_switch='1')) then
							  nextState<=empty;
						 elsif (reverse_switch='1') then
                       nextState<=dec_r;
                   else
                       nextState<=inc_r;
                   end if;
                end if;
				when inc_r =>
				   output_selector<='1';
					incr<='1';
					nextState<=trans_r;
				when dec_r =>
				   output_selector<='1';
					decr<='1';
					nextState<=trans_r;
            --transition states
            when trans_r =>
				   output_selector<='1';
               nextState<=reading;
               if ((eq='1') and (reverse_switch='0')) then
                   nextState<=empty;
               end if;
				when others =>
					nextState <= empty;
        end case;
    end process;

end Behavioral;

