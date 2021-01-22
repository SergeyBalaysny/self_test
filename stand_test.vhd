-- модуль тестирования правильности работы стенда в части корректрого анализа выходных сигналов блока
-- имитирует работу блока в плане корректной реакции на поступающие входные сигналы
-- схема проверяет последовательность поступления пар сигналов и ведет их подсчет, при этом на одной из 64 выходных 
-- линий формируется выходной импульс отрицательной полярности. номер линии на которой формируется выходной импульс
-- соответсвует количеству пришедших в систему пар входных импульсов 

-- входные сигналы
-- p_IN_IMP_LAS - импульс запуска лазера - сигнал положительной полярности
-- p_IN_IMP_GEN - импульс запуска генератора - сигнал отрицательной полярности

-- выходные сигналы
-- p_OUT_IMP - импульсы длительностью 2,5 мкс каждый

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stand_test is
	port (		p_CLK:				in std_logic;
				--p_IN_IMP_LAS:			in std_logic;								-- вход \ сигнал запуска лазера
				--p_IN_IMP_GEN:			in std_logic;								-- вход \ сигнал запуска генератора
				--p_OUT_IMP:				out std_logic_vector(63 downto 0);	-- выход \ имитация выхродного импульса блока по одному из каналов

				p_VOLTAGE_MODE:		out std_logic_vector(1 downto 0);	-- выход \ режим работы напряжений стенда 00 - номинал	
																							-- 01 - пониженное, 10 - повышенное
				p_VOLTAGE_MODE_STRB:	out std_logic;								-- строб выставления режиа работы на выходе

				p_VOLTAGE:				in std_logic_vector(6 downto 0);		-- вход \ результат проверки напряжений МК в каждом из режимов 1 - прошло, 0 - не прошло
				p_VOLTAGE_STRB:		in std_logic;								-- вход \ строб высталенния МК результатов проверки напряжений

				p_BTN_VOLT_CNTR:		in std_logic;								-- вход \ кнопка запуск проверки напржений питания стенда
				--p_BTN_FREQ_CNTR:		in std_logic; 								-- вход \ кнопка запуск проверки детектора импульсов стенда

				p_LED_OUT:				out std_logic_vector(6 downto 0)

			);
end entity;

architecture stand_test_behav of stand_test is

	type t_state is (st_gen, st_las, st_imp, st_end);				--	состоянии конечного автомат проверки импульсного детектора
	SIGNAL s_FSM:t_state;

	SIGNAL s_CNT:					integer range 0 to 100:=0;	
	SIGNAL s_IMP_CNT:				integer range 0 to 63:=0;			-- количество выдаваемых импульсов при проверки импульсоного деиектора

	SIGNAL s_OUT_PORT:			std_logic_vector(63 downto 0):=x"FFFFFFFFFFFFFFFE";	-- имитация сигналов блока при работе
	SIGNAL s_LAS_FILTER:			std_logic_vector(4 downto 0);		-- фильтр импульса запуска лазера
	SIGNAL s_GEN_FILTER:			std_logic_vector(4 downto 0);		-- фильтр импульма запуска генеретора


	SIGNAL s_SELECT_MODE_VOLATGE:	std_logic:='0';		
	SIGNAL s_SELECT_MODE_FREQ:		std_logic:='0';

	SIGNAL s_VOLTAGE_MODE:			std_logic_vector(1 downto 0):="00";	-- режим проверки напряжений

	SIGNAL s_VOLTAGE_STRB_FILTER:	std_logic_vector(3 downto 0);			-- фильтр строба результатов проверки напряжений
	SIGNAL s_VOLTAGE_VALUE:			std_logic_vector(6 downto 0):="0000000";		-- результат проверки напряжений


	type t_voltage_fsm_state is (st_write_mode, st_read_data, st_set_new_mode);
	SIGNAL s_VOLTAGE_FSM: t_voltage_fsm_state;
	
	SIGNAL s_BTN_VOLTAGE_FILTER: std_logic_vector(3 downto 0);

begin
	process (p_CLK)
	begin
		if rising_edge(p_CLK) then
