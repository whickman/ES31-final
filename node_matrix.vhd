--Will Hickman
--ENGS 31 Final Project

--------------------Node matrix, controls unit cells and performs backtrace--------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity node_matrix is
    Port ( clk : in  STD_LOGIC;
           disp_loc_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_tick : in STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           in_path : out STD_LOGIC;
           weight_out : out  STD_LOGIC_VECTOR (7 downto 0));
end node_matrix;

architecture Behavioral of node_matrix is

    --------------------COMPONENT DECLARATIONS--------------------
    component node 
        Port ( clk : in  STD_LOGIC;
               weight_in : in  STD_LOGIC_VECTOR (7 downto 0);
               in_ping_start: in  STD_LOGIC;
               in_ping_N, in_ping_E, in_ping_S, in_ping_W : in STD_LOGIC;
               reset : in  STD_LOGIC;
			   en : in STD_LOGIC;
               weight_out : out STD_LOGIC_VECTOR (7 downto 0);
               ping_out : out  STD_LOGIC;
               pinged_by_out : out  STD_LOGIC_VECTOR (1 downto 0));
    end component;

    component reg_8b
        Port ( clk : in  STD_LOGIC;
               data_in : in  STD_LOGIC_VECTOR (7 downto 0);
               clear : in STD_LOGIC;
               enable : in STD_LOGIC;
               data_out : out  STD_LOGIC_VECTOR (7 downto 0));
    end component;

    --------------------CONSTANTS--------------------
    constant comm_header : std_logic_vector(7 downto 0) := "01010111";
    constant comm_cell_w : std_logic_vector(7 downto 0) := "00000001";
    constant comm_beg_addr : std_logic_vector(7 downto 0) := "00000010";
    constant comm_end_addr : std_logic_vector(7 downto 0) := "00000011";
    constant comm_prog_beg : std_logic_vector(7 downto 0) := "00000100";
    constant comm_prog_end : std_logic_vector(7 downto 0) := "00000101";
    
    constant node_cdown_scale : integer := 3;--divides clock by 2^n for node countdowns

    --------------------TYPES AND SIGNALS--------------------
    type binary_array is array (0 to 255) of std_logic;
    type backtrace_array is array (0 to 255) of std_logic_vector(1 downto 0);
    type weight_array is array (0 to 255) of std_logic_vector(7 downto 0);

    type state_type is (waiting, command, re_w_addr, re_w_weight, 
    re_beg, re_end, start, finish);--For receiving commands
    type back_state_type is (waiting, get_pointer, set_loc, 
    go_N, go_E, go_S, go_W, done);--For backtrace

    signal pings, start_ping, path_back, next_path_back : binary_array;
    signal backtrace : backtrace_array;
    signal start_weights, next_start_weights, weights : weight_array;
    signal beg_loc_w, beg_loc_r, end_loc_w, end_loc_r, 
        path_loc_w, path_loc_r : unsigned(7 downto 0) := (others=>'0');
    signal path_vect_r, addr_r, addr_w, 
        beg_loc_vect, end_loc_vect : std_logic_vector(7 downto 0);
    signal pointer, next_pointer : std_logic_vector(1 downto 0);
    signal reset, stopped, next_stopped, pinged_end, 
        next_pinged_end, node_en, beg_loc_en, end_loc_en : std_logic := '0';
    signal disp_index, weight_index, btrace_index, beg_loc_index, end_loc_index : integer := 0;
    signal state, next_state : state_type := waiting;
    signal back_state, next_back_state : back_state_type := waiting;
	signal clk_div : unsigned(node_cdown_scale downto 0):=(others=>'0');

