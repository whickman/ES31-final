----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:07:38 05/17/2014 
-- Design Name: 
-- Module Name:    matrix_controller - Behavioral 
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

entity matrix_controller is
    Port ( clk : in  STD_LOGIC;
           rx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           rx_done_tick : in  STD_LOGIC;
           data_tick : out STD_LOGIC;
           mod_data : out  STD_LOGIC_VECTOR (7 downto 0);
           shift_state : out  STD_LOGIC_VECTOR (1 downto 0));
end matrix_controller;

architecture Behavioral of matrix_controller is
    constant header_val : std_logic_vector(7 downto 0) := "1010111";
    constant comm_cell_w : std_logic_vector(7 downto 0) := "00000001";
    constant comm_beg_addr : std_logic_vector(7 downto 0) := "00000010";
    constant comm_end_addr : std_logic_vector(7 downto 0) := "00000011";
    constant comm_prog_beg : std_logic_vector(7 downto 0) := "00000100";
    constant comm_prog_end : std_logic_vector(7 downto 0) := "00000101";
    type state_type is (waiting, header, command, 
    shift_rec, shift_beg, shift_end, shift_prog_beg, shift_prog_end, 
    addr, addr_send, cost, cost_send);
    signal state, next_state : state_type := waiting;
begin

    state_process : process(clk)
    begin
        if rising_edge(clk) then
            state<=next_state;
        end if;
    end process;

    state_logic : process(state,rx_done_tick)
    begin
        case state is
            when waiting =>
                if (rx_done_tick='1') then
                    next_state<=header;
                end if;
            when header =>
                if ((rx_done_tick='1') and (rx_data=header_val)) then
                    next_state<=command;
            when command =>
                if (rx_done_tick='1') then
                    case rx_data is
                        when comm_cell_w =>
                            next_state<=shift_rec;
                        when comm_beg_addr =>
                            next_state<=shift_beg;
                        when comm_end_addr =>
                            next_state<=shift_end;
                        when comm_prog_beg =>
                            next_state<=shift_prog_beg;
                        when comm_prog_end =>
                            next_state<=shift_prog_end;
                        when others =>
                            next_state<=waiting;
                    end case;
                end if;
            when comm_send =>

            when addr =>
            when cost =>
            when others =>
                next_state<=waiting;
        end case;
end Behavioral;

