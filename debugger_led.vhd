library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debugger_led is
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
end entity debugger_led;

architecture rtl of debugger_led is
	
	--Required count = 22500
	constant c_REFRESH_DBG_LEDS : natural := 22500;
	signal r_REFRESH_DBG_COUNTER : natural range 0 to c_REFRESH_DBG_LEDS := 0;
	
	constant c_MAX_REFRESH_ITEMS : natural := 12; --The number of items to be refreshed
	signal r_REFRESH_ITEM : natural range 0 to c_MAX_REFRESH_ITEMS := 0; --Register to keep track of what item is being updated
	signal r_CUR_ITEM : std_logic_vector(11 downto 0) := "000000000001";
	
	begin
	
	p_refresh_items : process(i_mclk) is
		begin
			if rising_edge(i_mclk) then
				if r_REFRESH_DBG_COUNTER = c_REFRESH_DBG_LEDS-1 then
					
					if r_REFRESH_ITEM = c_MAX_REFRESH_ITEMS-1 then
						r_REFRESH_ITEM <= 0; --Reset the current item to 0
						r_CUR_ITEM <= "000000000001"; --Reset the activation to the first item
					else
						r_REFRESH_ITEM <= r_REFRESH_ITEM+1;
					end if;
					
					r_REFRESH_DBG_COUNTER <= 0; --Reset the refresh counter
					
					--Refreshing each of the items in sequence
					case r_REFRESH_ITEM is
						when 0 => 
							o_act_led_bus <= r_CUR_ITEM;
							o_muxed_dbg_led_bus(3 downto 0) <= i_pc_dbg;
						when 1 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),1));
							o_muxed_dbg_led_bus(7 downto 0) <= i_a_reg_dbg;
						when 2 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),2));
							o_muxed_dbg_led_bus(7 downto 0) <= i_alu_reg_dbg;
						when 3 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),3));
							o_muxed_dbg_led_bus(1 downto 0) <= i_flags_reg_dbg;
						when 4 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),4));
							o_muxed_dbg_led_bus(7 downto 0) <= i_b_reg_dbg;
						when 5 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),5));
							o_muxed_dbg_led_bus(3 downto 0) <= i_mem_addr_dbg;
						when 6 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),6));
							o_muxed_dbg_led_bus(7 downto 0) <= i_ram_content_dbg;
						when 7 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),7));
							o_muxed_dbg_led_bus(7 downto 0) <= i_inst_reg_dbg;
						when 8 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),8));
							o_muxed_dbg_led_bus(2 downto 0) <= i_inst_step_dbg; 
						when 9 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),9));
							o_muxed_dbg_led_bus(7 downto 0) <= i_ctrl_word_dbg(7 downto 0);
						when 10 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),10));
							o_muxed_dbg_led_bus(7 downto 0) <= i_ctrl_word_dbg(15 downto 8);
						when 11 => 
							o_act_led_bus <= std_logic_vector(shift_left(unsigned(r_CUR_ITEM),11));
							o_muxed_dbg_led_bus(7 downto 0) <= i_bus_dbg;
						when others => 
							o_act_led_bus <= "000000000000";
					end case;
					
				else
					r_REFRESH_DBG_COUNTER <= r_REFRESH_DBG_COUNTER+1; --Incrementing the refresh counter
				end if;
			end if;
	end process p_refresh_items;
	
end rtl;