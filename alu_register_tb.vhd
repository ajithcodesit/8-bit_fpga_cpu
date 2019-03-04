library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_register_tb is
end alu_register_tb;

architecture behaviour of alu_register_tb is
	
	--50 MHz = 20 ns period
	constant c_CLOCK_PERIOD : time := 20 ns;
	
	signal r_CLKIN : std_logic := '0';
	signal r_RESET : std_logic := '1';
	signal r_WE : std_logic := '1';
	signal r_OE : std_logic := '1';
	signal r_DATA_BUS_IN : std_logic_vector (7 downto 0) := (others => '0');
	signal r_DATA_BUS_OUT : std_logic_vector (7 downto 0) := (others => '0');
	signal r_REG_DBG_LED : std_logic_vector (7 downto 0) := (others => '0');
	
	component alu_register is
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_we : in std_logic; --Load enable (Active low)
			i_oe : in std_logic; --Write enable (Active low)
			i_data_bus_in: in std_logic_vector (7 downto 0);  --For internal buses seperate buses are used for data in/out
			o_data_bus_out : out std_logic_vector (7 downto 0);  --No tri-state logic internally available on at IO pins
			o_reg_dbg_led : out std_logic_vector (7 downto 0)
		);
	end component alu_register;
	
	begin
	
	UUT : alu_register 
		port map(
			i_clkin => r_CLKIN,
			i_reset => r_RESET,
			i_we => r_WE,
			i_oe => r_OE,
			i_data_bus_in => r_DATA_BUS_IN,
			o_data_bus_out => r_DATA_BUS_OUT,
			o_reg_dbg_led => r_REG_DBG_LED
		);
		
	p_clk_gen : process is
		begin
			wait for c_CLOCK_PERIOD/2;
			r_CLKIN <= not r_CLKIN;
		end process p_clk_gen;
		
	process
		begin
		
		r_DATA_BUS_IN <= "10101001";
		
		--Testing if data is getting when needed
		wait for 5 ns;
		r_WE<='0';
		wait for 20 ns;
		r_WE<='1';
		
		--Testing if data is being output to the out bus
		wait for 5 ns;
		r_OE<='0';
		wait for 20 ns;
		r_OE<='1';
		
		wait for 5 ns;
		r_RESET <= '0';
		wait for 20 ns;
		r_RESET <= '1';
		
		wait for 1 ns;
		
	end process;
end behaviour;
	
	
	
	
	
	
	

	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
