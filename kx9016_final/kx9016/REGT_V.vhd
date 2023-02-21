library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity REGT_V is

    port (
        a               : in  std_logic_vector(15 downto 0);
        clk , rst , en  : in  std_logic;
        c_out           : out std_logic_vector(15 downto 0));

end entity REGT_V;

architecture rtl of REGT_V is
    signal v1 : std_logic_vector(15 downto 0);
begin
   proc_name: process(clk, rst , a)
   begin
       if rst = '1' then v1 <= "0000000000000000";
       elsif rising_edge(clk) then v1 <= a;
       end if;
   end process proc_name;

  proc_name1: process(en, v1)
  begin
      if en = '1' then c_out <= v1;
      else c_out <= "ZZZZZZZZZZZZZZZZ";
      end if;
  end process proc_name1;
end architecture rtl;
