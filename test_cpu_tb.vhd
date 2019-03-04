library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--This testbench requires the simple addition example in the RAM

entity test_cpu_tb is
end entity test_cpu_tb;

architecture behaviour of test_cpu_tb is
	
	--50 MHz clock = 20 ns time period
	constant c_CLK_PERIOD : time := 20 ns;
	
	signal r_CPU_CLK : std_logic := '0';
	signal r_MASTER_RESET : std_logic := '1';
	signal r_OUTPUT : std_logic_vector(7 downto 0) := (others=>'0');
	
	component test_cpu is
		port(
			i_cpu_clk : in std_logic;
			i_master_rst : in std_logic;
			o_output : out std_logic_vector(7 downto 0)
		);
	end component test_cpu;
	
	begin
	
	p_clk_gen : process is
		begin
			wait for c_CLK_PERIOD/2;
			r_CPU_CLK <= not r_CPU_CLK;
	end process p_clk_gen;
	
	UUT : test_cpu
		port map(
			i_cpu_clk => r_CPU_CLK,
			i_master_rst => r_MASTER_RESET,
			o_output => r_OUTPUT
		);
	
	process
	begin
	
	wait for 400 ns;
	
	if r_OUTPUT = "01010100" then
		report "Test Passed -- Correct byte in the ALU register A" severity note;
	else
		report "Test Failed -- Incorrect byte in the ALU register A" severity note;
	end if;
	
	wait for 10 ns;
	r_MASTER_RESET <= '0';
	wait for 10 ns;
	r_MASTER_RESET <= '1';
	
	assert false report "Test complete" severity failure;
	
	end process;
end behaviour;
	
	