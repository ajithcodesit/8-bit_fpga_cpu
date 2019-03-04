library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prog_counter_tb is
end entity prog_counter_tb;

architecture behaviour of prog_counter_tb is
	
	--50 Mhz = 20 ns Time period
	constant c_CLK_PERIOD : time := 20 ns;
	
	signal r_CLKIN : std_logic := '0';
	signal r_RESET : std_logic := '1';
	signal r_CE : std_logic := '1';
	signal r_CO : std_logic := '1';
	signal r_J : std_logic := '1';
	signal r_DATA_BUS_IN : std_logic_vector(7 downto 0) := (others => '0');
	signal r_DATA_BUS_OUT : std_logic_vector(7 downto 0) := (others => '0');
	signal r_PC_DBG_LED : std_logic_vector(3 downto 0) := (others => '0');
	
	component prog_counter is
		port(
			i_clkin : in std_logic; 
			i_reset : in std_logic;
			i_ce : in std_logic;  --Counter enable (Active LOW)
			i_co : in std_logic;  --Counter output to bus (Active LOW)
			i_j : in std_logic;  --Set the counter to a specfic value by reading in the 4 LSB of the bus (Used in jump instruction) (Active LOW)
			i_data_bus_in : in std_logic_vector(7 downto 0); --All th 8 bits are used but only the 4 LSB are considered
			o_data_bus_out : out std_logic_vector(7 downto 0);
			o_pc_dbg_led : out std_logic_vector(3 downto 0)
		);
	end component prog_counter;
	
	begin
	
	UUT : prog_counter
		port map(
			i_clkin => r_CLKIN,
			i_reset => r_RESET,
			i_ce => r_CE,
			i_co => r_CO,
			i_j => r_J,
			i_data_bus_in => r_DATA_BUS_IN,
			o_data_bus_out => r_DATA_BUS_OUT,
			o_pc_dbg_led => r_PC_DBG_LED
		);
	
	p_clk_gen : process is
		begin
			wait for c_CLK_PERIOD/2;
			r_CLKIN <= not r_CLKIN;
	end process p_clk_gen;
	
	process
	begin
	
	r_DATA_BUS_IN <= "11111001"; --Just to check if something is getting in
	r_CE <= '0';
	r_J <= '1';
	wait for 620 ns;
	r_CE <= '1';
	
	wait for 5 ns;
	r_CO <= '0';
	wait for 10 ns;
	r_CO <= '1';
	
	wait for 10 ns;
	r_J <= '0';
	wait for 10 ns;
	r_J <= '1';
	
	wait for 10 ns;
	r_RESET <= '0';
	wait for 10 ns;
	r_RESET <= '1';
	
	wait for 1 sec;
	
	end process;
	
end behaviour;
	
	
	
	
	
	
	
	
	
	
	
	