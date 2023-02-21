library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity COMP_V is
    port (
        a , b : in std_logic_vector(15 downto 0);
        sel   : in std_logic_vector(2 downto 0);
        c_out : out std_logic);
end entity COMP_V;

architecture rtl of COMP_V is

    constant eq     : std_logic_vector(2 downto 0) := "000";
    constant neq    : std_logic_vector(2 downto 0) := "001";
    constant gt     : std_logic_vector(2 downto 0) := "010";
    constant gte    : std_logic_vector(2 downto 0) := "011";
    constant lt     : std_logic_vector(2 downto 0) := "100";
    constant lte    : std_logic_vector(2 downto 0) := "101";

begin
   proc_name: process(a , b , sel) begin
        case sel is
            when eq  => if (a=b)  then c_out <= '1'; else c_out <= '0'; end if;
            when neq => if (a/=b) then c_out <= '1'; else c_out <= '0'; end if;
            when gt  => if (a>b)  then c_out <= '1'; else c_out <= '0'; end if;
            when gte => if (a>=b) then c_out <= '1'; else c_out <= '0'; end if;
            when lt  => if (a<b)  then c_out <= '1'; else c_out <= '0'; end if;
            when lte => if (a<=b) then c_out <= '1'; else c_out <= '0'; end if;
            when others => c_out <= '0';
        end case;
   end process proc_name;
end architecture rtl;

