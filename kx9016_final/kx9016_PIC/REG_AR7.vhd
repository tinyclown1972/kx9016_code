LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

ENTITY REG_AR7 IS
   PORT (
      data  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      sel   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      clk   : IN STD_LOGIC;
      q     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
END REG_AR7;

ARCHITECTURE trans OF REG_AR7 IS
   TYPE type_xhdl0 IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);

   SIGNAL ramdata : type_xhdl0;
BEGIN
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         ramdata(CONV_INTEGER(sel)) <= data;
      END IF;
   END PROCESS;

   q <= ramdata(CONV_INTEGER(sel));

END trans;


