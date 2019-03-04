library ieee;

use ieee.std_logic_1164.all;

entity instruction_reg is
	port(
		i_clkin : in std_logic;
		i_reset : in std_logic;
		i_we : in std_logic; --Instruction register in (Active LOW)
		i_oe : in std_logic; --Instruction register output (Active LOW)
		i_data_bus_in : in std_logic_vector(7 downto 0);
		o_data_bus_out : out std_logic_vector(7 downto 0);
		o_instuction : out std_logic_vector(3 downto 0);
		o_instreg_dbg_led : out std_logic_vector(7 downto 0)
	);
end entity instruction_reg;

architecture rtl of instruction_reg is

	--Instruction register
	signal r_instruction_reg : std_logic_vector(7 downto 0) := (others => '0');
	signal w_address : std_logic_vector(7 downto 0) := (others => '0');
	
	begin
		
		w_address(3 downto 0) <= r_instruction_reg(3 downto 0); --The address associated with the instruction is found in the 4 LSB
		
		--Instruction register input
		p_instreg_write : process(i_clkin,i_reset) is
			begin
				if i_reset = '0' then
					r_instruction_reg <= (others => '0');
				elsif rising_edge(i_clkin) then
					if i_we = '0' and i_oe = '1' then
						r_instruction_reg <= i_data_bus_in;
					end if;
				end if;
		end process p_instreg_write;
		
		--Instruction register output	to the data bus	
		o_data_bus_out <= w_address when(i_oe = '0' and i_we = '1') else
								(others => '0');
		
		o_instuction <= r_instruction_reg(7 downto 4);  --The 4 MSB is the instruction
		o_instreg_dbg_led <= r_instruction_reg; --The debug LED is the instruction register
		
end rtl;
				
	
	
	
	