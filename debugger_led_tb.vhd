library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debugger_led_tb is
end entity debugger_led_tb;

architecture behaviour of debugger_led_tb is

	constant c_CLK_PERIOD : time := 20 ns;

	signal r_MCLK : std_logic := '0';
	signal r_PC_BDG : std_logic_vector(3 downto 0) := "1011";
	signal r_A_REG_DBG : std_logic_vector(7 downto 0) := "11011011";
	signal r_ALU_REG_DBG : std_logic_vector(7 downto 0) := "10010011";
	signal r_FLAGS_REG_DBG : std_logic_vector(1 downto 0) := "10";
	signal r_B_REG_DBG : std_logic_vector(7 downto 0) := "10100101"; 
	signal r_MEM_ADDR_DBG : std_logic_vector(3 downto 0) := "1001";
	signal r_RAM_CONTENT_DBG : std_logic_vector(7 downto 0) := "11110011";
	signal r_INST_REG_DBG : std_logic_vector(7 downto 0) := "11001111";
	signal r_INST_STEP_DBG : std_logic_vector(2 downto 0) := "101";
	signal r_CTRL_WORD_DBG : std_logic_vector(15 downto 0) := "1110111100001111";
	signal r_BUS_DBG : std_logic_vector(7 downto 0) := "10111101";
	signal r_MUXED_DBG_LED_BUS : std_logic_vector(7 downto 0);
	signal r_ACT_LED_BUS : std_logic_vector(11 downto 0);
	
	component debugger_led is
		port(
			i_mclk : in std_logic;
			i_pc_dbg : in std_logic_vector(3 downto 0);
			i_a_reg_dbg : in std_logic_vector(7 downto 0);
			i_alu_reg_dbg : in std_logic_vector(7 downto 0);
			i_flags_reg_dbg : in std_logic_vector(1 downto 0);
			i_b_reg_dbg : in std_logic_vector(7 downto 0);
			i_mem_addr_dbg : in std_logic_vector(3 downto 0);
			i_ram_content_dbg : in std_logic_vector(7 downto 0);
			i_inst_reg_dbg : in std_logic_vector(7 downto 0);
			i_inst_step_dbg : in std_logic_vector(2 downto 0);
			i_ctrl_word_dbg : in std_logic_vector(15 downto 0);
			i_bus_dbg : in std_logic_vector(7 downto 0);
			o_muxed_dbg_led_bus : out std_logic_vector(7 downto 0) := (others => '0');
			o_act_led_bus : out std_logic_vector(11 downto 0) := (others => '0')
		);
	end component debugger_led;
	
	begin
	
	p_clk_gen : process is
		begin
			wait for c_CLK_PERIOD/2;
			r_MCLK <= not r_MCLK;
	end process p_clk_gen;
	
	UUT : debugger_led 
		port map(
			i_mclk => r_MCLK,
			i_pc_dbg => r_PC_BDG,
			i_a_reg_dbg => r_A_REG_DBG,
			i_alu_reg_dbg => r_ALU_REG_DBG,
			i_flags_reg_dbg => r_FLAGS_REG_DBG,
			i_b_reg_dbg => r_B_REG_DBG,
			i_mem_addr_dbg => r_MEM_ADDR_DBG,
			i_ram_content_dbg => r_RAM_CONTENT_DBG,
			i_inst_reg_dbg => r_INST_REG_DBG,
			i_inst_step_dbg => r_INST_STEP_DBG,
			i_ctrl_word_dbg => r_CTRL_WORD_DBG,
			i_bus_dbg => r_BUS_DBG,
			o_muxed_dbg_led_bus => r_MUXED_DBG_LED_BUS,
			o_act_led_bus => r_ACT_LED_BUS
		);
		
	process
	begin
	
	wait for 10 ns;
	
	end process;
	
end behaviour;
	
	