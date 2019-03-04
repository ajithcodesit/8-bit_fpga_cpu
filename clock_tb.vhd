library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_tb is
end clock_tb;

architecture behaviour of clock_tb is
	
	--Period of 50 MHz master clock
	constant c_CLOCK_PERIOD : time := 20 ns;
	
	signal r_CLOCKIN : std_logic := '0';
	signal r_MAN_CLK : std_logic := '1';
	signal r_SELECT : std_logic := '1'; -- 1 means not active
	signal r_HALT : std_logic := '1';
	signal r_CLKOUT : std_logic;
	
	component clock is
		port(
			i_clkin : in std_logic;
			i_man_clk : in std_logic; 
			i_select : in std_logic;
			i_halt : in std_logic;
			o_clkout : out std_logic
		);
	end component clock;
	
	begin 
	
	--Unit Under Test
	UUT : clock
		port map(
			i_clkin => r_CLOCKIN,
			i_man_clk => r_MAN_CLK,
			i_select => r_SELECT,
			i_halt => r_HALT,
			o_clkout => r_CLKOUT
		);
		
	p_CLK_GEN : process is
		begin
			wait for c_CLOCK_PERIOD/2;
			r_CLOCKIN <= not r_CLOCKIN;
		end process p_CLK_GEN;
		
	--Main testing section
	process
	begin
		
	wait;
	
	end process;

end behaviour;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

		
		
		
		
		
		
		
		
