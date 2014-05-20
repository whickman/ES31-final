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
           data_tick : in STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           reset_in : in  STD_LOGIC;
           in_path : out STD_LOGIC;
           weight_out : out  STD_LOGIC_VECTOR (7 downto 0));
end node_matrix;

architecture Behavioral of node_matrix is

    component node 
        Port ( clk : in  STD_LOGIC;
               weight_in : in  STD_LOGIC_VECTOR (7 downto 0);
               in_ping_start: in  STD_LOGIC;
               in_ping_N,in_ping_E,in_ping_S,in_ping_W : in STD_LOGIC;
               reset : in  STD_LOGIC;
               weight_out : out STD_LOGIC_VECTOR (7 downto 0);
               out_ping: out  STD_LOGIC;
               pinged_by : out  STD_LOGIC_VECTOR (1 downto 0));
    end component;

    component reg_8b
        Port ( clk : in  STD_LOGIC;
               data_in : in  STD_LOGIC_VECTOR (7 downto 0);
               clear : in STD_LOGIC;
               enable : in STD_LOGIC;
               data_out : out  STD_LOGIC_VECTOR (7 downto 0));
    end component;

    constant comm_header : std_logic_vector(7 downto 0) := "01010111";
    constant comm_cell_w : std_logic_vector(7 downto 0) := "00000001";
    constant comm_beg_addr : std_logic_vector(7 downto 0) := "00000010";
    constant comm_end_addr : std_logic_vector(7 downto 0) := "00000011";
    constant comm_prog_beg : std_logic_vector(7 downto 0) := "00000100";
    constant comm_prog_end : std_logic_vector(7 downto 0) := "00000101";
    
    type binary_array is array (0 to 255) of std_logic;
    type backtrace_array is array (0 to 255) of std_logic_vector(1 downto 0);
    type weight_array is array (0 to 255) of std_logic_vector(7 downto 0);
    type state_type is (waiting,command,re_w_addr,re_w_weight,re_beg,re_end,start,finish,resetting);
    type back_state_type is (waiting,get_pointer,first_set_loc,set_loc,go_N,go_E,go_S,go_W,done);

    signal pings,start_ping,path_back: binary_array;
    signal backtrace : backtrace_array;
    signal start_weights,weights : weight_array;
    signal beg_loc,end_loc,
        path_loc_w,path_loc_r : unsigned(7 downto 0) := (others=>'0');
    signal path_vect_r,addr_r,addr_w : std_logic_vector(7 downto 0);
    signal pointer : std_logic_vector(1 downto 0);
    signal reset,reached_end,next_reached_end,pinged_end,next_pinged_end : std_logic := '0';
    signal disp_index,weight_index, btrace_index : integer := 0;
    signal state,next_state : state_type := waiting;
    signal back_state,next_back_state : back_state_type := waiting;

