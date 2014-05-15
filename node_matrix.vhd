----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:00:15 05/10/2014 
-- Design Name: 
-- Module Name:    node_matrix - Behavioral 
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

entity node_matrix is
    Port ( clk : in  STD_LOGIC;
           disp_loc_in : in  STD_LOGIC_VECTOR (7 downto 0);
           shift_state : in STD_LOGIC_VECTOR (1 downto 0);
           data_tick : in STD_LOGIC;
           serial_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           reset_in : in  STD_LOGIC;
           in_path : out STD_LOGIC_VECTOR(1 downto 0);
           weight_out : out  STD_LOGIC_VECTOR (7 downto 0));
end node_matrix;

architecture Behavioral of node_matrix is

    component node 
        Port ( clk : in  STD_LOGIC;
               weight : in  STD_LOGIC_VECTOR (7 downto 0);
               in_ping_start_end : in  STD_LOGIC;
               in_ping_N,in_ping_E,in_ping_S,in_ping_W : in STD_LOGIC;
               in_bping_N,in_bping_E,in_bping_S,in_bping_W : in STD_LOGIC;
               reset : in  STD_LOGIC;
               out_ping: out  STD_LOGIC;
               out_bping: out STD_LOGIC);
    end component;

    type binary_array is array (0 to 255) of std_logic;
    type backtrace_array is array (0 to 255) of std_logic_vector(1 downto 0);
    type weight_array is array (0 to 255) of std_logic_vector(7 downto 0);
    type state_type is (waiting,receiving,re_beg,re_end,loaded,running,done,resetting);

    signal pings,bpings,start_end_ping : binary_array;
    signal backtrace : backtrace_array;
    signal weights : weight_array;
    signal beg_loc,end_loc : unsigned(7 downto 0) := (others=>'0');
    signal reset : std_logic := '0';
    signal ind,serial_ind,disp_ind : integer;
    signal state,next_state : state_type;

