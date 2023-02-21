LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pulsegen IS
    PORT(
        clk     : IN STD_LOGIC;
        step    : OUT STD_LOGIC;
        t1,t2   : OUT STD_LOGIC
    );
END pulsegen;

ARCHITECTURE one OF pulsegen IS
SIGNAL timer: INTEGER RANGE 0 TO 24; -- 根据需要调整
SIGNAL STEP_TEMP : STD_LOGIC;
SIGNAL T1_TEMP : STD_LOGIC;
SIGNAL T2_TEMP : STD_LOGIC;

BEGIN

REG : PROCESS(clk)
    BEGIN
        IF clk'EVENT AND clk = '1' THEN
            IF timer < 24 THEN timer <= timer + 1;
            ELSE timer <= 0;
            END IF;
        END IF;
END PROCESS;

COM : PROCESS(CLK)
BEGIN
    IF timer > 0 and timer < 12 THEN
        STEP_TEMP <= '1';
    END IF;
    IF timer > 4 and timer < 7 THEN
        STEP_TEMP <= '1';
        T1_TEMP <= '1';
        T2_TEMP <= '0';
    END IF;
    IF timer > 9 and timer < 12 THEN
        STEP_TEMP <= '1';
        T1_TEMP <= '0';
        T2_TEMP <= '1';
    END IF;
    IF timer > 12 and timer < 24 THEN
        STEP_TEMP <= '0';
        T1_TEMP <= '0';
        T2_TEMP <= '0';
    END IF;

    IF clk'EVENT AND clk = '1' THEN
        step <= STEP_TEMP;
        t1 <= T1_TEMP;
        t2 <= T2_TEMP;
    END IF;

END PROCESS;

END one;
