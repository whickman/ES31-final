--Will Hickman
--ENGS 31

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.All;

entity solver is
    Port ( clk : in  STD_LOGIC;
           TXD : in  STD_LOGIC;
           red : out std_logic_vector(2 downto 0);
		   green : out std_logic_vector(2 downto 0);
		   blue : out std_logic_vector(1 downto 0); 
           hs,vs : out STD_LOGIC);
end solver;

architecture Behavioral of solver is

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
	 
    component node_matrix
    Port ( clk : in  STD_LOGIC;
           disp_loc_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_tick : in STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           in_path : out STD_LOGIC;
           weight_out : out  STD_LOGIC_VECTOR (7 downto 0));
    end component;

    component vga_color
	port( row, column : in INTEGER;
		  in_path : std_logic;
          cell_address : out std_logic_vector(7 downto 0);
          cell_data : in std_logic_vector(7 downto 0);
          color : out std_logic_vector(7 downto 0));
    end component;
    
    component vga_controller
	port( clk_px : in std_logic;
          clk_en : in std_logic;
		  color : in std_logic_vector(7 downto 0);
		  red : out std_logic_vector(2 downto 0);
		  green : out std_logic_vector(2 downto 0);
		  blue : out std_logic_vector(1 downto 0);
		  hs,vs	: out std_logic;
		  row,column : out INTEGER);
    end component;

    signal br_tick_16, rx_done_tick, slow_clk, in_path, vga_clk_en : std_logic;
    signal color, cell_address, rx_data,weight : std_logic_vector(7 downto 0);
    signal row, col : integer;
    signal clk_counter : unsigned(1 downto 0) := (others=>'0');

begin

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
	 
    nm : node_matrix
    PORT MAP (
    clk,
    cell_address,
    rx_done_tick,
    rx_data,
    in_path,
    weight);

    v_col : vga_color
    PORT MAP (
    row,
    col,
	in_path,
    cell_address,
	weight,
    color);

    v_cont : vga_controller
    PORT MAP (
    clk,
    vga_clk_en,
    color,
    red,
    green,
    blue,
    hs,
    vs,
    row,
    col);

    --Enables the vga clock 1/4 of the time to match clock speeds
    vga_clk_en_process : process(clk)
    begin
        if rising_edge(clk) then
            vga_clk_en<='0';
            if (clk_counter="00") then
                vga_clk_en<='1';
            end if;
            clk_counter<=clk_counter+"01";
        end if;
    end process;

end Behavioral;

