library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is
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
end entity instruction_decoder;

architecture rtl of instruction_decoder is
	
	constant c_INST_MAX_COUNT : natural := 5; --Maximum of 5 microinstruction steps per instrunction
	signal r_INST_STEP_COUNTER : natural range 0 to c_INST_MAX_COUNT;
	
	--The 16 Bits of the control word are arranged in the following word
	--15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0
	--H  M  R  R  I  I  A  A  E  S  B  O  C  C  J  F
	--L  I  I  0  0  I  I  0  0  U  I  I  E  O  -  I
	--T  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	
	--Single microcode
	subtype t_microcode is std_logic_vector(15 downto 0);
	constant c_DFT : t_microcode := "0000000000000000";  --Default when no case match is found
	constant c_HLT : t_microcode := "1000000000000000";
	constant c_MI 	: t_microcode := "0100000000000000";
	constant c_RI	: t_microcode := "0010000000000000";
	constant c_RO 	: t_microcode := "0001000000000000";
	constant c_IO	: t_microcode := "0000100000000000";
	constant c_II	: t_microcode := "0000010000000000";
	constant c_AI	: t_microcode := "0000001000000000";
	constant c_AO	: t_microcode := "0000000100000000";
	constant c_EO	: t_microcode := "0000000010000000";
	constant c_SU	: t_microcode := "0000000001000000";
	constant c_BI	: t_microcode := "0000000000100000";
	constant c_OI	: t_microcode := "0000000000010000";
	constant c_CE 	: t_microcode := "0000000000001000";
	constant c_CO	: t_microcode := "0000000000000100";
	constant c_J	: t_microcode := "0000000000000010";
	constant c_FI	: t_microcode := "0000000000000001";
	
	--Timestep
	subtype t_timestep is std_logic_vector(2 downto 0);
	constant c_T0 : t_timestep := "000";
	constant c_T1 : t_timestep := "001";
	constant c_T2 : t_timestep := "010";
	constant c_T3 : t_timestep := "011";
	constant c_T4 : t_timestep := "100";
	
	--Instructions (OP codes)
	subtype t_instruction is std_logic_vector(3 downto 0);
	constant c_NOP  : t_instruction := "0000"; 	--No OPeration
	constant c_LDA  : t_instruction := "0001"; 	--Load Register A
	constant c_ADD  : t_instruction := "0010"; 	--ADDition
	constant c_SUB  : t_instruction := "0011";	--SUBtraction
	constant c_STA  : t_instruction := "0100"; 	--STore A to RAM
	constant c_LDI  : t_instruction := "0101";	--LoaD Immediate (Put a value directly into A register)
	constant c_JMP  : t_instruction := "0110";	--JuMP to a different address in RAM
	constant c_JC 	 : t_instruction := "0111";	--Jump on Carry
	constant c_JZ 	 : t_instruction := "1000";	--Jump on Zero
	constant c_OUT  : t_instruction := "1110"; 	--OUTput result
	constant c_HALT : t_instruction := "1111"; 	--HALT clock
	
	signal w_inv_clk : std_logic; --The inverted clock
	signal w_inst_step : std_logic_vector(2 downto 0); --The current microstep for the instruction
	
	--Control word that is broken into the different control signals
	signal w_control_word : std_logic_vector(15 downto 0);
	
	function f_INST_DECODER(w_INSTRUCTION : in std_logic_vector(3 downto 0); w_INST_STEP : in std_logic_vector(2 downto 0); w_FLAGS : in std_logic_vector(1 downto 0))
		return std_logic_vector is
		variable v_CONTROL_WORD : std_logic_vector(15 downto 0); --Control lines are active low
		variable v_CF : std_logic;
		variable v_ZF : std_logic;
		
		begin
		
		v_CF := w_FLAGS(0);
		v_ZF := w_FLAGS(1);
		
		--Fetch instruction needs to be run for all the instrunctions
		case w_INST_STEP is
			when c_T0 => v_CONTROL_WORD := not (c_MI or c_CO);
			when c_T1 => v_CONTROL_WORD := not (c_RO or c_II or c_CE);
			when others =>
				case w_INSTRUCTION is
					when c_NOP => --NOP instruction
						v_CONTROL_WORD := not c_DFT;
						
					when c_LDA => --LDA instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not (c_MI or c_IO);
							when c_T3 => v_CONTROL_WORD := not (c_RO or c_AI);
							when others => v_CONTROL_WORD := not c_DFT; --Important to cover all the cases
						end case;
					
					when c_ADD => --ADD instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not (c_MI or c_IO);
							when c_T3 => v_CONTROL_WORD := not (c_RO or c_BI);
							when c_T4 => v_CONTROL_WORD := not (c_AI or c_EO or c_FI); --The sum is loaded into the accumulator (A register) (Flag register is updated)
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
						
					when c_SUB => --SUB instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not (c_MI or c_IO); --Get the address part and put it into memory address register
							when c_T3 => v_CONTROL_WORD := not (c_RO or c_BI); --Put the RAM content the memort address register points to into register B
							when c_T4 => v_CONTROL_WORD := not (c_AI or c_EO or c_SU or c_FI); --When storing the result the subtract bit is set (Flag register is updated)
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
						
					when c_STA => --STA instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not (c_MI or c_IO);
							when c_T3 => v_CONTROL_WORD := not (c_AO or c_RI);
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
						
					when c_LDI => --LDI instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not (c_IO or c_AI); --Only the 4 LSB are used and there a max value of xF can be used
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
						
					when c_JMP => --JMP instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not (c_IO or c_J); --Put the 4 LSB which is the address for next instruction into the PC 
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
						
					when c_JC => --JC instruction
						case w_INST_STEP is
							when c_T2 =>
								if v_CF = '1' then --Jump only if the carry flag is set
									v_CONTROL_WORD := not (c_IO or c_J); --Put new address into the PC to point to new location in RAM for the next instuction
								else
									v_CONTROL_WORD := not c_DFT;
								end if;
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
						
					when c_JZ => --JZ instruction
						case w_INST_STEP is
							when c_T2 =>
								if v_ZF = '1' then --Jump only if the zero flag is set
									v_CONTROL_WORD := not (c_IO or c_J);
								else
									v_CONTROL_WORD := not c_DFT;
								end if;
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
					
					when c_OUT => --OUT instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not (c_AO or c_OI);
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
					
					when c_HALT => --HLT instruction
						case w_INST_STEP is
							when c_T2 => v_CONTROL_WORD := not c_HLT;
							when others => v_CONTROL_WORD := not c_DFT;
						end case;
					
					when others => v_CONTROL_WORD := not c_DFT; --No instruction match
				end case;
		end case;
		
		return std_logic_vector(v_CONTROL_WORD);
		
	end function f_INST_DECODER;
	
	begin
	
	w_inv_clk <= not i_clkin; --Inverting the clock so the control word is changed in between clocks
	w_inst_step <= std_logic_vector(to_unsigned(r_INST_STEP_COUNTER,w_inst_step'length));
	
	w_control_word <= f_INST_DECODER(i_instruction,w_inst_step,i_flags);
	
	o_hlt <= w_control_word(15);
	o_mi 	<= w_control_word(14);
	o_ri 	<= w_control_word(13);
	o_ro 	<= w_control_word(12);
	o_io 	<= w_control_word(11);
	o_ii 	<= w_control_word(10);
	o_ai 	<= w_control_word(9);
	o_ao 	<= w_control_word(8);
	o_eps <= w_control_word(7);
	o_su 	<= w_control_word(6);
	o_bi 	<= w_control_word(5);
	o_bo  <= '1'; --B register out is not used
	o_oi 	<= w_control_word(4);
	o_ce 	<= w_control_word(3);
	o_co 	<= w_control_word(2);
	o_j 	<= w_control_word(1);
	o_fi 	<= w_control_word(0);
	
	--Process to increment the counter
	p_inst_counter : process(w_inv_clk,i_reset) is
		begin
			if i_reset = '0' then
				r_INST_STEP_COUNTER <= 0; --Reset the instruction step counter
			elsif rising_edge(w_inv_clk) then
				if r_INST_STEP_COUNTER = c_INST_MAX_COUNT-1 then
					r_INST_STEP_COUNTER <= 0;
				else
					r_INST_STEP_COUNTER <= r_INST_STEP_COUNTER+1;
				end if;
			end if;
	end process p_inst_counter;
	
	--Debug LED for the current time step for the instruction and control word
	o_inv_clk <= w_inv_clk;
	o_inst_step_dbg_led <= w_inst_step;
	o_ctrl_word_dbg_led <= w_control_word;
	
end rtl;
				
		
	
	

