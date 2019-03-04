library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_7_segment_tb is
end entity display_7_segment_tb;

architecture behaviour of display_7_segment_tb is

	--50MHz = 20 ns period
	constant c_CLK_PERIOD : time := 20 ns;
	
	signal r_MCLK : std_logic := '0';
	signal r_CLKIN : std_logic := '0';
	signal r_RESET : std_logic := '1';
	signal r_WE : std_logic := '1';
	signal r_DISPLAY_SIGNED : std_logic := '1';
	signal r_DATA_BUS_IN : std_logic_vector(7 downto 0) := (others => '0');
	signal r_DIG : std_logic_vector(3 downto 0);
	signal r_SEGMENT_DRIVE : std_logic_vector(7 downto 0);
	
	component display_7_segment is
		port(
			i_mclk : in std_logic;  --Master clock input
			i_clkin : in std_logic; --The system clock
			i_reset : in std_logic;
			i_we : in std_logic;  --Output register in (Active LOW)
			i_display_signed : in std_logic;
			i_data_bus_in : in std_logic_vector(7 downto 0);
			o_dig : out std_logic_vector(3 downto 0);  --Selection for each digit of the 4 digit display
			o_segment_drive : out std_logic_vector(7 downto 0)  --7 segment display drive
			);
	end component display_7_segment;
	
	begin 
	
	UUT : display_7_segment 
		port map(
			i_mclk => r_MCLK,
			i_reset => r_RESET,
			i_clkin => r_CLKIN,
			i_we => r_WE,
			i_display_signed => r_DISPLAY_SIGNED,
			i_data_bus_in => r_DATA_BUS_IN,
			o_dig => r_DIG,
			o_segment_drive => r_SEGMENT_DRIVE
		);
		
	p_clk_gen : process is
		begin
			wait for c_CLK_PERIOD/2;
			r_MCLK <= not r_MCLK;
	end process p_clk_gen;
	
	process
		begin
		
		r_DATA_BUS_IN <= X"FF";
		r_DISPLAY_SIGNED <= '0';
		wait for 5 ns;
		r_WE <= '0';
		wait for 5 ns;
		r_CLKIN <= '1';
		wait for 5 ns;
		r_CLKIN <= '0';
		r_WE <= '1';
		
		--Reset
		wait for 310 ns;
		r_RESET <= '0';
		wait for 5 ns;
		r_RESET <= '1';
		
		r_DATA_BUS_IN <= X"FF";
		r_DISPLAY_SIGNED <= '1';
		wait for 5 ns;
		r_WE <= '0';
		wait for 5 ns;
		r_CLKIN <= '1';
		wait for 5 ns;
		r_CLKIN <= '0';
		r_WE <= '1';
		
		wait;
		
	end process;
end behaviour;
		
		
		
		
		
	
	
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	