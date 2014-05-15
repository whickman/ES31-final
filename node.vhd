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
           in_ping_start_end: in  STD_LOGIC;
           in_ping_N,in_ping_E,in_ping_S,in_ping_W : in STD_LOGIC;
           in_bping_N,in_bping_E,in_bping_S,in_bping_W : in STD_LOGIC;
           reset : in STD_LOGIC;
           out_ping : out  STD_LOGIC;
           out_bping : out STD_LOGIC;
           pinged_by_out : out  STD_LOGIC_VECTOR (1 downto 0));
end node;

architecture Behavioral of node is
signal counter : integer := 0;
signal is_start : std_logic :='0';
signal pinged_by : std_logic_vector(1 downto 0);
type state_type is (waiting, countdown, ping, done, back_ping, the_end);
signal state, next_state : state_type :=waiting;
begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
        end if;
    end process;

    counter_process : process(clk)
    begin
        if rising_edge(clk) then
            if (state=countdown) then
                counter<=counter-1;
            else
                counter<=to_integer(unsigned(weight));
            end if;
        end if;
    end process;

    state_process : process(state,counter,in_ping_start_end,
        in_ping_N,in_ping_E,in_ping_S,in_ping_W,
        in_bping_N,in_bping_E,in_bping_S,in_bping_W,
        reset,is_start)
    begin

        out_ping<='0';
        next_state<=state;

        case state is
            when waiting =>
                is_start<='0';
                out_bping<='0';
                pinged_by<=(others=>'0');
                if (in_ping_start_end='1') then
                    next_state<=countdown;
                    is_start<='1';
                elsif (in_ping_N='1') then
                    next_state<=countdown;
                    pinged_by<="00";
                elsif (in_ping_E='1') then
                    next_state<=countdown;
                    pinged_by<="01";
                elsif (in_ping_S='1') then
                    next_state<=countdown;
                    pinged_by<="10";
                elsif (in_ping_W='1') then
                    next_state<=countdown;
                    pinged_by<="11";
                end if;
            when countdown =>
                if (reset='1') then
                    next_state<=waiting;
                elsif (counter<=0) then
                    next_state<=ping;
                end if;
            when ping =>
                out_ping<='1';
                next_state<=done;
                if (reset='1') then
                    next_state<=waiting;
                end if;
            when back_ping =>
                out_bping<='1';
                 next_state<=done;
                if (reset='1') then
                    next_state<=waiting;
                end if;
            when done =>
                if (reset='1') then
                    next_state<=waiting;
                elsif (is_start='1') then NULL;
                elsif (in_ping_start_end='1') then
                    next_state<=back_ping;
                elsif (in_bping_N='1') then
                    next_state<=back_ping;
                elsif (in_bping_E='1') then
                    next_state<=back_ping;
                elsif (in_bping_S='1') then
                    next_state<=back_ping;
                elsif (in_bping_W='1') then
                    next_state<=back_ping;
                end if;
            when others =>
                next_state<=waiting;
        end case;

    end process;

    pinged_by_out<=pinged_by;

end Behavioral;

