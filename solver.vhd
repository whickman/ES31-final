----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:33:26 05/18/2014 
-- Design Name: 
-- Module Name:    solver - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity solver is
    Port ( clk_real : in  STD_LOGIC;
           TXD : in  STD_LOGIC;
			  RXD : out STD_LOGIC;
           red : out std_logic_vector(2 downto 0);
		     green : out std_logic_vector(2 downto 0);
		     blue : out std_logic_vector(1 downto 0); 
           hs,vs : out STD_LOGIC);
end solver;

architecture Behavioral of solver is

	component cbuff
		port
		 (-- Clock in ports
		  CLK_IN1           : in     std_logic;
		  -- Clock out ports
		  CLK_OUT1          : out    std_logic;
		  CLK_OUT2          : out    std_logic
		 );
	 end component;
	
    component brg 
        Port ( clk : in  STD_LOGIC;
           br_tick16 : out  STD_LOGIC);
    end component;

    component SerialRx
    Port ( Clk25 : in  STD_LOGIC;
           TXD : in  STD_LOGIC;
           br_tick16 : in  STD_LOGIC;
           rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_done_tick : out  STD_LOGIC);
    end component;
	 
	 component SerialTx
    Port ( Clk25 : in  STD_LOGIC;
           tx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           tx_start : in  STD_LOGIC;
           tx_tick16 : in  STD_LOGIC;			-- from BRG
           tx : out  STD_LOGIC;					-- to RS-232 port
           tx_done_tick : out  STD_LOGIC);
	end component;

    component node_matrix
    Port ( clk : in  STD_LOGIC;
           disp_loc_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_tick : in STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           reset_in : in  STD_LOGIC;
           in_path : out STD_LOGIC;
           weight_out : out  STD_LOGIC_VECTOR (7 downto 0));
    end component;

    component vga_color
	port(row,column	     : in INTEGER;
         cell_address    : out std_logic_vector(7 downto 0);
         cell_data       : in std_logic_vector(7 downto 0);
         color           : out std_logic_vector(7 downto 0));
    end component;
    
    component vga_controller
	port(clk_px			: in std_logic;
       clk_en        : in std_logic;
		  color			: in std_logic_vector(7 downto 0);
		  red				: out std_logic_vector(2 downto 0);
		  green			: out std_logic_vector(2 downto 0);
		  blue			: out std_logic_vector(1 downto 0);
		  hs,vs			: out std_logic;
		  row,column	: out INTEGER);
    end component;

    signal br_tick_16,rx_done_tick,reset,clk,slow_clk,in_path : std_logic;
    signal color,cell_address,rx_data,weight_in,weight_out : std_logic_vector(7 downto 0);
    signal row, col : integer;

begin

	 cb : cbuff
	 PORT MAP (
	 clk_real,
	 slow_clk,
	 clk);

    br_gen : brg
    PORT MAP (
    clk,
    br_tick_16);

    s_rx : SerialRx
    PORT MAP (
    clk,
    TXD,
    br_tick_16,
    rx_data,
    rx_done_tick);
	 
	 s_tx : SerialTx
	 PORT MAP (
	 clk,
	 rx_data,
	 rx_done_tick,
	 br_tick_16,
	 RXD,
	 open);

    nm : node_matrix
    PORT MAP (
    clk,
    cell_address,
    rx_done_tick,
    rx_data,
    reset,
    in_path,
    weight_in);

    v_col : vga_color
    PORT MAP (
    row,
    col,
    cell_address,
	 weight_out,
    color);

    v_cont : vga_controller
    PORT MAP (
    slow_clk,
    '1',
    color,
    red,
    green,
    blue,
    hs,
    vs,
    row,
    col);
		
    weight_process : process(weight_in,in_path)
    begin
        weight_out<=weight_in;
        if (in_path='1') then
            weight_out<="00000000";
        end if;
    end process;

end Behavioral;

