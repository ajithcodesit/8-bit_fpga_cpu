library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_ram is
	port(
		i_clkin : in std_logic;
		i_we : in std_logic; --Active LOW
		i_oe : in std_logic; --Active LOW
		i_addr : in std_logic_vector(3 downto 0);
		i_data_bus_in : in std_logic_vector(7 downto 0);
		o_data_bus_out : out std_logic_vector(7 downto 0);
		o_ram_dbg_led : out std_logic_vector(7 downto 0)
	);
end entity single_port_ram;

architecture rtl of single_port_ram is
	
	--Based on Intel single port RAM example
	--Building a 2D array type of RAM
	subtype word_t is std_logic_vector(7 downto 0);
	type memory_t is array (0 to (2**i_addr'length)-1) of word_t;
	
	--RAM signal (This register hold the value stored in the address accessed from RAM)
	--Example for simple addition									
	signal r_ram : memory_t :=(
										"00011110", --LDA 14
										"00101111",	--ADD 15
										"11100000",	--OUT
										"11110000", --HALT
										"00000000", 
										"00000000", 
										"00000000", 
										"00000000", 
										"00000000",	
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00111000", --56 in binary at address 14
										"00011100"  --28 in binary at address 15
										);
										
	--Example for conditional jumps
--	signal r_ram : memory_t :=(
--										"00011110", --LDA 14
--										"00101111",	--ADD 15
--										"11100000",	--OUT
--										"01110101", --JC	5
--										"01100001", --JMP 1
--										"00111111", --SUB 15
--										"11100000", --OUT
--										"10000001", --JZ 	1
--										"01100101",	--JMP 5
--										"00000000",
--										"00000000",
--										"00000000",
--										"00000000",
--										"00000000",
--										"00000001", --1 in binary at address 14
--										"00000001"	--1 in binary at addresss 15
--										);
	
	begin
	
	--Writing to RAM
	p_ram_write : process(i_clkin)
		begin
			if rising_edge(i_clkin) then
				if i_we = '0' and i_oe ='1' then
					r_ram(to_integer(unsigned(i_addr))) <= i_data_bus_in;
				end if;
			end if;
	end process p_ram_write;
	
	--Putting the data in RAM on to the bus
	o_data_bus_out <= r_ram(to_integer(unsigned(i_addr))) when(i_oe = '0' and i_we = '1') else
							(others => '0');
	
	--Shows the contents of the current address if debug LEDs are used
	o_ram_dbg_led <= r_ram(to_integer(unsigned(i_addr)));
			
end rtl;
