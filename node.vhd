--Will Hickman
--ENGS 31

--The node or unit cell for the grid, it gets activated by a neighbor,
--then counts down its input weight before activating its neighbors

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
           ping_out : out  STD_LOGIC;
           pinged_by_out : out  STD_LOGIC_VECTOR (1 downto 0));
end node;

architecture Behavioral of node is

    --------------------REGULAR SIGNALS--------------------
    signal counter : unsigned(7 downto 0) := (others=>'0');
    signal pinged_by, next_pinged_by : STD_LOGIC_VECTOR(1 downto 0);

    --------------------STATE SIGNALS AND TYPE--------------------
    type state_type is (waiting, countdown, ping, done, the_end);
    signal state, next_state : state_type :=waiting;
begin

    --------------------NEXT-STATE ASSIGNMENT--------------------
    clocked_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
            pinged_by<=next_pinged_by;
        end if;
    end process;

    --------------------COUNTDOWN LOGIC--------------------
    counter_process : process(clk)
    begin
        if rising_edge(clk) then
            --Only countdown if in correct state and enabled by matrix
            if ((state=countdown) and (en='1')) then
                counter<=counter-"1";
            --In initial state set counter to default value
            elsif (state=waiting) then
                counter<=unsigned(weight_in);
            else
                counter<=counter;
            end if;
        end if;
    end process;

    --------------------NEXT-STATE LOGIC--------------------
    state_process : process(state,counter,pinged_by,
        in_ping_start,in_ping_N,in_ping_E,in_ping_S,in_ping_W,reset)
    begin

        ping_out<='0';
        next_state<=state;
        next_pinged_by<=pinged_by;

        case state is
            --Wait until pinged, keep track of where the ping comes from
            when waiting =>
                next_pinged_by<=(others=>'0');
                if (in_ping_start='1') then
                    next_state<=countdown;
                elsif (in_ping_N='1') then
                    next_state<=countdown;
                    next_pinged_by<="00";
                elsif (in_ping_E='1') then
                    next_state<=countdown;
                    next_pinged_by<="01";
                elsif (in_ping_S='1') then
                    next_state<=countdown;
                    next_pinged_by<="10";
                elsif (in_ping_W='1') then
                    next_state<=countdown;
                    next_pinged_by<="11";
                end if;

            --Countdown from initial value happens, leave if reset or finish countdown
            when countdown =>
                if (reset='1') then
                    next_state<=waiting;
                elsif (counter=("00000000")) then
                    next_state<=ping;
                end if;

            --Ping neighbors
            when ping =>
                ping_out<='1';
                next_state<=done;
                if (reset='1') then
                    next_state<=waiting;
                end if;

            --All done, only change state if reset
            when done =>
                if (reset='1') then
                    next_state<=waiting;
                end if;

            --Default the state
            when others =>
                next_state<=waiting;
        end case;
    end process;

    weight_out<=std_logic_vector(counter);
    pinged_by_out<=pinged_by;

end Behavioral;

