library ieee;

use ieee.std_logic_1164.all;

entity instruction_reg_tb is
end entity instruction_reg_tb;

architecture behaviour of instruction_reg_tb is
	
	--50 MHz clock = 20 ns period
	constant c_CLK_PERIOD : time := 20 ns;

	signal r_CLKIN : std_logic := '0';
	signal r_RESET : std_logic := '1';
	signal r_WE : std_logic := '1';
	signal r_OE : std_logic := '1';
	signal r_DATA_BUS_IN : std_logic_vector(7 downto 0) := (others => '0');
	signal r_DATA_BUS_OUT : std_logic_vector(7 downto 0);
	signal r_INSTRUCTION : std_logic_vector(3 downto 0);
	signal r_INSTREG_DBG_LED : std_logic_vector(7 downto 0);

	component instruction_reg is
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_we : in std_logic; --Instruction register in (Active LOW)
			i_oe : in std_logic; --Instruction register output (Active LOW)
			i_data_bus_in : in std_logic_vector(7 downto 0);
			o_data_bus_out : out std_logic_vector(7 downto 0);
			o_instuction : out std_logic_vector(3 downto 0);
			o_instreg_dbg_led : out std_logic_vector(7 downto 0)
		);
	end component instruction_reg;
	
	begin
	
	UUT : instruction_reg
		port map(
			i_clkin => r_CLKIN,
			i_reset => r_RESET,
			i_we => r_WE,
			i_oe => r_OE,
			i_data_bus_in => r_DATA_BUS_IN,
			o_data_bus_out => r_DATA_BUS_OUT,
			o_instuction => r_INSTRUCTION,
			o_instreg_dbg_led => r_INSTREG_DBG_LED
		);
	
	p_clk_gen : process is
		begin
			wait for c_CLK_PERIOD/2;
			r_CLKIN <= not r_CLKIN;
	end process p_clk_gen;
	
	process
	begin
	
	r_DATA_BUS_IN <= "10100101";
	wait for 5 ns;
	r_WE <= '0';
	wait for 10 ns;
	r_WE <= '1';
	
	wait for 10 ns;
	r_OE <= '0';
	wait for 10 ns;
	r_OE <= '1';
	
	wait for 10 ns;
	r_RESET <= '0';
	wait for 5 ns;
	r_RESET <= '1';
	
	wait for 1 sec;
	
	end process;
end behaviour;
	
	