LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY SFT4A IS
   PORT (
      a         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      sel       : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      y         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
END SFT4A;

ARCHITECTURE trans OF SFT4A IS
   constant shftpass  : std_logic_vector(2 downto 0 ) := "000";
   constant sftl      : std_logic_vector(2 downto 0 ) := "001";
   constant sftr      : std_logic_vector(2 downto 0 ) := "010";
   constant rotl      : std_logic_vector(2 downto 0 ) := "011";
   constant rotr      : std_logic_vector(2 downto 0 ) := "100";
BEGIN
   PROCESS (a, sel)
   BEGIN
      CASE sel IS
         WHEN shftpass =>
            y <= a;
         WHEN sftl =>
            y <= (a(14 DOWNTO 0) & '0');
         WHEN sftr =>
            y <= ('0' & a(15 DOWNTO 1));
         WHEN rotl =>
            y <= (a(14 DOWNTO 0) & a(15));
         WHEN rotr =>
            y <= (a(0) & a(15 DOWNTO 1));
         WHEN OTHERS =>
            y <= "0000000000000000";
      END CASE;
   END PROCESS;
END trans;


