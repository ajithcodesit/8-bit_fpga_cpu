library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture behaviour of alu_tb is
	
	signal r_EO : std_logic := '1';
	signal r_SU : std_logic := '1';
	signal r_A : std_logic_vector (7 downto 0) := (others => '0');
	signal r_B : std_logic_vector (7 downto 0) := (others => '0');
	signal r_CY : std_logic := '0';
	signal r_ZR : std_logic := '0';
	signal r_ALU_BUS_OUT : std_logic_vector (7 downto 0) := (others => '0');
	signal r_ALU_DBG_OUT : std_logic_vector (7 downto 0) := (others => '0');

	component alu is
		port(
			i_eo : in std_logic;  --Output the result (Active low)
			i_su : in std_logic;  --Subtraction when high and addition when low
			i_a : in std_logic_vector (7 downto 0);
			i_b : in std_logic_vector (7 downto 0);
			o_cy : out std_logic;
			o_zr : out std_logic;
			o_alu_bus_out : out std_logic_vector (7 downto 0);
			o_alu_dbg_led : out std_logic_vector(7 downto 0)
		);
	end component alu;

	begin
	
	UUT : alu
		port map(
			i_eo => r_EO,
			i_su => r_SU,
			i_a => r_A,
			i_b => r_B,
			o_cy => r_CY,
			o_zr => r_ZR,
			o_alu_bus_out => r_ALU_BUS_OUT,
			o_alu_dbg_led => r_ALU_DBG_OUT
		);
	
	process
	begin
		wait for 10 ns;
		r_A <= "00101111";
		r_B <= "00100001";
		wait for 10 ns;
		
		r_EO <= '0';
		wait for 30 ns;
		r_EO <= '1';
		
		wait for 10 ns;
		r_A <= "10010001";
		r_B <= "10010011";
		wait for 10 ns;
		
		r_EO <= '0';
		wait for 10 ns;
		r_SU <= '0';
		wait for 20 ns;
		r_SU <= '1';
		r_EO <= '1';
		
		wait for 10 ns;
		r_A <= "10010011";
		r_B <= "10010011";
		wait for 10 ns;
		
		r_EO <= '0';
		wait for 10 ns;
		r_SU <= '0';
		wait for 20 ns;
		r_SU <= '1';
		r_EO <= '1';
		
		wait;
		
	end process;

end architecture behaviour;