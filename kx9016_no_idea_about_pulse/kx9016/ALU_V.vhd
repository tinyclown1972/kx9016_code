LIbRaRY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ALU_V is
    port (
        a , b  : IN std_logic_vector(15 DOWNTO 0);
        sel    : IN std_logic_vector(3 DOWNTO 0);
        c_out  : OUT std_logic_vector(15 DOWNTO 0));
end entity ALU_V;

architecture rtl of ALU_V is

    constant alupass    : std_logic_vector(3 downto 0 ) := "0000";
    constant OP_and     : std_logic_vector(3 downto 0 ) := "0001";
    constant OP_or      : std_logic_vector(3 downto 0 ) := "0010";
    constant OP_not     : std_logic_vector(3 downto 0 ) := "0011";
    constant OP_xor     : std_logic_vector(3 downto 0 ) := "0100";
    constant plus       : std_logic_vector(3 downto 0 ) := "0101";
    constant sub        : std_logic_vector(3 downto 0 ) := "0110";
    constant inc        : std_logic_vector(3 downto 0 ) := "0111";
    constant dec        : std_logic_vector(3 downto 0 ) := "1000";
    constant zero       : std_logic_vector(3 downto 0 ) := "1001";

begin
   process(a ,b ,sel) begin
        case sel is
            when alupass    => c_out <= a;
            when OP_and     => c_out <= a and b;
            when OP_or      => c_out <= a or b ;
            when OP_not     => c_out <= not a;
            when OP_xor     => c_out <= a xor b;
            when plus       => c_out <= a + b;
            when sub        => c_out <= a - b;
            when inc        => c_out <= a+"0000000000000001";
            when dec        => c_out <= a-"0000000000000001";
            when zero       => c_out <= "0000000000000000";
            when others      => c_out <= "0000000000000000";
        end case;
   end process;
end architecture rtl;
