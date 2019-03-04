library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port(
		i_eo : in std_logic;  --Output the result (Active low)
		i_su : in std_logic;  --Subtraction when high and addition when low
		i_a : in std_logic_vector (7 downto 0);
		i_b : in std_logic_vector (7 downto 0);
		o_cy : out std_logic; --Carry 
		o_zr : out std_logic; --Zero
		o_alu_bus_out : out std_logic_vector (7 downto 0);
		o_alu_dbg_led : out std_logic_vector(7 downto 0)
	);
end entity alu;

architecture rtl of alu is

	--Only combinational logic is used for the ALU
	
	signal w_a : std_logic_vector (8 downto 0) := (others => '0');
	signal w_b : std_logic_vector (8 downto 0) := (others => '0');
	signal w_alu_out : std_logic_vector (8 downto 0) := (others => '0');

	begin
	
	w_a(7 downto 0) <= i_a;
	w_b(7 downto 0) <= i_b;
	
	--Arithmatic operations (Only add and subtraction) (Subtraction is active low)
	w_alu_out <= std_logic_vector(unsigned(w_a) + unsigned(w_b)) when (i_su = '1') else
				std_logic_vector(unsigned(w_a) - unsigned(w_b));
	
	o_cy <= w_alu_out(8); --Output the carry bit used with jump carry command
	o_zr <= '1' when (w_alu_out(7 downto 0) = (w_alu_out(7 downto 0)'range => '0')) else --Output the zero bit used for jump zero command
			  '0';
		
	--Putting the ALU result onto the bus
	o_alu_bus_out <= w_alu_out(7 downto 0) when(i_eo = '0') else
						  (others => '0');
	
	--Debug LEDs if used
	o_alu_dbg_led <= w_alu_out(7 downto 0);

end architecture rtl;