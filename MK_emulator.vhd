library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MK_emulator is
	port (	p_CLK:			in std_logic;
			p_MODE:			in std_logic_vector(1 downto 0);
			p_MODE_STRB:	in std_logic;
			p_VOLTAGE:		out std_logic_vector(6 downto 0);
			p_VOLTAGE_STRB:	out std_logic
			);
end entity MK_emulator;

architecture MK_emulator_behav of MK_emulator is

	SIGNAL s_MODE_STRB_FILTER: 	std_logic_vector(3 downto 0);
	SIGNAL s_CURR_MODE:			std_logic_vector(1 downto 0);
	SIGNAL s_CURR_VOLTAGE:		std_logic_vector(6 downto 0):="0000000";
	SIGNAL s_INP_MODE_FLAG:		std_logic:='0';
	SIGNAL s_CNT:				integer:=200;


begin

	process(p_CLK)
	begin
		if rising_edge(p_CLK) then

			s_MODE_STRB_FILTER(2 downto 0)<=s_MODE_STRB_FILTER(3 downto 1);
			s_MODE_STRB_FILTER(3)<=p_MODE_STRB;

			if s_MODE_STRB_FILTER(0)='1' and s_MODE_STRB_FILTER(1)='0' then
				s_CURR_MODE<=p_MODE;
				s_INP_MODE_FLAG<='1';
				s_CNT<=100;
			end if;


			if s_INP_MODE_FLAG='1' then
				if s_CNT=0 then
					s_CNT<=199;
					p_VOLTAGE_STRB<='0';
					s_INP_MODE_FLAG<='0';
				elsif s_CNT>50 then
					s_CNT<=s_CNT - 1;
					p_VOLTAGE_STRB<='0';
					s_CURR_VOLTAGE(6)<=s_CURR_MODE(1);
					s_CURR_VOLTAGE(5)<=s_CURR_MODE(0);
					s_CURR_VOLTAGE(4)<=s_CURR_MODE(1);
					s_CURR_VOLTAGE(3)<=s_CURR_MODE(0);
					s_CURR_VOLTAGE(2)<=s_CURR_MODE(1);
					s_CURR_VOLTAGE(1)<=s_CURR_MODE(0);
					s_CURR_VOLTAGE(0)<=s_CURR_MODE(1);
					p_VOLTAGE<=s_CURR_VOLTAGE;
				elsif s_CNT>0 and s_CNT<=50 then
					s_CNT<=s_CNT - 1;
					p_VOLTAGE_STRB<='1';
				end if;

			end if;

			

		end if;

	end process;
	
end architecture MK_emulator_behav;