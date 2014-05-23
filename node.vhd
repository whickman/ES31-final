--Will Hickman
--ENGS 31

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity node is
    Port ( clk : in  STD_LOGIC;
           weight_in : in  STD_LOGIC_VECTOR (7 downto 0);
           in_ping_start: in  STD_LOGIC;
           in_ping_N,in_ping_E,in_ping_S,in_ping_W : in STD_LOGIC;
           reset : in STD_LOGIC;
           en : in STD_LOGIC;
           weight_out : out STD_LOGIC_VECTOR (7 downto 0);
           out_ping: out  STD_LOGIC;
           pinged_by : out  STD_LOGIC_VECTOR (1 downto 0));
end node;

architecture Behavioral of node is
signal counter : unsigned(7 downto 0) := (others=>'0');
signal pinged_by_current, pinged_by_next : STD_LOGIC_VECTOR(1 downto 0);
type state_type is (waiting, countdown, ping, done, the_end);
signal state, next_state : state_type :=waiting;
begin

    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
            pinged_by_current<=pinged_by_next;
        end if;
    end process;

    counter_process : process(clk)
    begin
        if rising_edge(clk) then
            if ((state=countdown) and (en='1')) then
                counter<=counter-"1";
            elsif (state=waiting) then
                counter<=unsigned(weight_in);
            else
                counter<=counter;
            end if;
        end if;
    end process;

    state_process : process(state,counter,pinged_by_current,
        in_ping_start,in_ping_N,in_ping_E,in_ping_S,in_ping_W,reset)
    begin

        out_ping<='0';
        next_state<=state;
        pinged_by_next<=pinged_by_current;

        case state is
            when waiting =>
                pinged_by_next<=(others=>'0');
                if (in_ping_start='1') then
                    next_state<=countdown;
                elsif (in_ping_N='1') then
                    next_state<=countdown;
                    pinged_by_next<="00";
                elsif (in_ping_E='1') then
                    next_state<=countdown;
                    pinged_by_next<="01";
                elsif (in_ping_S='1') then
                    next_state<=countdown;
                    pinged_by_next<="10";
                elsif (in_ping_W='1') then
                    next_state<=countdown;
                    pinged_by_next<="11";
                end if;
            when countdown =>
                if (reset='1') then
                    next_state<=waiting;
                elsif (counter=("00000000")) then
                    next_state<=ping;
                end if;
            when ping =>
                out_ping<='1';
                next_state<=done;
                if (reset='1') then
                    next_state<=waiting;
                end if;
            when done =>
                if (reset='1') then
                    next_state<=waiting;
                end if;
            when others =>
                next_state<=waiting;
        end case;
    end process;

    weight_out<=std_logic_vector(counter);
    pinged_by<=pinged_by_current;

end Behavioral;

