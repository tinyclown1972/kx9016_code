library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity REGA_V is
    port (
        a                 : in  std_logic_vector(15 downto 0);
        clk , rst , load  : in  std_logic;
        c_out             : out std_logic_vector(15 downto 0));
end entity REGA_V;

architecture rtl of REGA_V is
begin
   proc_name: process(clk, rst)
   begin
       if rst = '1' then c_out <= "0000000000000000";
       elsif rising_edge(clk) then
            if load = '1' then c_out <= a;
            end if;
       end if;
   end process proc_name;
end architecture rtl;
