library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stand_test_tb is
end entity stand_test_tb;

architecture stand_test_tb_behav of stand_test_tb is
	SIGNAL s_CLK:		std_logic;
	SIGNAL s_IMP_LAS:	std_logic:='1';
	SIGNAL s_IMP_GEN:	std_logic:='0';
	SIGNAL s_OUT_IMP:	std_logic_vector(63 downto 0);


	SIGNAL s_BTN_VOLT:	std_logic:='0';
	SIGNAL s_BTN_FREQ:	std_logic:='0';

	SIGNAL s_VOLT_MODE:	std_logic_vector(1 downto 0);
	SIGNAL s_VOLT_MODE_STRB:	std_logic;

	SIGNAL s_VOLT_CNRT:	std_logic_vector(6 downto 0):="0101010";
	SIGNAL s_VOLT_CNRT_STRB:	std_logic:='0';

	SIGNAL s_LEDS:		std_logic_vector(6 downto 0);


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

	module_stand_test: stand_test port map (s_CLK,
										--	s_IMP_LAS,
										--	s_IMP_GEN,
										--	s_OUT_IMP,
											s_VOLT_MODE,
											s_VOLT_MODE_STRB,
											s_VOLT_CNRT,
											s_VOLT_CNRT_STRB,
											s_BTN_VOLT,
										--	s_BTN_FREQ,
											s_LEDS
											);

	
	process 
	begin
		s_CLK<='1';
		wait for 1 ns;
		s_CLK<='0';
		wait for 1 ns;
	end process;



	process 
	begin
		s_BTN_VOLT<='0';
		s_BTN_FREQ<='0';
		wait for 10 ns;
		s_BTN_FREQ<='1';
		s_BTN_VOLT<='1';
		wait for 5 ns;
		s_BTN_FREQ<='0';
		s_BTN_VOLT<='0';
		wait;
		--wait for 42000 ns;
	end process;


	process
	begin	
		s_VOLT_CNRT_STRB<='0';
		wait until s_VOLT_MODE_STRB='1';
		wait for 200 ns;
		s_VOLT_CNRT<=s_VOLT_CNRT+'1';
		wait for 10 ns;
		s_VOLT_CNRT_STRB<='1';
		wait for 5 ns;
	end process;


	process
	begin
		s_IMP_GEN<='0';
		s_IMP_LAS<='1';
		wait for 30 ns;
		s_IMP_GEN<='1';
		wait for 5 ns;
		s_IMP_GEN<='0';
		wait for 10 ns;
		s_IMP_LAS<='0';
		wait for 5 ns;
		s_IMP_LAS<='1';
		wait for 30 ns;
	end process;




	
end architecture stand_test_tb_behav;
