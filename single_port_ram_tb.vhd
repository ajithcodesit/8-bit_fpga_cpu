library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_ram_tb is
end entity single_port_ram_tb;

architecture rtl of single_port_ram_tb is

	--50 MHz = 20 ns period
	constant c_CLOCK_PERIOD : time := 20 ns;
	
	signal r_CLKIN : std_logic := '0';
	signal r_WE : std_logic := '1';
	signal r_OE : std_logic := '1';
	signal r_ADDR : std_logic_vector(3 downto 0) := (others => '0');
	signal r_DATA_BUS_IN : std_logic_vector(7 downto 0) := (others => '0');
	signal r_DATA_BUS_OUT : std_logic_vector(7 downto 0) := (others => '0');
	signal r_RAM_DBG_LED : std_logic_vector(7 downto 0) := (others => '0');
	
	component single_port_ram is
			port(
				i_clkin : in std_logic;
				i_we : in std_logic; --Active LOW
				i_oe : in std_logic; --Active LOW
				i_addr : in std_logic_vector(3 downto 0);
				i_data_bus_in : in std_logic_vector(7 downto 0);
				o_data_bus_out : out std_logic_vector(7 downto 0);
				o_ram_dbg_led : out std_logic_vector(7 downto 0)
			);
	end component single_port_ram;
	
	begin
	
	UUT : single_port_ram
		port map(
			i_clkin => r_CLKIN,
			i_we => r_WE,
			i_oe => r_OE,
			i_addr => r_ADDR,
			i_data_bus_in => r_DATA_BUS_IN,
			o_data_bus_out => r_DATA_BUS_OUT,
			o_ram_dbg_led => r_RAM_DBG_LED
		);
		
	p_clk_gen : process is
		begin
			wait for c_CLOCK_PERIOD/2;
			r_CLKIN <= not r_CLKIN;
		end process p_clk_gen;
		
	process
	begin
		
		r_ADDR <= "0001";
		r_DATA_BUS_IN <= "10011001";
		wait for 7.5 ns;
		r_WE <= '0';
		wait for 5 ns;
		r_WE <= '1';
		
		r_ADDR <= "1010";
		r_DATA_BUS_IN <= "10111101";
		wait for 15 ns;
		r_WE <= '0';
		wait for 5 ns;
		r_WE <= '1';
		
		r_ADDR <= "0001";
		r_DATA_BUS_IN <= "11111111"; --Just to ckeck if data gets in the ram
		wait for 15 ns;
		r_OE <= '0';
		wait for 5 ns;
		r_OE <= '1';
		
		r_ADDR <= "1010";
		r_DATA_BUS_IN <= "11111111";
		wait for 15 ns;
		r_OE <= '0';
		wait for 5 ns;
		r_OE <= '1';
		
		wait for 1 sec;
		
	end process;
	
end architecture rtl;
		
		
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
