library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder_tb is
end entity instruction_decoder_tb;

architecture behaviour of instruction_decoder_tb is
	
	--50 MHz = 20 ns period
	constant c_CLK_PERIOD : time := 20 ns;
	
	signal r_CLKIN : std_logic := '0';
	signal r_RESET : std_logic := '1';
	
	signal r_INSTRUCTION : std_logic_vector(3 downto 0) := "0000"; --NOP
	signal r_FLAGS : std_logic_vector(1 downto 0) := "00";
	
	signal r_HLT : std_logic;
	signal r_MI : std_logic;
	signal r_RI : std_logic;
	signal r_RO : std_logic;
	signal r_IO : std_logic;
	signal r_II : std_logic;
	signal r_AI : std_logic;
	signal r_AO : std_logic;
	signal r_EPS : std_logic;
	signal r_SU : std_logic;
	signal r_BI : std_logic;
	signal r_BO : std_logic;
	signal r_OI : std_logic;
	signal r_CE : std_logic;
	signal r_CO : std_logic;
	signal r_J : std_logic;
	
	signal r_INV_CLK : std_logic;
	signal r_INST_STEP_DBG_LED : std_logic_vector(2 downto 0);
	signal r_CTRL_WORD_DBG_LED : std_logic_vector(15 downto 0);
	
	component instruction_decoder is
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_instruction : in std_logic_vector(3 downto 0);
			i_flags : in std_logic_vector(1 downto 0);
			o_hlt : out std_logic;
			o_mi : out std_logic;
			o_ri : out std_logic;
			o_ro : out std_logic;
			o_io : out std_logic;
			o_ii : out std_logic;
			o_ai : out std_logic;
			o_ao : out std_logic;
			o_eps : out std_logic;
			o_su : out std_logic;
			o_bi : out std_logic;
			o_bo : out std_logic;
			o_oi : out std_logic;
			o_ce : out std_logic;
			o_co : out std_logic;
			o_j : out std_logic;
			o_fi : out std_logic;
			o_inv_clk : out std_logic;
			o_inst_step_dbg_led : out std_logic_vector(2 downto 0);
			o_ctrl_word_dbg_led : out std_logic_vector(15 downto 0)
		);
	end component instruction_decoder;
	
	begin
	
	p_clk_gen : process is
		begin
			wait for c_CLK_PERIOD/2;
			r_CLKIN <= not r_CLKIN;
	end process p_clk_gen;
	
	UUT : instruction_decoder
		port map(
			i_clkin => r_CLKIN,
			i_reset => r_RESET,
			i_instruction => r_INSTRUCTION,
			i_flags => r_FLAGS,
			o_hlt => r_HLT,
			o_mi => r_MI,
			o_ri => r_RI,
			o_ro => r_RO,
			o_io => r_IO,
			o_ii => r_II,
			o_ai => r_AI,
			o_ao => r_AO,
			o_eps => r_EPS,
			o_su => r_SU,
			o_bi => r_BI,
			o_bo => r_BO,
			o_oi => r_OI,
			o_ce => r_CE,
			o_co => r_CO,
			o_j => r_J,
			o_inv_clk => r_INV_CLK,
			o_inst_step_dbg_led => r_INST_STEP_DBG_LED,
			o_ctrl_word_dbg_led => r_CTRL_WORD_DBG_LED
		);
	
	process
	begin
	
	r_INSTRUCTION <= "0001"; --LDA
	
	wait for 100 ns;
	
	r_INSTRUCTION <= "0111"; --JC
	
	wait for 100 ns;
	
	r_INSTRUCTION <= "1000"; --JZ
	
	wait for 100 ns;
	
	r_FLAGS <= "01"; --Set the carry flag
	r_INSTRUCTION <= "0111"; --JC
	
	wait for 100 ns;
	
	r_FLAGS <= "10"; --Set the carry flag
	r_INSTRUCTION <= "1000"; --JZ
	
	wait for 100 ns;
	
	r_FLAGS <= "11"; --Set the carry flag
	r_INSTRUCTION <= "0111"; --JC
	
	wait for 100 ns;
	
	r_FLAGS <= "11"; --Set the carry flag
	r_INSTRUCTION <= "1000"; --JZ
	
	wait for 100 ns;
	
	r_INSTRUCTION <= "0010"; --ADD
	
	wait for 100 ns;
	
	r_INSTRUCTION <= "1110"; --OUT
	
	wait for 50 ns;
	
	--Resetting in the middle
	r_RESET <= '0';
	wait for 10 ns;
	r_RESET <= '1';
	
	wait for 1 sec;
	
	end process;

end behaviour;