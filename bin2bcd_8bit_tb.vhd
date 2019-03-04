library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2bcd_8bit_tb is
end bin2bcd_8bit_tb;

architecture behaviour of bin2bcd_8bit_tb is

	component bin2bcd_8bit is
		port(
			i_bin : in std_logic_vector(7 downto 0);
			i_disp_sig : in std_logic;
			o_sig : out std_logic;
			o_ones : out std_logic_vector(3 downto 0);
			o_tens : out std_logic_vector(3 downto 0);
			o_hundreds : out std_logic_vector(3 downto 0)
		);
	end component bin2bcd_8bit;
	
	signal r_BIN : std_logic_vector(7 downto 0) := (others => '0');
	signal r_DISP_SIG : std_logic := '1';
	signal r_SIG : std_logic;
	signal r_ONES : std_logic_vector(3 downto 0);
	signal r_TENS : std_logic_vector(3 downto 0);
	signal r_HUNDEREDS : std_logic_vector(3 downto 0);
	
	begin
	
		UUT : bin2bcd_8bit
			port map(
				i_bin => r_BIN,
				i_disp_sig => r_DISP_SIG,
				o_sig => r_SIG,
				o_ones => r_ONES,
				o_tens => r_TENS,
				o_hundreds => r_HUNDEREDS
			);
			
		process is
			begin
			
			r_BIN <= X"FF";
			wait for 5 ns;
			
			r_BIN <= X"00";
			wait for 5 ns;
			
			r_BIN <= X"BC";
			wait for 5 ns;
			
			r_DISP_SIG <= '0';
			r_BIN <= X"FF";
			wait for 5 ns;
			
			r_BIN <= X"7F";
			wait for 5 ns;
			
			r_BIN <= X"80";
			wait for 5 ns;
			
			wait;
		end process;
		
end behaviour;
		
		
	