-- выбор типа проверки, в завичимости от нажатой кнопки
			s_BTN_VOLTAGE_FILTER(2 downto 0)<=s_BTN_VOLTAGE_FILTER(3 downto 1);
			s_BTN_VOLTAGE_FILTER(3)<=p_BTN_VOLT_CNTR;
			
			--if p_BTN_VOLT_CNTR='0' then
			if s_BTN_VOLTAGE_FILTER(1)='1' and s_BTN_VOLTAGE_FILTER(0)='0' then
				s_SELECT_MODE_VOLATGE<='1';
				s_VOLTAGE_VALUE<="0000000";
				s_VOLTAGE_MODE<="00";
				s_CNT<=0;
			end if;

--			if p_BTN_FREQ_CNTR='0' then
--				s_SELECT_MODE_FREQ<='1';
--				s_OUT_PORT<=x"FFFFFFFFFFFFFFFE";
--			end if;
			p_LED_OUT<=s_VOLTAGE_VALUE;


-- проверка питающих напряжений в рахличных режимах
			if s_SELECT_MODE_VOLATGE='1' then
				
				case s_VOLTAGE_FSM is
					when st_write_mode => 	p_VOLTAGE_MODE<=s_VOLTAGE_MODE;
													if s_CNT=99 then 
														s_CNT<=0;
														p_VOLTAGE_MODE_STRB<='1';
														s_VOLTAGE_FSM<=st_read_data;
													else
														s_CNT<=s_CNT+1;
														p_VOLTAGE_MODE_STRB<='0';
													end if;

					when st_read_data => 	s_VOLTAGE_STRB_FILTER(2 downto 0)<=s_VOLTAGE_STRB_FILTER(3 downto 1);
													s_VOLTAGE_STRB_FILTER(3)<=p_VOLTAGE_STRB;

													if (s_VOLTAGE_STRB_FILTER(0)='1') and (s_VOLTAGE_STRB_FILTER(1)='0') then
														s_VOLTAGE_VALUE<=p_VOLTAGE;
														s_VOLTAGE_FSM<=st_set_new_mode;
														p_VOLTAGE_MODE_STRB<='0';
													end if;

					when st_set_new_mode => if s_VOLTAGE_MODE="10" then 
														s_SELECT_MODE_VOLATGE<='0';
														s_VOLTAGE_MODE<="11";
														p_LED_OUT<="0000000";
													else
														s_VOLTAGE_MODE<=s_VOLTAGE_MODE+'1';
														s_VOLTAGE_FSM<=st_write_mode;
													end if;
													
					when others =>		s_VOLTAGE_FSM<=st_write_mode;
				end case;

			end if;

-- проверка стенда на сарабатывание от пачек импульсов 
--			if s_SELECT_MODE_FREQ='1' then
--				s_LAS_FILTER(2 downto 0)<=s_LAS_FILTER(3 downto 1);
--				s_LAS_FILTER(3)<=p_IN_IMP_LAS;
--				s_GEN_FILTER(2 downto 0)<=s_GEN_FILTER(3 downto 1);
--				s_GEN_FILTER(3)<=p_IN_IMP_GEN;
--
--				case s_FSM is
--					when st_gen =>	if (s_GEN_FILTER(0)='1') and (s_GEN_FILTER(1)='0') then
--											s_FSM<=st_las;
--										end if;
--
--					when st_las =>	if (s_LAS_FILTER(0)='0') and (s_LAS_FILTER(1)='1') then
--											s_CNT<=0;
--											s_FSM<=st_imp;
--										end if;
--
--					when st_imp =>	if (s_CNT=300) then
--											p_OUT_IMP<=(others=>'1');
--											s_FSM<=st_end;
--										else
--											s_CNT<=s_CNT + 1;
--											p_OUT_IMP<=s_OUT_PORT;
--											s_FSM<=st_imp;
--										end if;
--
--					when st_end =>	s_OUT_PORT<=s_OUT_PORT(62 downto 0) & s_OUT_PORT(63);
--										if s_IMP_CNT=63 then 
--											s_IMP_CNT<=0;
--											s_SELECT_MODE_FREQ<='0';
--										else 
--											s_IMP_CNT<=s_IMP_CNT+1;
--											--s_FSM <= st_gen;
--										end if;
--										s_FSM <= st_gen;
--					when others => s_FSM<=st_gen;
--
--				end case;
--			end if;

		end if;
	end process;
	
end architecture stand_test_behav;	