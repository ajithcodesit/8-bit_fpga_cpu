library ieee;

use ieee.std_logic_1164.all;

entity test_cpu is
	port(
		i_cpu_clk : in std_logic;
		i_master_rst : in std_logic;
		o_output : out std_logic_vector(7 downto 0)
	);
end entity test_cpu;

architecture rtl of test_cpu is
	
	--CPU Clock
	signal w_CLK_1HZ : std_logic;
	signal w_HLT : std_logic;
	
	--Master reset for the entire CPU
	signal w_RESET : std_logic;
	
	--Data bus connections
	signal w_DATA_BUS_IN : std_logic_vector(7 downto 0);
	signal w_DATA_BUS_OUT_PC : std_logic_vector(7 downto 0);
	signal w_DATA_BUS_OUT_INR : std_logic_vector(7 downto 0);
	
	--Memory address register controls and output
	signal w_MI : std_logic; --Memory address register in
	signal w_ADDR : std_logic_vector(3 downto 0); --Address to be put into RAM
	
	--RAM control and outputs
	signal w_RI : std_logic;
	signal w_RO : std_logic;
	signal w_DATA_BUS_OUT_RAM : std_logic_vector(7 downto 0);
	signal w_RAM_DBG_LED : std_logic_vector(7 downto 0);
	
	--Program counter controls and output
	signal w_CO : std_logic; --Counter out
	signal w_CE : std_logic; --Counter enable (Increments)
	signal w_J : std_logic; --Jump 
	signal w_PC_DBG_LED : std_logic_vector(3 downto 0);
	
	--Register A and B for the ALU (A is the accumulator)
	signal w_AI : std_logic;
	signal w_AO : std_logic;
	signal w_DATA_BUS_OUT_A : std_logic_vector(7 downto 0);
	signal w_ALU_REG_OUT_A : std_logic_vector(7 downto 0);
	signal w_REG_DBG_LED_A : std_logic_vector(7 downto 0);
	
	signal w_BI : std_logic;
	signal w_BO : std_logic;
	signal w_DATA_BUS_OUT_B : std_logic_vector(7 downto 0);
	signal w_ALU_REG_OUT_B : std_logic_vector(7 downto 0);
	signal w_REG_DBG_LED_B : std_logic_vector(7 downto 0);
	
	--ALU
	signal w_EO : std_logic;
	signal w_SU : std_logic;
	signal w_CY : std_logic;
	signal w_ZR : std_logic;
	signal w_DATA_BUS_OUT_ALU : std_logic_vector(7 downto 0);
	signal w_ALU_DBG_LED : std_logic_vector(7 downto 0);
	
	--Flags register
	signal w_FI : std_logic;
	signal w_FLAGS : std_logic_vector(1 downto 0);
	signal w_FLAGS_DBG_LED : std_logic_vector(1 downto 0);
	
	--Instruction register controls and output
	signal w_II : std_logic;
	signal w_IO : std_logic;
	signal w_INSTRUCTION : std_logic_vector(3 downto 0);
	signal w_INSTREG_DBG_LED : std_logic_vector(7 downto 0);
	
	--Instruction decoder
	signal w_INST_STEP_DBG_LED : std_logic_vector(2 downto 0);
	signal w_CTRL_WORD_DBG_LED : std_logic_vector(15 downto 0);
	
	--Output register
	signal w_OI : std_logic;
	
	component memory_addr_reg 
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_mi : in std_logic; --Signal to take in the 4 LSB and put it into the register (Active LOW)
			i_data_bus_in : in std_logic_vector(7 downto 0);
			o_addr : out std_logic_vector(3 downto 0) --Outputs the 4 LSB stored in the memory address register
		);
	end component memory_addr_reg;
	
	component single_port_ram
		port(
			i_clkin : in std_logic;
			i_we : in std_logic; --Active LOW
			i_oe : in std_logic; --Active LOW
			i_addr : in std_logic_vector(3 downto 0);
			i_data_bus_in : in std_logic_vector(7 downto 0);
			o_data_bus_out : out std_logic_vector(7 downto 0);
			o_ram_dbg_led : out std_logic_vector(7 downto 0)
		);
	end component single_port_ram;
	
	component prog_counter
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_ce : in std_logic;  --Counter enable (Active LOW)
			i_co : in std_logic;  --Counter output to bus (Active LOW)
			i_j : in std_logic;  --Set the counter to a specfic value by reading in the 4 LSB of the bus (Used in jump instruction) (Active LOW)
			i_data_bus_in : in std_logic_vector(7 downto 0); --All th 8 bits are used but only the 4 LSB are considered
			o_data_bus_out : out std_logic_vector(7 downto 0);
			o_pc_dbg_led : out std_logic_vector(3 downto 0)
		);
	end component prog_counter;
	
	component alu_register
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_we : in std_logic; --Load enable (Active low)
			i_oe : in std_logic; --Write enable (Active low)
			i_data_bus_in: in std_logic_vector (7 downto 0);  --For internal buses seperate buses are used for data in/out
			o_data_bus_out : out std_logic_vector (7 downto 0);  --No tri-state logic internally available on at IO pins
			o_alu_reg_out : out std_logic_vector (7 downto 0); --This is connected to the ALU directly (Always outputs)
			o_reg_dbg_led : out std_logic_vector (7 downto 0)
		);
	end component alu_register;
	
	component alu
		port(
			i_eo : in std_logic;  --Output the result (Active low)
			i_su : in std_logic;  --Subtraction when high and addition when low
			i_a : in std_logic_vector (7 downto 0);
			i_b : in std_logic_vector (7 downto 0);
			o_cy : out std_logic;
			o_zr : out std_logic;
			o_alu_bus_out : out std_logic_vector (7 downto 0);
			o_alu_dbg_led : out std_logic_vector(7 downto 0)
		);
	end component alu;
	
	component flags_reg
		port(
			i_clkin : in std_logic;
			i_reset : in std_logic;
			i_cb : in std_logic; --Carry bit
			i_zb : in std_logic;	--Zero bit
			i_we : in std_logic; --Write to flags register(Active LOW)
			o_flags : out std_logic_vector(1 downto 0);
			o_flags_dbg_led : out std_logic_vector(1 downto 0)
		);
	end component flags_reg;
	
	component instruction_reg
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
	end component instruction_reg;
	
	component instruction_decoder
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
			o_inst_step_dbg_led : out std_logic_vector(2 downto 0);
			o_ctrl_word_dbg_led : out std_logic_vector(15 downto 0)
		);
	end component instruction_decoder;
	
	begin
	
	--Clock input for testing with halt functionality
	w_CLK_1HZ <= i_cpu_clk when(w_HLT = '1') else
					 '0';
	
	--Reset (Button needs to debounced)
	w_RESET <= i_master_rst;

	--Bus connections
	w_DATA_BUS_IN <= w_DATA_BUS_OUT_PC when(w_CO = '0') else
						  w_DATA_BUS_OUT_A when(w_AO = '0') else
						  w_DATA_BUS_OUT_ALU when(w_EO = '0') else
						  w_DATA_BUS_OUT_B when(w_BO = '0') else
						  w_DATA_BUS_OUT_RAM when(w_RO = '0') else
						  w_DATA_BUS_OUT_INR when(w_IO = '0') else
						  (others => '0');
						  
	o_output <= w_ALU_REG_OUT_A; --The final output
					
	pc : prog_counter
		port map(
					i_clkin => w_CLK_1HZ,
					i_reset => w_RESET,
					i_ce => w_CE,
					i_co => w_CO,
					i_j => w_J,
					i_data_bus_in => w_DATA_BUS_IN,
					o_data_bus_out => w_DATA_BUS_OUT_PC,
					o_pc_dbg_led => w_PC_DBG_LED
					);
					
	a_reg : alu_register
		port map(
					i_clkin => w_CLK_1HZ,
					i_reset => w_RESET,
					i_we => w_AI,
					i_oe => w_AO,
					i_data_bus_in => w_DATA_BUS_IN,
					o_data_bus_out => w_DATA_BUS_OUT_A,
					o_alu_reg_out => w_ALU_REG_OUT_A,
					o_reg_dbg_led => w_REG_DBG_LED_A
					);
					
	arith_logic_unit : alu
		port map(
					i_eo => w_EO,
					i_su => w_SU,
					i_a => w_ALU_REG_OUT_A,
					i_b => w_ALU_REG_OUT_B,
					o_cy => w_CY,
					o_zr => w_ZR,
					o_alu_bus_out => w_DATA_BUS_OUT_ALU,
					o_alu_dbg_led => w_ALU_DBG_LED
					);
	
	flags_register : flags_reg
		port map(
					i_clkin => w_CLK_1HZ,
					i_reset => w_RESET,
					i_cb => w_CY,
					i_zb => w_ZR,
					i_we => w_FI,
					o_flags => w_FLAGS,
					o_flags_dbg_led => w_FLAGS_DBG_LED
					);
	
	b_reg : alu_register
		port map(
					i_clkin => w_CLK_1HZ,
					i_reset => w_RESET,
					i_we => w_BI,
					i_oe => w_BO,
					i_data_bus_in => w_DATA_BUS_IN,
					o_data_bus_out => w_DATA_BUS_OUT_B,
					o_alu_reg_out => w_ALU_REG_OUT_B,
					o_reg_dbg_led => w_REG_DBG_LED_B
					);
					
	mem_addr_reg : memory_addr_reg
		port map(
					i_clkin => w_CLK_1HZ,
					i_reset => w_RESET,
					i_mi => w_MI,
					i_data_bus_in => w_DATA_BUS_IN,
					o_addr => w_ADDR
					);
					
	ram : single_port_ram
		port map(
					i_clkin => w_CLK_1HZ,
					i_we => w_RI,
					i_oe => w_RO,
					i_addr => w_ADDR,
					i_data_bus_in => w_DATA_BUS_IN,
					o_data_bus_out => w_DATA_BUS_OUT_RAM,
					o_ram_dbg_led => w_RAM_DBG_LED
					);
	
	inst_reg : instruction_reg
		port map(
					i_clkin => w_CLK_1HZ,
					i_reset => w_RESET,
					i_we => w_II,
					i_oe => w_IO,
					i_data_bus_in => w_DATA_BUS_IN,
					o_data_bus_out => w_DATA_BUS_OUT_INR,
					o_instuction => w_INSTRUCTION,
					o_instreg_dbg_led => w_INSTREG_DBG_LED
					);
					
	inst_decode : instruction_decoder
		port map(
					i_clkin => w_CLK_1HZ,
					i_reset => w_RESET,
					i_instruction => w_INSTRUCTION,
					i_flags => w_FLAGS,
					o_hlt => w_HLT,
					o_mi => w_MI,
					o_ri => w_RI,
					o_ro => w_RO,
					o_io => w_IO,
					o_ii => w_II,
					o_ai => w_AI,
					o_ao => w_AO,
					o_eps => w_EO,
					o_su => w_SU,
					o_bi => w_BI,
					o_bo => w_BO,
					o_oi => w_OI,
					o_ce => w_CE,
					o_co => w_CO,
					o_j  => w_J,
					o_fi => w_FI,
					o_inst_step_dbg_led => w_INST_STEP_DBG_LED, 
					o_ctrl_word_dbg_led => w_CTRL_WORD_DBG_LED
					);

end rtl;