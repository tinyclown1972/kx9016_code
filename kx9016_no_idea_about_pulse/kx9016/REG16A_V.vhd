library IEEE;
use IEEE.std_logic_1164.all;

entity REG16A_V is
    port (
        a     : in  std_logic_vector(15 downto 0);
        clk   : in  std_logic;
        c_out : out std_logic_vector(15 downto 0));
end entity REG16A_V;

architecture rtl of REG16A_V is
begin
   proc_name: process(clk , a)
   begin
        if(rising_edge(clk)) then c_out <= a; end if;
   end process proc_name;
end architecture rtl;
