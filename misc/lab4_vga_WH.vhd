----------------------------------------------------------------------------------
-- Company:       ENGS 31
-- Engineer:      Will Hickman
-- 
-- Create Date:    22:35:56 04/23/2014 
-- Design Name: 
-- Module Name:    lab4_vga_WH - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:     A VGA controller
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

entity vga_controller is
    Port ( HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           red: out STD_LOGIC_VECTOR (2 downto 0);
           green: out STD_LOGIC_VECTOR (2 downto 0);
           blue: out STD_LOGIC_VECTOR (2 downto 1);
           clk : in  STD_LOGIC);
end lab4_vga_WH;

architecture Behavioral of vga_controller is

    COMPONENT vga_test_pattern
        port(row_counter     : in std_logic_vector(9 downto 0);
	         column_counter  : in std_logic_vector(9 downto 0);
		     color           : out std_logic_vector(7 downto 0));
    END COMPONENT;

    constant VFP : integer := 10;
    constant VPW : integer := 2;
    constant VBP : integer := 29;
    constant VD : integer := 480;
    constant VTS : integer := 521;

    constant HFP : integer := 16;
    constant HPW : integer := 96;
    constant HBP : integer := 48;
    constant HD : integer := 640;
    constant HTS : integer := 800;

    signal color_in,color_out :  std_logic_vector(7 downto 0) := (others=>'0');
    signal rowsV,colsV : std_logic_vector(9 downto 0) := (others=>'0');
    signal cols,rows: integer := 0;
    signal vp,hp:std_logic:='1';

begin

    vga_pattern : vga_test_pattern PORT MAP (row_counter=>rowsV,column_counter=>colsV,color=>color_in);

    clocked_process: process(clk)
    begin
        if rising_edge(clk) then
            if (cols=(HTS-1)) then
                cols<=0;
                if (rows=VTS-1) then
                    rows<=0;
                else
                    rows<=rows+1;
                end if;
            else
                cols<=cols+1;
            end if;
            hp<='1';
            if (cols<HPW) then
                hp<='0';
            end if;
            vp<='1';
				if (rows<VPW) then
					vp<='0';
            end if;
        end if;
         
    end process;

    color_process: process(rows,cols,color_in)
    begin
        color_out<=(others=>'0');
        if ((rows>(VPW+VBP)) and (rows<(VTS-VFP)) and
        (cols>(HPW+HBP)) and (cols<(HTS-HFP))) then
            color_out<=color_in;
        end if;
    end process;

    rowsV<=std_logic_vector(to_unsigned((rows-VPW-VBP),10));
    colsV<=std_logic_vector(to_unsigned((cols-HPW-HBP),10));
    red<=color_out(7 downto 5);
    green<=color_out(4 downto 2);
    blue<=color_out(1 downto 0);
    VS<=vp;
    HS<=hp;
    
end Behavioral;