begin

    node_matrix_full:
    for I in 0 to 255 generate

        main_nodes : if ((I>15) and (I<240) and 
        ((I rem 16)/=0) and ((I rem 16)/=15)) generate
            NX : node
            PORT MAP ( 
            clk, 
            weights(I),
            start_end_ping(I),
            pings(I-16),
            pings(I+1),
            pings(I+16),
            pings(I-1),
            bpings(I-16),
            bpings(I+1),
            bpings(I+16),
            bpings(I-1),
            reset,
            pings(I),
            bpings(I));
        end generate main_nodes;

        top_row_nodes : if ((I<15) and (I>1)) generate
            NTR : node
            PORT MAP ( 
            clk, 
            weights(I),
            start_end_ping(I),
            '0',
            pings(I+1),
            pings(I+16),
            pings(I-1),
            '0',
            bpings(I+1),
            bpings(I+16),
            bpings(I-1),
            reset,
            pings(I),
            bpings(I));
        end generate top_row_nodes;

        bottow_row_nodes : if ((I<255) and (I>240)) generate
            NBR : node
            PORT MAP ( 
            clk, 
            weights(I),
            start_end_ping(I),
            pings(I-16),
            pings(I+1),
            '0',
            pings(I-1),
            bpings(I-16),
            bpings(I+1),
            '0',
            bpings(I-1),
            reset,
            pings(I),
            bpings(I));
        end generate bottow_row_nodes;

        UL_corner_node : if (I=0) generate
            NC1 : node
            PORT MAP ( 
            clk, 
            weights(I),
            start_end_ping(I),
            '0',
            pings(I+1),
            pings(I+16),
            '0',
            '0',
            bpings(I+1),
            bpings(I+16),
            '0',
            reset,
            pings(I),
            bpings(I));
        end generate UL_corner_node;

        UR_corner_node : if (I=15) generate
            NC2 : node
            PORT MAP ( 
            clk, 
            weights(I),
            start_end_ping(I),
            '0',
            '0',
            pings(I+16),
            pings(I-1),
            '0',
            '0',
            bpings(I+16),
            bpings(I-1),
            reset,
            pings(I),
            bpings(I));
        end generate UR_corner_node;

        LL_corner_node : if (I=240) generate
            NC3 : node
            PORT MAP ( 
            clk, 
            weights(I),
            start_end_ping(I),
            pings(I-16),
            pings(I+1),
            '0',
            '0',
            bpings(I-16),
            bpings(I+1),
            '0',
            '0',
            reset,
            pings(I),
            bpings(I));
        end generate LL_corner_node;

        LR_corner_node : if (I=255) generate
            NC4 : node
            PORT MAP ( 
            clk, 
            weights(I),
            start_end_ping(I),
            pings(I-16),
            '0',
            '0',
            pings(I-1),
            bpings(I-16),
            '0',
            '0',
            bpings(I-1),
            reset,
            pings(I),
            bpings(I));
        end generate LR_corner_node;

    end generate node_matrix_full;

    state_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
        end if;
    end process;

    next_state_process : process(state,shift_state,reset_in)
    begin
        reset<='0';
        next_state<=state;
        case state is
            when waiting =>
                if (shift_state="00") then
                    next_state<=receiving;
                elsif (shift_state="01") then
                    next_state<=re_beg;
                elsif (shift_state="10") then
                    next_state<=re_end;
                end if;
            when receiving =>
                if (reset_in='1') then
                    next_state<=resetting;
                elsif (shift_state="11") then
                    next_state<=loaded;
                elsif (shift_state="01") then
                    next_state<=re_beg;
                elsif (shift_state="10") then
                    next_state<=re_end;
                end if;
            when re_beg =>
                if (reset_in='1') then
                    next_state<=resetting;
                elsif (shift_state="11") then
                    next_state<=loaded;
                elsif (shift_state="00") then
                    next_state<=receiving;
                elsif (shift_state="10") then
                    next_state<=re_end;
                end if;
            when re_end =>
                if (reset_in='1') then
                    next_state<=resetting;
                elsif (shift_state="11") then
                    next_state<=loaded;
                elsif (shift_state="00") then
                    next_state<=receiving;
                elsif (shift_state="01") then
                    next_state<=re_beg;
                end if;
            when loaded =>
                if (reset_in='1') then
                    next_state<=resetting;
                elsif (shift_state="00") then
                    next_state<=running;
                end if;
            when running =>
                if (reset_in='1') then
                    next_state<=resetting;
                elsif (shift_state="01") then
                    next_state<=done;
                end if;
            when done =>
                if (reset_in='1') then
                    next_state<=resetting;
                end if;
            when resetting =>
                reset<='1';
                next_state<=waiting;
            when others =>
                next_state<=waiting;
        end case;
    end process;

    comm_process : process(clk)
    begin
        if rising_edge(clk) then
            weight_out<=(others=>'0');
            in_path<=(others=>'0');
            serial_ind<=to_integer(unsigned(serial_in));
            disp_ind<=to_integer(unsigned(disp_loc_in));
            if (data_tick='1') then
                case state is
                    when receiving =>
                        weights(serial_ind)<=data_in;
                    when re_beg =>
                        beg_loc<=unsigned(data_in);
                    when re_end =>
                        end_loc<=unsigned(data_in);
                    when loaded =>
                        weight_out<=weights(disp_ind);
                    when done =>
                        weight_out<=weights(disp_ind);
                        if (disp_ind=to_integer(beg_loc)) then
                            in_path<="01";
                        elsif (disp_ind=to_integer(end_loc)) then
                            in_path<="11";
                        elsif (bpings(disp_ind)='1') then
                            in_path<="10";
                        end if;
                    when others => NULL;
                end case;
            end if;
        end if;
    end process;

    start_end_process : process (state,beg_loc,end_loc)
    begin
        start_end_ping<=(others=>'0');
        if (state=running) then
            start_end_ping(to_integer(beg_loc))<='1';
        elsif (state=running) then
            start_end_ping(to_integer(end_loc))<='1';
        end if;
    end process;

        
end Behavioral;

