LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY REG8_V IS
   PORT (
      a    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      en , clk , rst   : IN STD_LOGIC;
      q    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
END REG8_V;

ARCHITECTURE trans OF REG8_V IS
   SIGNAL val : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
   PROCESS (clk, rst)
   BEGIN
      IF (rst = '1') THEN
         val <= "0000000000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         val <= a;
      END IF;
   END PROCESS;

   PROCESS (en, val)
   BEGIN
      IF (en = '1') THEN
         q <= val;
      ELSE
         q <= "ZZZZZZZZZZZZZZZZ";
      END IF;
   END PROCESS;
END trans;


