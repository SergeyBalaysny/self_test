library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MK_emulator_tb is
end entity MK_emulator_tb;

architecture MK_emulator_tb_bahav of MK_emulator_tb is

	SIGNAL s_CLK:		std_logic;
	SIGNAL s_MODE:		std_logic_vector(1 downto 0):="00";
	SIGNAL s_MODE_ST:	std_logic;
	SIGNAL s_VOLT:		std_logic_vector(6 downto 0);
	SIGNAL s_VLT_STR:	std_logic;

	SIGNAL s_CNT:		integer:=0;


component MK_emulator is
	port (	p_CLK:			in std_logic;
			p_MODE:			in std_logic_vector(1 downto 0);
			p_MODE_STRB:	in std_logic;
			p_VOLTAGE:		out std_logic_vector(6 downto 0);
			p_VOLTAGE_STRB:	out std_logic
			);
end component;

begin

		MK_emul_mode: MK_emulator port map (s_CLK,
											s_MODE,
											s_MODE_ST,
											s_VOLT,
											s_VLT_STR
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
			if s_CNT=0 then
				s_MODE<="00";
			elsif s_CNT=1 then
				s_MODE<="01";
			elsif s_CNT=2 then
				s_MODE<="10";
			else
				s_CNT<=0;
			end if;

			
			s_MODE_ST<='0';
			wait for 20 ns;
			s_MODE_ST<='1';
			wait for 10 ns;
			s_MODE_ST<='0';
			s_CNT<=s_CNT + 1;
			wait for 400 ns;
		end process;

end architecture MK_emulator_tb_bahav;