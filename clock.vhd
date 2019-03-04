library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock is
	port(
		i_clkin : in std_logic; --This is the master clock
		i_man_clk : in std_logic; --Manual clock pulse generate button
		i_select : in std_logic;  --Select between manual or master clock input
		i_sel_clk_freq : in std_logic_vector(1 downto 0); --Select the clock frequency
		i_halt : in std_logic; --To stop the clock programatically (Used internally)
		o_clkout : out std_logic;
		o_clk_freq_dbg_led : out std_logic_vector(1 downto 0)
	);
end clock;

architecture rtl of clock is
	
	--To get the required constant frequency
	--50 MHz / 1Hz * 50% duty cycle = 25000000 counts
	--Should be reduced test bench
	constant c_CNT_1HZ : natural := 25000000; 
	constant c_CNT_5HZ : natural := 5000000;
	constant c_CNT_10HZ : natural := 2500000;
	constant c_CNT_25HZ : natural := 1000000;
	
	--Maximum value is used for the range
	signal r_CNT_FREQ : natural range 0 to c_CNT_1HZ;  --Counter used to generate the required clock
	signal r_COMP_CNT : natural range 0 to c_CNT_1HZ;  --Register to hold the count to compare and generate the clock
	
	--Counter for the amount of time the pulse should last
	--f = 1/T = 1/0.1 = 10 Hz (For 100 ms pulse)
	--50 MHz / 10Hz = 5000000
	constant c_CLK_MAN_COUNT : natural := 5000000; --Should be reduced to 5 for TB
	signal r_MAN_PULSE_COUNTER : natural range 0 to c_CLK_MAN_COUNT;
	
	--Signal that will be toggled at the required frequency
	signal r_TOGGLE_CLK : std_logic := '0';
	signal r_MAN_CLK_PULSE : std_logic := '0';
	
	--Register to store the selection
	signal r_selection : std_logic := '0';
	signal r_select_sw : std_logic := '0';
	signal w_select_sw : std_logic;
	
	--Manual clocking signal
	signal w_man_clk_sw : std_logic;
	signal w_sel_clk_freq_sw : std_logic_vector(1 downto 0);
	
	type t_sm_main is (s_idle, s_pulse, s_stop);
	signal r_sm_main : t_sm_main := s_idle;
	
	--Debounce module is used for the different switches
	component debounce
		port(
			i_clk : in std_logic;
			i_switch : in std_logic;
			o_switch : out std_logic
		);
	end component;
	
	begin
		
		select_debounce : debounce port map(i_clk=>i_clkin, i_switch=>i_select, o_switch=>w_select_sw);
		man_clk_debounce : debounce port map(i_clk=>i_clkin, i_switch=>i_man_clk, o_switch=>w_man_clk_sw);
		clk_freq_sel_lsb : debounce port map(i_clk=>i_clkin, i_switch=>i_sel_clk_freq(0),o_switch=>w_sel_clk_freq_sw(0));
		clk_freq_sel_msb : debounce port map(i_clk=>i_clkin, i_switch=>i_sel_clk_freq(1),o_switch=>w_sel_clk_freq_sw(1));
		
		--Process to generate clock form master clock
		p_gen_cpu_clk : process(i_clkin, w_sel_clk_freq_sw) is
		begin
			if rising_edge(i_clkin) then
				
				--Selecting the clock frequency
				case w_sel_clk_freq_sw is
					when "11" => r_COMP_CNT <= c_CNT_1HZ;
					when "10" => r_COMP_CNT <= c_CNT_5HZ;
					when "01" => r_COMP_CNT <= c_CNT_10HZ;
					when "00" => r_COMP_CNT <= c_CNT_25HZ;
					when others => r_COMP_CNT <= c_CNT_1HZ;
				end case;
				
				if r_CNT_FREQ = r_COMP_CNT-1 then
					r_TOGGLE_CLK <= not r_TOGGLE_CLK;
					r_CNT_FREQ <= 0;
				else
					r_CNT_FREQ <= r_CNT_FREQ+1;
				end if;
			end if;
		end process p_gen_cpu_clk;
		
		--Process for clock type selection (Select is active low)
		p_select : process(i_clkin) is
			begin
				if rising_edge(i_clkin) then
					r_select_sw <= w_select_sw; --Shift the button value in
					
					--Looking for a falling edge looking at the current and previous state in the register
					if w_select_sw = '0' and r_select_sw = '1' then
						r_selection <= not r_selection; --Toggling the selection register
					end if;
				end if;
		end process p_select;
		
		p_man_clk : process(i_clkin) is
			begin
				if rising_edge(i_clkin) then
					
					case r_sm_main is
						
						when s_idle =>  --Starting
							r_MAN_CLK_PULSE <= '0';
							r_MAN_PULSE_COUNTER <= 0;
							
							if w_man_clk_sw = '0' then
								r_sm_main <= s_pulse;
								r_MAN_CLK_PULSE <= '1'; --Clock line is set high
							else
								r_sm_main <= s_idle;
							end if;
							
						when s_pulse =>  --Pulse of required length
							if r_MAN_PULSE_COUNTER = c_CLK_MAN_COUNT-2 then
								r_MAN_CLK_PULSE <= '0'; --Clock line is set low
								r_sm_main <= s_stop;
							else 
								r_MAN_PULSE_COUNTER <= r_MAN_PULSE_COUNTER+1;
							end if;
							
						when s_stop =>  --Clock pulsing is completed
							if w_man_clk_sw = '1' then  --If the manual pulse button is released
								r_sm_main <= s_idle;  --Set the state to idle
							else
								r_sm_main <= s_stop;
							end if;
						
						when others =>  --Default case
							r_sm_main <= s_idle;
							
					end case;
				end if;
		end process p_man_clk;
			
		--The final clock output
		o_clkout <= r_TOGGLE_CLK when (r_selection = '0' and i_halt = '1') else
						r_MAN_CLK_PULSE when (r_selection = '1' and i_halt = '1') else
						'0'; --Halt if the above condtions are not met (LED will be HIGH because of pull up)
						
		o_clk_freq_dbg_led <= w_sel_clk_freq_sw;
		
end rtl;