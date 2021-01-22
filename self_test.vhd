library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity self_test is
	port (	p_CLK:				in std_logic;
			p_MK_MODE:			in std_logic_vector(1 downto 0);
			p_MK_MODE_SRTB:		in std_logic;
			p_MK_VOLT:			out std_logic_vector(6 downto 0);
			p_MK_VOLT_STRB:		out std_logic;

			p_FPGA_MODE:		out std_logic_vector(1 downto 0);
			p_FPGA_MODE_STRB:	out std_logic;
			p_FPGA_VOLT:		in std_logic_vector(6 downto 0);
			p_FPGA_VOLT_STRB:	in std_logic;

			p_FPGA_BTN_VLT:		in std_logic;
			p_FPGA_LED:			out std_logic_vector(6 downto 0)
		);
end entity;

architecture self_test_behav of self_test is
	
	SIGNAL s_MODE: std_logic_vector(1 downto 0);
	SIGNAL s_MODE_STRB:	std_logic;
	SIGNAL s_VOLT:	std_logic_vector(6 downto 0);
	SIGNAL s_VOLT_STRB:	std_logic;
	
	
	component MK_emulator is
	port (	p_CLK:			in std_logic;
			p_MODE:			in std_logic_vector(1 downto 0);
			p_MODE_STRB:	in std_logic;
			p_VOLTAGE:		out std_logic_vector(6 downto 0);
			p_VOLTAGE_STRB:	out std_logic
			);
	end component;

	component stand_test is
	port (		p_CLK:				in std_logic;
--				p_IN_IMP_LAS:		in std_logic;								-- вход \ сигнал запуска лазера
--				p_IN_IMP_GEN:		in std_logic;								-- вход \ сигнал запуска генератора
--				p_OUT_IMP:			out std_logic_vector(63 downto 0);			-- выход \ имитация выхродного импульса блока по одному из каналов

				p_VOLTAGE_MODE:		out std_logic_vector(1 downto 0);			-- выход \ режим работы напряжений стенда 00 - номинал	
																				-- 01 - пониженное, 10 - повышенное
				p_VOLTAGE_MODE_STRB:out std_logic;								-- строб выставления режиа работы на выходе

				p_VOLTAGE:			in std_logic_vector(6 downto 0);			-- вход \ результат проверки напряжений МК в каждом из режимов 1 - прошло, 0 - не прошло
				p_VOLTAGE_STRB:		in std_logic;								-- вход \ строб высталенния МК результатов проверки напряжений

				p_BTN_VOLT_CNTR:	in std_logic;								-- вход \ кнопка запуск проверки напржений питания стенда
--				p_BTN_FREQ_CNTR:	in std_logic; 								-- вход \ кнопка запуск проверки детектора импульсов стенда
				p_LED_OUT:			out std_logic_vector(6 downto 0) 
				);
	end component;

begin

	mk_emulator_module: MK_emulator port map (	p_CLK,	
--												p_MK_MODE,
--												p_MK_MODE_SRTB,
--												MK_VOLT,
--												p_MK_VOLT_STRB
												s_MODE, s_MODE_STRB, s_VOLT, s_VOLT_STRB
											);

	fpga_emulator_module: stand_test port map (	p_CLK,
--												p_FPGA_MODE,
--												p_FPGA_MODE_STRB,
--												p_FPGA_VOLT,
--												p_FPGA_VOLT_STRB,
												s_MODE, s_MODE_STRB, s_VOLT, s_VOLT_STRB,
												p_FPGA_BTN_VLT,
												p_FPGA_LED
										 	);

end architecture self_test_behav;