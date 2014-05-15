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
           row_in : in  STD_LOGIC_VECTOR (3 downto 0);
           col_in : in  STD_LOGIC_VECTOR (3 downto 0);
           shift_state : in STD_LOGIC_VECTOR (1 downto 0);
           data_tick : in STD_LOGIC;
           serial_row_in : in  STD_LOGIC_VECTOR (3 downto 0);
           serial_col_in : in  STD_LOGIC_VECTOR (3 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           reset_in : in  STD_LOGIC;
           in_path : out STD_LOGIC_VECTOR(1 downto 0);
           weight_out : out  STD_LOGIC_VECTOR (7 downto 0));
end node_matrix;

architecture Behavioral of node_matrix is

    component node 
        Port ( clk : in  STD_LOGIC;
               weight : in  STD_LOGIC_VECTOR (7 downto 0);
               in_ping_start: in  STD_LOGIC;
               in_ping_N,in_ping_E,in_ping_S,in_ping_W : in STD_LOGIC;
               reset : in  STD_LOGIC;
               out_ping: out  STD_LOGIC;
               pinged_by : out  STD_LOGIC_VECTOR (1 downto 0));
    end component;

    component path_reg
        Port ( clk : in  STD_LOGIC;
               data_one_in : in  STD_LOGIC_VECTOR (3 downto 0);
               data_two_in : in  STD_LOGIC_VECTOR (3 downto 0);
               data_one_out : out  STD_LOGIC_VECTOR (3 downto 0);
               data_two_out : out  STD_LOGIC_VECTOR (3 downto 0));
    end component;

    type binary_array is array (0 to 15) of std_logic_vector(15 downto 0);
    type backtrace_col is array (0 to 15) of std_logic_vector(1 downto 0);
    type backtrace_array is array (0 to 15) of backtrace_col;
    type weight_col is array (0 to 15) of std_logic_vector(7 downto 0);
    type weight_array is array (0 to 15) of weight_col;
    type state_type is (waiting,receiving,re_beg,re_end,loaded,running,done,resetting);
    type back_state_type is (waiting,get_pointer,set_loc,done);

    signal pings,start_ping,path_back: binary_array;
    signal backtrace : backtrace_array;
    signal weights : weight_array;
    signal beg_loc,end_loc : unsigned(7 downto 0) := (others=>'0');
    signal path_col_r,path_row_r,path_col_w,path_row_w : unsigned(3 downto 0) := (others=>'0');
    signal path_vect_col, path_vect_row : std_logic_vector(3 downto 0);
    signal pointer : std_logic_vector(1 downto 0);
    signal back_temp_col,back_temp_row : integer;
    signal reset : std_logic := '0';
    signal col,row,serial_col,serial_row : integer;
    signal state,next_state : state_type;
    signal back_state,next_back_state : back_state_type;

