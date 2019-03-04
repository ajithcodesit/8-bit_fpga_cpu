library ieee;

use ieee.std_logic_1164.all;

entity flags_reg_tb is
end entity flags_reg_tb;

architecture behaviour of flags_reg_tb is

	signal r_CLKIN : std_logic := '0';
	signal r_RESET : std_logic := '1';
	signal r_CB : std_logic := '0';
	signal r_ZB : std_logic := '0';
	signal r_WE : std_logic := '1';
	signal r_FLAGS : std_logic_vector(1 downto 0) := (others =>'0');
	signal r_FLAGS_DBG_LED : std_logic_vector(1 downto 0) := (others => '0');

	component flags_reg is
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_cb : in std_logic; --Carry bit
			i_zb : in std_logic;	--Zero bit
			i_we : in std_logic; --Write to flags register(Active LOW)
			o_flags : out std_logic_vector(1 downto 0);
			o_flags_dbg_led : out std_logic_vector(1 downto 0)
		);
	end component flags_reg;
	
	begin
	
	UUT : flags_reg
		port map(
			i_clkin => r_CLKIN,
			i_reset => r_RESET,
			i_cb => r_CB,
			i_zb => r_ZB,
			i_we => r_WE,
			o_flags => r_FLAGS,
			o_flags_dbg_led => r_FLAGS_DBG_LED
		);
		
	process
	begin
	
	r_CB <= '1';
	r_WE <= '0';
	wait for 10 ns;
	r_CLKIN <= '1';
	wait for 10 ns;
	r_CLKIN <= '0';
	
	wait for 10 ns;
	
	r_ZB <= '1';
	r_WE <= '0';
	wait for 10 ns;
	r_CLKIN <= '1';
	wait for 10 ns;
	r_CLKIN <= '0';
	
	wait for 10 ns;
	
	r_RESET <= '0';
	wait for 10 ns;
	r_RESET <= '1';
	
	wait;
	
	end process;
end behaviour;