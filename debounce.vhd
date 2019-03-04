library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
	port(
		i_clk : in std_logic;
		i_switch : in std_logic;
		o_switch : out std_logic
	);
end entity debounce;

architecture rtl of debounce is
	
	--500000 clock ticks for 10 ms delay at 50MHz master clock
	constant c_DEBOUNCE_LIMIT : integer := 500000; --Should be reduced to 2 for TB
	
	signal r_count : integer range 0 to c_DEBOUNCE_LIMIT := 0;
	signal r_state : std_logic := '0';
	
	begin 
		
		p_debounce : process(i_clk) is
		begin 
			if rising_edge(i_clk) then
				
				--Switch bouncing is checked by checking the internal state and the actual switch value
				if(i_switch /= r_state and r_count  < c_DEBOUNCE_LIMIT) then
					r_count <= r_count + 1;
					
				--Switch is stable and can be register and the counter reset
				elsif r_count = c_DEBOUNCE_LIMIT then
					r_state <= i_switch;
					r_count <= 0;
					
				else
					r_count <= 0;
				
				end if;
			end if;
		end process p_debounce;
		
		--The final debounced switch value is output here
		o_switch <= r_state;
		
	end architecture rtl;