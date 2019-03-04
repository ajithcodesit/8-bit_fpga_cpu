library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_register is
	port(
		i_clkin : in std_logic;
		i_reset : in std_logic;
		i_we : in std_logic; --Load enable (Active low)
		i_oe : in std_logic; --Write enable (Active low)
		i_data_bus_in: in std_logic_vector (7 downto 0);  --For internal buses seperate buses are used for data in/out
		o_data_bus_out : out std_logic_vector (7 downto 0);  --No tri-state logic internally available on at IO pins
		o_alu_reg_out : out std_logic_vector (7 downto 0); --This is connected to the ALU directly (Always output)
		o_reg_dbg_led : out std_logic_vector (7 downto 0)
	);
end entity alu_register;

architecture rtl of alu_register is
	
	signal r_data_reg : std_logic_vector(7 downto 0) := (others => '0');  --Initialize register to zero
	
	begin
	
	--Loading the data into the Accumulator (A) or B register
	p_load : process(i_clkin, i_reset) is
		begin
			if i_reset = '0' then --Asynchronus reset is used since clock can be halted which means synchronous reset won't work
				r_data_reg <= (others => '0');
			elsif rising_edge(i_clkin) then
				if i_we = '0' and i_oe = '1' then
					r_data_reg <= i_data_bus_in;  --Load the data from the bus in to the register
				end if;
			end if;
	end process p_load;
		
	--Putting the data in the register on to the bus
	o_data_bus_out <= r_data_reg when(i_oe = '0' and i_we = '1') else
							(others => '0');
							
	o_alu_reg_out <= r_data_reg;
	
	o_reg_dbg_led <= r_data_reg;  --For debugging the data in the register used LED
	
end rtl;
	
	
