library ieee;

use ieee.std_logic_1164.all;

entity memory_addr_reg_tb is
end entity memory_addr_reg_tb;

architecture behaviour of memory_addr_reg_tb is

	--50MHz clock = 20 ns period
	constant c_CLK_PERIOD : time := 20 ns;
	
	signal r_CLKIN : std_logic := '0';
	signal r_RESET : std_logic := '1';
	signal r_MI : std_logic := '1';
	signal r_DATA_BUS_IN : std_logic_vector(7 downto 0) := (others => '0');
	signal r_ADDR : std_logic_vector (3 downto 0) := (others => '0');
	
	component memory_addr_reg is
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_mi : in std_logic; --Signal to take in the 4 LSB and put it into the register (Active LOW)
			i_data_bus_in : in std_logic_vector(7 downto 0);
			o_addr : out std_logic_vector(3 downto 0) --Outputs the 4 LSB stored in the memory address register
		);
	end component memory_addr_reg;
	
	begin
	
	UUT : memory_addr_reg
		port map(
			i_clkin => r_CLKIN,
			i_reset => r_RESET,
			i_mi => r_MI,
			i_data_bus_in => r_DATA_BUS_IN,
			o_addr => r_ADDR
		);
			
	p_clk_gen : process is
		begin
			wait for c_CLK_PERIOD/2;
			r_CLKIN <= not r_CLKIN;
		end process p_clk_gen;
	
	process
	begin
		
		r_DATA_BUS_IN <= "11111011";
		wait for 7.5 ns;
		r_MI <= '0';
		wait for 5 ns;
		r_MI <= '1';
		
		r_DATA_BUS_IN <= "10010000";
		
		wait for 5 ns;
		r_RESET <= '0';
		wait for 5 ns;
		r_RESET <= '1';
		
		wait for 1 sec;
	
	end process;
	
end behaviour;
	
	
	
	
	
	
	
	
		