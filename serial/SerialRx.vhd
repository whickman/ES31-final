--Will Hickman
--ENGS 31 Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SerialRx is
    Port ( Clk25 : in  STD_LOGIC;
           TXD : in  STD_LOGIC;
           br_tick16 : in  STD_LOGIC;
           rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_done_tick : out  STD_LOGIC);
end SerialRx;

architecture Behavioral of SerialRx is

    Component controller 
    Port ( br_tick16 : in  STD_LOGIC;
           data_in : in  STD_LOGIC;
           clk : in STD_LOGIC;
           shift : out STD_LOGIC;
           clr : out  STD_LOGIC;
           load : out  STD_LOGIC;
           rx_done_tick : out  STD_LOGIC);
    end Component;

    Component double_flop_sync
    Port ( async_in : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           async_out : out  STD_LOGIC);
    end Component;

    Component load_reg
    Port ( data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           load : in  STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
    end Component;

    Component shift_reg
    Port ( data_in : in  STD_LOGIC;
           shift : in  STD_LOGIC;
           clr : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
    end Component;

    signal async_data : std_logic :='1';
    signal shift,clr,load : std_logic :='0';
    signal shift_output : std_logic_vector(7 downto 0); 
begin

    control : controller 
    PORT MAP (br_tick16=>br_tick16,
              data_in=>async_data,
              clk=>Clk25,
              shift=>shift,
              clr=>clr,
              load=>load,
              rx_done_tick=>rx_done_tick);

    df_sync : double_flop_sync 
    PORT MAP (async_in=>TXD,
              clk=>Clk25,
              async_out=>async_data);

    s_reg : shift_reg 
    PORT MAP (data_in=>async_data,
              shift=>shift,
              clr=>clr,
              clk=>Clk25,
              data_out=>shift_output);

    l_reg : load_reg 
    PORT MAP (data_in=>shift_output,
              clk=>Clk25,
              load=>load,
              data_out=>rx_data);

end Behavioral;

