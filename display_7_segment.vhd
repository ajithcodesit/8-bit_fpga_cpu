library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_7_segment is
	port(
		i_mclk : in std_logic;  --Master clock input
		i_clkin : in std_logic; --The system clock
		i_reset : in std_logic; --Reset the qutput register
		i_we : in std_logic;  --Output register in (Active LOW)
		i_display_signed : in std_logic;
		i_data_bus_in : in std_logic_vector(7 downto 0);
		o_dig : out std_logic_vector(3 downto 0) := (others => '1');  --Selection for each digit of the 4 digit display (Active LOW)
		o_segment_drive : out std_logic_vector(7 downto 0) := (others => '1')  --7 segment display drive (Active LOW)
		);
end entity display_7_segment;

architecture rtl of display_7_segment is

	--7 segment display refresh logic
	constant c_REFRESH_DISP_CNT : natural := 200000; --125Hz refresh (Count 200000)
	constant c_MAX_REFRESH_DIGIT : natural := 4; --4 different 7 segment display

	--A counter is needed for the diplay refresh
	signal r_REFRESH_DISP_CNT : natural range 0 to c_REFRESH_DISP_CNT;

	--This register holds which digit of the display is getting updated
	signal r_REFRESH_DIGIT : natural range 0 to c_MAX_REFRESH_DIGIT;

	signal r_DIG0_SEG : std_logic_vector(7 downto 0) := (others=>'0');
	signal r_DIG1_SEG : std_logic_vector(7 downto 0) := (others=>'0');
	signal r_DIG2_SEG : std_logic_vector(7 downto 0) := (others=>'0');
	signal r_DIG3_SEG : std_logic_vector(7 downto 0) := (others=>'0');
	
	--Register to hold the result to display
	signal r_OUTPUT_REG : std_logic_vector(7 downto 0) := (others => '0');
	
	--Registers for ones, tens and hundreds
	signal r_ONES : std_logic_vector(3 downto 0) := (others => '0');
	signal r_TENS : std_logic_vector(3 downto 0) := (others => '0');
	signal r_HUNDREDS : std_logic_vector(3 downto 0) := (others => '0');
	signal r_SIGN : std_logic := '0';

	--Function that contains the logic to convert binary to 7 segment display
	function f_4_BIT_BCD2SEG_DISP(r_BIN_IN: in std_logic_vector(3 downto 0))
			return std_logic_vector is --Return type
			variable v_DISP_PATTERN : std_logic_vector(7 downto 0); --Actual return is 8 Bit vector
			
		begin --Function definition begins
			
			case r_BIN_IN is --Case statement to convert Binary to 7 segment output
				when "0000" => --0
					v_DISP_PATTERN := not "00111111";
				when "0001" => --1
					v_DISP_PATTERN := not "00000110";
				when "0010" => --2
					v_DISP_PATTERN := not "01011011";
				when "0011" => --3
					v_DISP_PATTERN := not "01001111";
				when "0100" => --4
					v_DISP_PATTERN := not "01100110";
				when "0101" => --5
					v_DISP_PATTERN := not "01101101";
				when "0110" => --6
					v_DISP_PATTERN := not "01111101";
				when "0111" => --7
					v_DISP_PATTERN := not "00000111";
				when "1000" => --8
					v_DISP_PATTERN := not "01111111";
				when "1001" => --9
					v_DISP_PATTERN := not "01100111";
				when others => --Undefined
					v_DISP_PATTERN := not "00000000";
			end case;
			
			return std_logic_vector(v_DISP_PATTERN);
		end function f_4_BIT_BCD2SEG_DISP;
		
	component bin2bcd_8bit 
		port(
			i_bin : in std_logic_vector(7 downto 0);
			i_disp_sig : in std_logic;  --Whether signed or not (Active LOW, LOW -> SIGNED, HIGH -> UNSIGNED)
			o_sig : out std_logic;  --Signal to say whether signed or not (Active LOW, LOW -> SIGNED, HIGH -> UNSIGNED)
			o_ones : out std_logic_vector(3 downto 0);
			o_tens : out std_logic_vector(3 downto 0);
			o_hundreds : out std_logic_vector(3 downto 0)
		);
	end component bin2bcd_8bit;

	begin
	
		bin2bcd : bin2bcd_8bit 
			port map(
					i_bin => r_OUTPUT_REG,
					i_disp_sig => i_display_signed,
					o_sig => r_SIGN,
					o_ones => r_ONES,
					o_tens => r_TENS,
					o_hundreds => r_HUNDREDS
				);
		
		--Process to store the output in a register to display
		p_output : process(i_clkin,i_reset) is
			begin
				if i_reset = '0' then
					r_OUTPUT_REG <= (others => '0');
				elsif rising_edge(i_clkin) then
					if i_we = '0' then
						r_OUTPUT_REG <= i_data_bus_in;
					end if;
				end if;
		end process p_output;
					
		
		p_REFRESH_DISP: process(i_mclk) is
			begin
				if rising_edge(i_mclk) then
					if r_REFRESH_DISP_CNT = c_REFRESH_DISP_CNT-1 then --If the refresh count is reached
					
						if r_REFRESH_DIGIT = c_MAX_REFRESH_DIGIT-1 then --If max digit is reached
							r_REFRESH_DIGIT<=0; --Reset to the 0th digit
						else
							r_REFRESH_DIGIT<=r_REFRESH_DIGIT+1; --Increment the digit display counter
						end if;
						
						r_DIG0_SEG <= f_4_BIT_BCD2SEG_DISP(r_ONES);
						r_DIG1_SEG <= f_4_BIT_BCD2SEG_DISP(r_TENS);
						r_DIG2_SEG <= f_4_BIT_BCD2SEG_DISP(r_HUNDREDS);
						
						if r_SIGN = '1' and i_display_signed = '0' then --Active low therefore signed numbers are used
							r_DIG3_SEG <= not "01000000";
						else 
							r_DIG3_SEG <= not "00000000"; --Turn the 7 segment completely off
						end if;
							
						
						r_REFRESH_DISP_CNT<=0; --Reset the refresh counter
						
						case r_REFRESH_DIGIT is --Updating the display
							when 0 => --Update digit 1
								o_dig <= not "1000";
								o_segment_drive<=r_DIG0_SEG;
							when 1 => --Update digit 2
								o_dig <= not "0100";
								o_segment_drive<=r_DIG1_SEG;
							when 2 => --Update digit 3
								o_dig <= not "0010";
								o_segment_drive<=r_DIG2_SEG;
							when 3 => --Update digit 4
								o_dig <= not "0001";
								o_segment_drive<=r_DIG3_SEG;
							when others => --Invalid case
								o_dig <= not "0000";
						end case;
						
					else
						r_REFRESH_DISP_CNT<=r_REFRESH_DISP_CNT+1; --Increment the refresh counter
					end if;
				end if;
		end process p_REFRESH_DISP;
	
end rtl;