begin

    path_register : reg_8b
    PORT MAP (
        clk,
        std_logic_vector(path_loc_w),
        '0',
        '1',
        path_vect_r);

    addr_register : reg_8b
    PORT MAP (
        clk,
        addr_w,
        '0',
        '1',
        addr_r);


    node_matrix_full:
        for I in 0 to 255 generate

            main_nodes : if ((I>15) and (I<240) and 
            ((I rem 16)/=0) and ((I rem 16)/=15)) generate
                NX : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                pings(I-16),
                pings(I+1),
                pings(I+16),
                pings(I-1),
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate main_nodes;

            top_row_nodes : if ((I<15) and (I>0)) generate
                NTR : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                '0',
                pings(I+1),
                pings(I+16),
                pings(I-1),
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate top_row_nodes;

            bottow_row_nodes : if ((I<255) and (I>240)) generate
                NBR : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                pings(I-16),
                pings(I+1),
                '0',
                pings(I-1),
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate bottow_row_nodes;

        left_side_nodes : if (((I rem 16)=0) and (I/=0) and (I/=240)) generate
                NTR : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                pings(I-16),
                pings(I+1),
                pings(I+16),
                '0',
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate left_side_nodes;

        right_side_nodes : if (((I rem 16)=15) and (I/=15) and (I/=255)) generate
                NTR : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                pings(I-16),
                '0',
                pings(I+16),
                pings(I-1),
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate right_side_nodes;

            UL_corner_node : if (I=0) generate
                NC1 : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                '0',
                pings(I+1),
                pings(I+16),
                '0',
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate UL_corner_node;

            UR_corner_node : if (I=15) generate
                NC2 : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                '0',
                '0',
                pings(I+16),
                pings(I-1),
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate UR_corner_node;

            LL_corner_node : if (I=240) generate
                NC3 : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                pings(I-16),
                pings(I+1),
                '0',
                '0',
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate LL_corner_node;

            LR_corner_node : if (I=255) generate
                NC4 : node
                PORT MAP ( 
                clk, 
                start_weights(I),
                start_ping(I),
                pings(I-16),
                '0',
                '0',
                pings(I-1),
                reset,
                weights(I),
                pings(I),
                backtrace(I));
            end generate LR_corner_node;

    end generate node_matrix_full;

   
    state_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
            back_state<=next_back_state;
            reached_end<=next_reached_end;
            pinged_end<=next_pinged_end;
        end if;
    end process;

    next_state_process : process(state,data_in,data_tick,addr_r,weight_index,reset_in,beg_loc)
    begin
        reset<='0';
        start_ping<=(others=>'0');
        next_state<=state;
        addr_w<=addr_r;
        case state is
            when waiting =>
                if ((data_tick='1') and (data_in=comm_header)) then
                    next_state<=command;
                end if;
            when command =>
                if (data_tick='1') then
                    case data_in is
                        when comm_cell_w =>
                            next_state<=re_w_addr;
                        when comm_beg_addr =>
                            next_state<=re_beg;
                        when comm_end_addr =>
                            next_state<=re_end;
                        when comm_prog_beg =>
                            next_state<=start;
                        when comm_prog_end =>
                            next_state<=finish;
                        when others =>
                            next_state<=waiting;
                    end case;
                end if;
            when re_w_addr =>
                if (data_tick='1') then
                    addr_w<=data_in;
                    next_state<=re_w_weight;
                end if;
            when re_w_weight =>
                if (data_tick='1') then
                    start_weights(weight_index)<=data_in;
                    next_state<=waiting;
                end if;
            when re_beg =>
                if (data_tick='1') then
                    beg_loc<=unsigned(data_in);
                    next_state<=waiting;
                end if;
            when re_end =>
                if (data_tick='1') then
                    end_loc<=unsigned(data_in);
                    next_state<=waiting;
                end if;
            when start =>
                start_ping(to_integer(beg_loc))<='1';
                next_state<=waiting;
            when resetting =>
                reset<='1';
                next_state<=waiting;
            when others =>
                next_state<=waiting;
        end case;
        if (reset_in='1') then
            next_state<=resetting;
        end if;
    end process;


    comm_process : process(disp_loc_in,beg_loc,end_loc,path_back,disp_index,weights)
    begin
			in_path<=path_back(disp_index);
			weight_out<=weights(disp_index);
    end process;

    backtrace_state_process : process(back_state,state,
        reset_in,path_loc_r,beg_loc,end_loc,
        pointer,btrace_index,backtrace,pinged_end,reached_end)
    begin
        path_loc_w<=path_loc_r;
        next_back_state<=back_state;
        case back_state is
            when waiting =>
                pointer<=(others=>'0');
                path_back<=(others=>'0');
                path_loc_w<=end_loc;
                if (pinged_end='1') then
                    next_back_state<=get_pointer;
                end if;
            when get_pointer =>
                path_back(btrace_index)<='1';
                pointer<=backtrace(btrace_index);
                next_back_state<=set_loc;
                if (reset_in='1') then
                    next_back_state<=waiting;
                elsif (path_loc_r=end_loc) then
                    next_back_state<=first_set_loc;
                end if;
            when first_set_loc =>
                if (reset_in='1') then
                    next_back_state<=waiting;
                elsif (beg_loc/=end_loc) then
                    next_back_state<=get_pointer;
                    case pointer is
                        when "00" =>
                            next_back_state<=go_N; 
                        when "01" =>
                            next_back_state<=go_E;
                        when "10" =>
                            next_back_state<=go_S;
                        when "11" =>
                            next_back_state<=go_W;
                        when others => NULL;
                    end case;                
                else
                    next_back_state<=done;
                end if;

            when set_loc =>
                if (reset_in='1') then
                    next_back_state<=waiting;
                elsif (path_loc_r/=beg_loc) then
                    next_back_state<=get_pointer;
                    case pointer is
                        when "00" =>
                            next_back_state<=go_N; 
                        when "01" =>
                            next_back_state<=go_E;
                        when "10" =>
                            next_back_state<=go_S;
                        when "11" =>
                            next_back_state<=go_W;
                        when others => NULL;
                    end case;                
                else
                    next_back_state<=done;
                end if;
            when go_N =>
                path_loc_w<=path_loc_r-"10000"; 
                next_back_state<=get_pointer;
            when go_E =>
                path_loc_w<=path_loc_r+"00001";
                next_back_state<=get_pointer;
            when go_S => 
                path_loc_w<=path_loc_r+"10000"; 
                next_back_state<=get_pointer;
            when go_W =>
                path_loc_w<=path_loc_r-"00001";
                next_back_state<=get_pointer;
            when done =>
                if (reset_in='1') then
                    next_back_state<=waiting;
                end if;
            when others =>
                next_back_state<=waiting;
        end case;
    end process;

    btrace_finished_process : process(beg_loc,pings,state,reached_end)
    begin
        next_reached_end<='0';
        if ((pings(to_integer(beg_loc))='1') or (reached_end='1')) then
            next_reached_end<='1';
        end if; 
    end process;

    pinged_end_process : process(end_loc,pings,state,pinged_end)
    begin
        next_pinged_end<='0';
        if ((pings(to_integer(end_loc))='1') or (pinged_end='1')) then
            next_pinged_end<='1';
        end if; 
    end process;


	 disp_index<=to_integer(unsigned(disp_loc_in));
    path_loc_r<=unsigned(path_vect_r);
    btrace_index<=to_integer(path_loc_r);
    weight_index<=to_integer(unsigned(addr_r));


end Behavioral;

