library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity FDIV_1k is

port( clk : IN std_logic;
	  f_out       : OUT std_logic
	 );

end FDIV_1k;


architecture one of FDIV_1k is

	signal f : std_logic;
	signal C : integer range 50000000 downto 0;

begin

	process(clk) begin
		if clk'event and clk = '1' then
			if C < 3 then C <= C + 1;
			else f <= not f; C <= 0;
			end if;
		end if;
	end process;
	f_out <= f;

end one;