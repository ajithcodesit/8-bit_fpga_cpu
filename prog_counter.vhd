library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prog_counter is
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
end entity prog_counter;

architecture rtl of prog_counter is

	constant c_PC_MAX : natural := 16;
	signal r_PC_REG : natural range 0 to c_PC_MAX;
	
	begin
		
		--Process to increment the counter and jump the counter value
		p_counter : process(i_clkin,i_reset)
			begin
				if i_reset = '0' then
					r_PC_REG <= 0; --Resetting the count register for program counter
				elsif rising_edge(i_clkin) then
					if i_ce = '0' then
						if r_PC_REG = c_PC_MAX-1 then
							r_PC_REG <= 0;
						else
							r_PC_REG <= r_PC_REG+1;
						end if;
					elsif i_j = '0' then
						r_PC_REG <= to_integer(unsigned(i_data_bus_in(3 downto 0)));  --The 4 LSB are used (WORK NEEDED HERE)
					end if;
				end if;
		end process p_counter;
		
		--Put the program counter value on to the bus
		o_data_bus_out <= std_logic_vector(to_unsigned(r_PC_REG,o_data_bus_out'length)) when(i_co = '0') else
								(others => '0');
		
		--Debug LED for the program counter
		o_pc_dbg_led <= std_logic_vector(to_unsigned(r_PC_REG,o_pc_dbg_led'length));
	
end rtl;