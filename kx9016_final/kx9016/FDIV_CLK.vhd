library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity FDIV_CLK is

port( clk : IN std_logic;
	  f_out       : OUT std_logic
	 );

end FDIV_CLK;


architecture one of FDIV_CLK is

	signal f : std_logic;
	signal C : integer range 1250000 downto 0;

begin

	process(clk) begin
		if clk'event and clk = '1' then
			if C < 1249999 then C <= C + 1;
			else f <= not f; C <= 0;
			end if;
		end if;
	end process;
	f_out <= f;
end one;