begin

    path_register : path_reg
    PORT MAP (
        clk,
        std_logic_vector(path_col_w),
        std_logic_vector(path_row_w),
        path_vect_col,
        path_vect_row);

    node_matrix_full:
    for I in 0 to 255 generate

        main_nodes : if ((I>15) and (I<240) and 
        ((I rem 16)/=0) and ((I rem 16)/=15)) generate
            NX : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I/16)),
            start_ping((I rem 16))((I/16)),
            pings((I rem 16))((I/16)-1),
            pings((I rem 16)+1)((I/16)),
            pings((I rem 16))((I/16)+1),
            pings((I rem 16)-1)((I/16)),
            reset,
            pings((I rem 16))((I/16)),
            backtrace((I rem 16))((I/16)));
        end generate main_nodes;

        top_row_nodes : if ((I<15) and (I>1)) generate
            NTR : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))(0),
            start_ping((I rem 16))(0),
            '0',
            pings((I rem 16)+1)(0),
            pings((I rem 16))(1),
            pings((I rem 16)-1)((I/16)),
            reset,
            pings((I rem 16))(0),
            backtrace((I rem 16))(0));
        end generate top_row_nodes;

        bottow_row_nodes : if ((I<255) and (I>240)) generate
            NBR : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))(15),
            start_ping((I rem 16))(15),
            pings((I rem 16))(14),
            pings((I rem 16)+1)(15),
            '0',
            pings((I rem 16)-1)(15),
            reset,
            pings((I rem 16))(15),
            backtrace((I rem 16))(15));
        end generate bottow_row_nodes;

        UL_corner_node : if (I=0) generate
            NC1 : node
            PORT MAP ( 
            clk, 
            weights(0)(0),
            start_ping(0)(0),
            '0',
            pings(1)(0),
            pings(0)(0),
            '0',
            reset,
            pings(0)(0),
            backtrace(0)(0));
        end generate UL_corner_node;

        UR_corner_node : if (I=15) generate
            NC2 : node
            PORT MAP ( 
            clk, 
            weights(15)(0),
            start_ping(15)(0),
            '0',
            '0',
            pings(15)(1),
            pings(14)(15),
            reset,
            pings(15)(0),
            backtrace(15)(0));
        end generate UR_corner_node;

        LL_corner_node : if (I=240) generate
            NC3 : node
            PORT MAP ( 
            clk, 
            weights(0)(15),
            start_ping(0)(15),
            pings(0)(14),
            pings(1)(15),
            '0',
            '0',
            reset,
            pings(0)(15),
            backtrace(0)(15));
        end generate LL_corner_node;

        LR_corner_node : if (I=255) generate
            NC4 : node
            PORT MAP ( 
            clk, 
            weights(15)(15),
            start_ping(15)(15),
            pings(15)(14),
            '0',
            '0',
            pings(14)(15),
            reset,
            pings(15)(15),
            backtrace(15)(15));
        end generate LR_corner_node;

    end generate node_matrix_full;

    state_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
            back_state<=next_back_state;
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
            serial_col<=to_integer(unsigned(serial_col_in));
            serial_row<=to_integer(unsigned(serial_row_in));
            col<=to_integer(unsigned(col_in));
            row<=to_integer(unsigned(row_in));
            if (data_tick='1') then
                case state is
                    when receiving =>
                        weights(serial_col)(serial_row)<=data_in;
                    when re_beg =>
                        beg_loc<=unsigned(data_in);
                    when re_end =>
                        end_loc<=unsigned(data_in);
                    when loaded =>
                        weight_out<=weights(col)(row);
                    when done =>
                        weight_out<=weights(col)(row);
                        if ((col_in=(std_logic_vector(beg_loc(3 downto 0)))) and 
                        (row_in=(std_logic_vector(beg_loc(7 downto 4))))) then
                            in_path<="01";
                        elsif ((col_in=(std_logic_vector(end_loc(3 downto 0)))) and 
                        (row_in=(std_logic_vector(end_loc(7 downto 4))))) then
                            in_path<="11";
                        elsif (path_back(col)(row)='1') then
                            in_path<="10";
                        end if;
                    when others => NULL;
                end case;
            end if;
        end if;
    end process;

    start_process : process (state,beg_loc)
    begin
        start_ping<=(others=>(others=>'0'));
        if (state=running) then
            start_ping(to_integer(beg_loc(3 downto 0)))(to_integer(beg_loc(7 downto 4)))<='1';
        end if;
    end process;

    backtrace_state_process : process(back_state,state,reset_in,path_col_r,path_row_r,end_loc,backtrace)
    begin
        back_temp_col<=to_integer(path_col_r);
        back_temp_row<=to_integer(path_row_r);
        case back_state is
            when waiting =>
                pointer<=(others=>'0');
                path_back<=(others=>(others=>'0'));
                path_col_w<=end_loc(3 downto 0);
                path_row_w<=end_loc(7 downto 4);
                if (state=done) then
                    next_back_state<=get_pointer;
                end if;
            when get_pointer =>
                path_back(back_temp_col)(back_temp_row)<='1';
                pointer<=backtrace(back_temp_col)(back_temp_row);
                next_back_state<=set_loc;
                if (reset_in='1') then
                    next_back_state<=waiting;
                end if;
            when set_loc =>
                if (reset_in='1') then
                    next_back_state<=waiting;
                elsif ((path_col_r/=end_loc(3 downto 0)) or 
                (path_row_r/=end_loc(7 downto 4))) then
                    case pointer is
                        when "00" =>
                            path_row_w<=path_row_r-"1";
                            path_col_w<=path_col_r;
                        when "01" =>
                            path_row_w<=path_row_r;
                            path_col_w<=path_col_r+"1";
                        when "10" =>
                            path_row_w<=path_row_r+"1";
                            path_col_w<=path_col_r;
                        when "11" =>
                            path_row_w<=path_row_r;
                            path_col_w<=path_col_r-"1";
                        when others => NULL;
                    end case;
                    next_back_state<=get_pointer;
                else
                    next_back_state<=done;
                end if;
            when done =>
                if (reset_in='1') then
                    next_back_state<=waiting;
                end if;
            when others =>
                    next_back_state<=waiting;
        end case;
    end process;

    path_col_r<=unsigned(path_vect_col);
    path_row_r<=unsigned(path_vect_row);
    
end Behavioral;

