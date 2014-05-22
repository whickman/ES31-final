
-- VHDL Instantiation Created from source file solver.vhd -- 17:27:10 05/21/2014
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT solver
	PORT(
		clk_real : IN std_logic;
		TXD : IN std_logic;          
		RXD : OUT std_logic;
		test : OUT std_logic;
		red : OUT std_logic_vector(2 downto 0);
		green : OUT std_logic_vector(2 downto 0);
		blue : OUT std_logic_vector(1 downto 0);
		hs : OUT std_logic;
		vs : OUT std_logic
		);
	END COMPONENT;

	Inst_solver: solver PORT MAP(
		clk_real => ,
		TXD => ,
		RXD => ,
		test => ,
		red => ,
		green => ,
		blue => ,
		hs => ,
		vs => 
	);


