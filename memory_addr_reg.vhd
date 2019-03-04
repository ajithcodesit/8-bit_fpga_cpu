library ieee;

use ieee.std_logic_1164.all;

entity memory_addr_reg is
	port(
		i_clkin : in std_logic;
		i_reset : in std_logic;
		i_mi : in std_logic; --Signal to take in the 4 LSB and put it into the register (Active LOW)
		i_data_bus_in : in std_logic_vector(7 downto 0);
		o_addr : out std_logic_vector(3 downto 0) --Outputs the 4 LSB stored in the memory address register
	);
end entity memory_addr_reg;

architecture rtl of memory_addr_reg is

	signal r_mem_addr_reg : std_logic_vector(3 downto 0) := (others => '0');
	
	begin
	
	p_mem_addr_write : process(i_clkin,i_reset)
		begin
			if i_reset = '0' then
				r_mem_addr_reg <= (others => '0');
			elsif rising_edge(i_clkin) then
				if i_mi = '0' then
					r_mem_addr_reg <= i_data_bus_in(3 downto 0); --LSB of the data bus is taken and stored
				end if;
			end if;
		end process p_mem_addr_write;
		
	o_addr <= r_mem_addr_reg; --Output the address constantly

end rtl;
				
