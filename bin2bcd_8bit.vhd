library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2bcd_8bit is
	port(
		i_bin : in std_logic_vector(7 downto 0);
		i_disp_sig : in std_logic;  --Whether signed or not (Active LOW, LOW -> SIGNED, HIGH -> UNSIGNED)
		o_sig : out std_logic;  --Signal to say whether signed or not (Active LOW, LOW -> SIGNED, HIGH -> UNSIGNED)
		o_ones : out std_logic_vector(3 downto 0);
		o_tens : out std_logic_vector(3 downto 0);
		o_hundreds : out std_logic_vector(3 downto 0)
	);
end bin2bcd_8bit;

architecture rtl of bin2bcd_8bit is

	begin
	
	--Just combinational logic
	
	p_bin2bcd : process(i_bin, i_disp_sig)  --Double dable algorithm (Based on Wikipedia example)
		
		variable temp : std_logic_vector(7 downto 0);
		variable bcd : unsigned(11 downto 0) := (others => '0');
		
		begin 
			bcd := (others => '0'); --Initialize to zero
			
			if i_disp_sig = '0' and i_bin(7) = '1' then --If the display needs to be signed output check if the MSB is 1
				temp(7 downto 0) := std_logic_vector(unsigned(not i_bin)+1);  --Read input into the temporary variable
				o_sig <= '1';  --Number is signed
			else
				temp(7 downto 0) := i_bin;
				o_sig <= '0';
			end if;
			
			--Cycling 8 times for the 8 bits
			for i in 0 to 7 loop
				
				if bcd(3 downto 0) > 4 then
					bcd(3 downto 0) := bcd(3 downto 0) + 3;
				end if;
				
				if bcd(7 downto 4) > 4 then
					bcd(7 downto 4) := bcd(7 downto 4) + 3;
				end if;
				
				--Shift bcd left by 1 Bit and copy the MSB of temperory into LSB of BCD
				bcd := bcd(10 downto 0) & temp(7); -- Concatenation of the MSB of temperory
				
				--Shift temperory left by 1 Bit
				temp := temp(6 downto 0) & '0';
				
			end loop;
			
			o_ones <= std_logic_vector(bcd(3 downto 0));
			o_tens <= std_logic_vector(bcd(7 downto 4));
			o_hundreds <= std_logic_vector(bcd(11 downto 8));
			
	end process p_bin2bcd;
	
end rtl;
			
			
				
		
		