begin

    --------------------PORT MAPPING--------------------
    path_register : reg_8b--Stores the current backtrace location
    PORT MAP (
        clk, 
        std_logic_vector(path_loc_w), 
        '0', 
        '1', 
        path_vect_r);

    addr_register : reg_8b--Stores the current cell's location
    PORT MAP (
        clk, 
        addr_w, 
        '0', 
        '1', 
        addr_r);
    
    beg_loc_reg : reg_8b--Stores the beginning location
    PORT MAP (
        clk, 
        std_logic_vector(beg_loc_w), 
        '0', 
        '1', 
        beg_loc_vect);

    end_loc_reg : reg_8b--Stores the end location
    PORT MAP (
        clk, 
        std_logic_vector(end_loc_w), 
        '0', 
        '1', 
        end_loc_vect);

    --Generate statements--
    node_matrix_full:
        for I in 0 to 255 generate

            --non-edge nodes
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate main_nodes;

            --nodes in the top row
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate top_row_nodes;

            --nodes in the bottom row
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate bottow_row_nodes;

            --nodes in the left column
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate left_side_nodes;

            --nodes in the right column
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate right_side_nodes;

            --The node in the upper left corner
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate UL_corner_node;

            --The node in the upper right corner
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate UR_corner_node;

            --The node in the lower left corner
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate LL_corner_node;

            --The node in the lower right corner
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
				node_en, 
                weights(I), 
                pings(I), 
                backtrace(I));
            end generate LR_corner_node;

    end generate node_matrix_full;

    --The clock divider for enabling nodes
	clk_div_process : process (clk)
	begin
		if rising_edge(clk) then
			clk_div<=clk_div+"01";
		end if;
	end process;
	 
    --The node enabling process
	node_en_process : process(clk_div,stopped,pinged_end)
	begin
		node_en<='0';
        --Enable the nodes if overflow has occurred (the counter returned to zero)
        --and if the end hasn't been found yet
		if ((clk_div=to_unsigned(0, (node_cdown_scale+1)))
        and (stopped='0') and (pinged_end='0')) then
			node_en<='1';
		end if;
	end process;

    --State and register changing
    state_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
            back_state<=next_back_state;
            start_weights<=next_start_weights;
            pinged_end<=next_pinged_end;
            path_back<=next_path_back;
            pointer<=next_pointer;
            stopped<=next_stopped;
        end if;
    end process;

    --Next-state logic for receiving commands
    next_state_process : process(state, data_in, data_tick, addr_r, stopped,
        weight_index, start_weights, beg_loc_index, beg_loc_r, end_loc_r)
    begin
        reset<='0';
        start_ping<=(others=>'0');
        next_state<=state;
        next_start_weights<=start_weights;
        next_stopped<=stopped;
        addr_w<=addr_r;
        beg_loc_w<=beg_loc_r;
		end_loc_w<=end_loc_r;
        case state is
            --Go to the command state if we get a header
            when waiting =>
                if ((data_tick='1') and (data_in=comm_header)) then
                    next_state<=command;
                end if;
            --Determine the next state from the data packet
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
            --Set the address to write a weight to
            when re_w_addr =>
                if (data_tick='1') then
                    addr_w<=data_in;
                    next_state<=re_w_weight;
                end if;
            --Write a weight to the address set in the last state
            when re_w_weight =>
                if (data_tick='1') then
                    next_start_weights(weight_index)<=data_in;
                    next_state<=waiting;
                end if;
            --Set the beginning address
            when re_beg =>
                    --reset the nodes if we're receiving new data
					next_stopped<='0';
					if (stopped='1') then
						reset<='1';
					end if;
               if (data_tick='1') then
					beg_loc_w<=unsigned(data_in);
                    next_state<=waiting;
                end if;
            --Set the end address
            when re_end =>
                if (data_tick='1') then
					end_loc_w<=unsigned(data_in);
                    next_state<=waiting;
                end if;
            --Send the start ping
            when start =>
                start_ping(beg_loc_index)<='1';
                next_state<=waiting;
            --Stop the program
            when finish =>
                next_stopped<='1';
                next_state<=waiting;
            --Default to waiting
            when others =>
                next_state<=waiting;
        end case;
    end process;

    --Backtrace process
    backtrace_state_process : process(back_state, state, 
        path_loc_r, beg_loc_r, end_loc_r, path_back, reset, 
        pointer, btrace_index, backtrace, pinged_end)
    begin
        path_loc_w<=path_loc_r;
        next_path_back<=path_back;
        next_pointer<=pointer;
		next_back_state<=back_state;
        case back_state is
            when waiting =>
                --Default values to zero
                next_pointer<=(others=>'0');
                next_path_back<=(others=>'0');
                path_loc_w<=end_loc_r;--Set the first backtrace location to the end location
                --If the end location has been pinged start backtraces
                if (pinged_end='1') then
                    next_back_state<=get_pointer;
                end if;
            --Get the pointer to the triggering adjacent cell
            when get_pointer =>
                next_path_back(btrace_index)<='1';--Mark the current cell as in the path
                next_pointer<=backtrace(btrace_index);--Get the pointer
                next_back_state<=set_loc;--Go to setting the location
               
            --Set the location of the backtracer depending on the pointer
            when set_loc =>
                if (path_loc_r/=beg_loc_r) then
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
            --Set if pointer is north
            when go_N =>
                path_loc_w<=path_loc_r-"10000"; 
                next_back_state<=get_pointer;
            --Set if pointer is east
            when go_E =>
                path_loc_w<=path_loc_r+"00001";
                next_back_state<=get_pointer;
            --Set if pointer is south
            when go_S => 
                path_loc_w<=path_loc_r+"10000"; 
                next_back_state<=get_pointer;
            --Set if pointer is west
            when go_W =>
                path_loc_w<=path_loc_r-"00001";
                next_back_state<=get_pointer;
            --Wait until reset
            when done =>
                if (reset='1') then
                    next_back_state<=waiting;
                end if;
            --Default to waiting
            when others =>
                next_back_state<=waiting;
        end case;
    end process;
    
    --Send the weight values and whether the cell is in the path to vga_color
    comm_process : process(path_back, disp_index, weights)
    begin
		in_path<=path_back(disp_index);
		weight_out<=weights(disp_index);
    end process;

    --Checks if the end has been reached to start backtrace
    pinged_end_process : process(end_loc_index, pings, state, pinged_end, reset)
    begin
        next_pinged_end<='0';
        if (reset='1') then NULL;
		  elsif ((pings(end_loc_index)='1') or (pinged_end='1')) then
            next_pinged_end<='1';
        end if; 
    end process;

    --Various conversions for signals and outputs
    disp_index<=to_integer(unsigned(disp_loc_in));
    path_loc_r<=unsigned(path_vect_r);
    btrace_index<=to_integer(path_loc_r);
    weight_index<=to_integer(unsigned(addr_r));
    beg_loc_r<=unsigned(beg_loc_vect);
    end_loc_r<=unsigned(end_loc_vect);
	beg_loc_index<=to_integer(beg_loc_r);
    end_loc_index<=to_integer(end_loc_r);

end Behavioral;
