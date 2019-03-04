library ieee;

use ieee.std_logic_1164.all;

entity flags_reg is
	port(
		i_clkin : in std_logic;
		i_reset : in std_logic;
		i_cb : in std_logic; --Carry bit
		i_zb : in std_logic;	--Zero bit
		i_we : in std_logic; --Write to flags register(Active LOW)
		o_flags : out std_logic_vector(1 downto 0);
		o_flags_dbg_led : out std_logic_vector(1 downto 0)
	);
end entity flags_reg;

architecture rtl of flags_reg is
	
	--Flags register arrangement
	--1 0
	--Z C
	--F F

	signal r_flags_reg : std_logic_vector(1 downto 0) := (others => '0');
	
	begin
	
	p_flag_set : process(i_clkin,i_reset) is
		begin
			if i_reset = '0' then
				r_flags_reg <= (others => '0');
			elsif rising_edge(i_clkin) then
				if i_we = '0' then 
					r_flags_reg(0) <= i_cb;
					r_flags_reg(1) <= i_zb;
				end if;
			end if;
	end process p_flag_set;
	
	--Output the flags
	o_flags <= r_flags_reg;
	
	--For debug LEDs
	o_flags_dbg_led <= r_flags_reg;
	
end rtl;
	
	
	