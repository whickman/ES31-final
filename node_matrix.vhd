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
           serial_data_start : in STD_LOGIC;
           serial_row_in : in  STD_LOGIC_VECTOR (3 downto 0);
           serial_col_in : in  STD_LOGIC_VECTOR (3 downto 0);
           weight_in : in  STD_LOGIC_VECTOR (7 downto 0);
           reset_in : in  STD_LOGIC;
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

    type ping_array is array (0 to 15) of std_logic_vector(15 downto 0);
    type backtrace_col is array (0 to 15) of std_logic_vector(1 downto 0);
    type backtrace_array is array (0 to 15) of backtrace_col;
    type weight_col is array (0 to 15) of std_logic_vector(7 downto 0);
    type weight_array is array (0 to 15) of weight_col;
    type state_type is (waiting,receiving,running,done);

    signal pings,start_ping: ping_array;
    signal backtrace : backtrace_array;
    signal weights : weight_array;
    signal I_vect : unsigned(7 downto 0) := (others=>'0');
    signal reset : std_logic := '0';
    signal col,row : integer;
    signal state,next_state : state_type;

begin

    node_matrix_full:
    for I in 0 to 255 generate

        main_nodes : if ((I>15) and (I<240) and 
        ((I rem 16)/=0) and ((I rem 16)/=15)) generate
            NX : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I mod 16)),
            start_ping((I rem 16))((I mod 16)),
            pings((I rem 16))((I mod 16)-1),
            pings((I rem 16)+1)((I mod 16)),
            pings((I rem 16))((I mod 16)+1),
            pings((I rem 16)-1)((I mod 16)),
            reset,
            pings((I rem 16))((I mod 16)),
            backtrace((I rem 16))((I mod 16)));
        end generate main_nodes;

        top_row_nodes : if ((I<15) and (I>1)) generate
            NTR : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I mod 16)),
            start_ping((I rem 16))((I mod 16)),
            '0',
            pings((I rem 16)+1)((I mod 16)),
            pings((I rem 16))((I mod 16)+1),
            pings((I rem 16)-1)((I mod 16)),
            reset,
            pings((I rem 16))((I mod 16)),
            backtrace((I rem 16))((I mod 16)));
        end generate top_row_nodes;

        bottow_row_nodes : if ((I<15) and (I>1)) generate
            NBR : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I mod 16)),
            start_ping((I rem 16))((I mod 16)),
            pings((I rem 16))((I mod 16)-1),
            pings((I rem 16)+1)((I mod 16)),
            '0',
            pings((I rem 16)-1)((I mod 16)),
            reset,
            pings((I rem 16))((I mod 16)),
            backtrace((I rem 16))((I mod 16)));
        end generate bottow_row_nodes;

        UL_corner_node : if (I=0) generate
            NC1 : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I mod 16)),
            start_ping((I rem 16))((I mod 16)),
            '0',
            pings((I rem 16)+1)((I mod 16)),
            pings((I rem 16))((I mod 16)+1),
            '0',
            reset,
            pings((I rem 16))((I mod 16)),
            backtrace((I rem 16))((I mod 16)));
        end generate UL_corner_node;

        --THESE ALL NEED TO BE FIXED!!
        UR_corner_node : if (I=15) generate
            NC2 : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I mod 16)),
            start_ping((I rem 16))((I mod 16)),
            '0',
            '0',
            pings((I rem 16))((I mod 16)+1),
            pings((I rem 16)-1)((I mod 16)),
            reset,
            pings((I rem 16))((I mod 16)),
            backtrace((I rem 16))((I mod 16)));
        end generate UR_corner_node;

        LL_corner_node : if (I=240) generate
            NC3 : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I mod 16)),
            start_ping((I rem 16))((I mod 16)),
            pings((I rem 16))((I mod 16)-1),
            pings((I rem 16)+1)((I mod 16)),
            '0',
            '0',
            reset,
            pings((I rem 16))((I mod 16)),
            backtrace((I rem 16))((I mod 16)));
        end generate LL_corner_node;

        LR_corner_node : if (I=255) generate
            NC4 : node
            PORT MAP ( 
            clk, 
            weights((I rem 16))((I mod 16)),
            start_ping((I rem 16))((I mod 16)),
            pings((I rem 16))((I mod 16)-1),
            '0',
            '0',
            pings((I rem 16)-1)((I mod 16)),
            reset,
            pings((I rem 16))((I mod 16)),
            backtrace((I rem 16))((I mod 16)));
        end generate LR_corner_node;

    end generate node_matrix_full;

    state_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
        end if;
    end process;


end Behavioral;

