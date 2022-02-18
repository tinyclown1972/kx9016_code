LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY CONTRLA IS
   PORT (
      clock       : IN STD_LOGIC;
      reset       : IN STD_LOGIC;
      instrReg    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      -- compout     : IN STD_LOGIC;
      progCntrWr  : OUT STD_LOGIC;
      progCntrRd  : OUT STD_LOGIC;
      addrRegWr   : OUT STD_LOGIC;
      addrRegRd   : OUT STD_LOGIC;
      outRegWr    : OUT STD_LOGIC;
      outRegRd    : OUT STD_LOGIC;
      shiftSel    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      aluSel      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      compSel     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      opRegRd     : OUT STD_LOGIC;
      opRegWr     : OUT STD_LOGIC;
      instrWr     : OUT STD_LOGIC;
      regSel      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      regRd       : OUT STD_LOGIC;
      regWr       : OUT STD_LOGIC;
      rw          : OUT STD_LOGIC;
      vma         : OUT STD_LOGIC
   );
END CONTRLA;

ARCHITECTURE trans OF CONTRLA IS
   CONSTANT shftpass    : std_logic_vector(2 downto 0) := "000";
   CONSTANT alupass     : std_logic_vector(3 downto 0) := "0000";
   CONSTANT zero        : std_logic_vector(3 downto 0) := "1001";
   CONSTANT inc         : std_logic_vector(3 downto 0) := "0111";
   CONSTANT plus        : std_logic_vector(3 downto 0) := "0101";


   type state is (
      reset1 , reset2 , reset3 , execute , load2  , load3  , store2 , store3 ,
      incPC   , incPc2 , incPc3 , loadI2 , loadI3 , loadI4 , loadI5 , loadI6 , inc2   ,
      inc3   , inc4    , move1  , move2  , add2   , add3   , add4
   );

   SIGNAL current_state : state ;
   SIGNAL next_state    : state ;
BEGIN
-- PROCESS (current_state, instrReg, compout)
   PROCESS (current_state, instrReg )
   BEGIN
      -- 每次轮询状态机都会将所有状态清零
      compSel <= "000";
      progCntrWr <= '0';
      progCntrRd <= '0';
      addrRegWr <= '0';
      addrRegRd <= '0';
      outRegWr <= '0';
      outRegRd <= '0';
      shiftSel <= shftpass;
      aluSel <= alupass;
      opRegRd <= '0';
      opRegWr <= '0';
      instrWr <= '0';
      regSel <= "000";
      regRd <= '0';
      regWr <= '0';
      rw <= '0';
      vma <= '0';

      -- 进行当前状态机判断并进行对应微指令操作
      CASE current_state IS
         -- 将复位放在最前面是因为，复位在系统中拥有最高优先级
         WHEN reset1 =>
            aluSel <= zero;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= reset2;
         WHEN reset2 =>
            outRegRd <= '1';
            progCntrWr <= '1';
            addrRegWr <= '1';
            next_state <= reset3;
         WHEN reset3 =>
            vma <= '1';
            rw <= '0';
            instrWr <= '1';
            next_state <= execute;

         -- 随即进行执行指令操作的判断，根据当前指令的命令才可以知道下条指令该干嘛
         WHEN execute =>
            CASE instrReg(15 DOWNTO 11) IS
               -- nop指令，直接跳转下一条指令
               WHEN "00000" =>
                  next_state <= incPc;
               -- 装载数据到寄存器
               WHEN "00001" =>
                  next_state <= load2;
               -- 将寄存器的数值存入存储器
               WHEN "00010" =>
                  next_state <= store2;
               -- 将立即数装入寄存器
               WHEN "00100" =>
                  progCntrRd <= '1';
                  aluSel <= inc;
                  shiftSel <= shftpass;
                  next_state <= loadI2;
               -- 将某个寄存器数值加一后放回
               WHEN "00111" =>
                  next_state <= inc2;
               -- 两个寄存器相加，默认存入R3
               WHEN "01101" =>
                  next_state <= add2;
               -- 在寄存器间传送操作数
               WHEN "00011" =>
                  next_state <= move1;
               -- 其它情况都是nop指令
               WHEN OTHERS =>
                  next_state <= incPc;
            END CASE;

         WHEN load2 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            addrRegWr <= '1';
            next_state <= load3;
         WHEN load3 =>
            vma <= '1';
            rw <= '0';
            regSel <= instrReg(2 DOWNTO 0);
            regWr <= '1';
            next_state <= incPc;
         WHEN add2 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            next_state <= add3;
            opRegWr <= '1';
         WHEN add3 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= plus;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= add4;
         WHEN add4 =>
            regSel <= "011";
            outRegRd <= '1';
            regWr <= '1';
            next_state <= incPc;
         WHEN move1 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            aluSel <= alupass;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= move2;
         WHEN move2 =>
            regSel <= instrReg(2 DOWNTO 0);
            outRegRd <= '1';
            regWr <= '1';
            next_state <= incPc;
         WHEN store2 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            addrRegWr <= '1';
            next_state <= store3;
         WHEN store3 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            rw <= '1';
            next_state <= incPc;
         WHEN loadI2 =>
            progCntrRd <= '1';
            aluSel <= inc;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= loadI3;
         WHEN loadI3 =>
            outRegRd <= '1';
            next_state <= loadI4;
         WHEN loadI4 =>
            outRegRd <= '1';
            progCntrWr <= '1';
            addrRegWr <= '1';
            next_state <= loadI5;
         WHEN loadI5 =>
            vma <= '1';
            rw <= '0';
            next_state <= loadI6;
         WHEN loadI6 =>
            vma <= '1';
            rw <= '0';
            regSel <= instrReg(2 DOWNTO 0);
            regWr <= '1';
            next_state <= incPc;
         WHEN inc2 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= inc;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= inc3;
         WHEN inc3 =>
            outRegRd <= '1';
            next_state <= inc4;
         WHEN inc4 =>
            outRegRd <= '1';
            regSel <= instrReg(2 DOWNTO 0);
            regWr <= '1';
            next_state <= incPc;
         WHEN incPc =>
            progCntrRd <= '1';
            aluSel <= inc;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= incPc2;
         WHEN incPc2 =>
            outRegRd <= '1';
            progCntrWr <= '1';
            addrRegWr <= '1';
            next_state <= incPc3;
         WHEN incPc3 =>
            outRegRd <= '0';
            vma <= '1';
            rw <= '0';
            instrWr <= '1';
            next_state <= execute;
         WHEN OTHERS =>
            next_state <= incPc;
      END CASE;
   END PROCESS;

   PROCESS (clock, reset)
   BEGIN
      -- 复位操作不受时序控制
      IF (reset = '1') THEN
         current_state <= reset1;
      -- 正常的指令操作受到时序控制
      ELSIF (clock'EVENT AND clock = '1') THEN
         current_state <= next_state;
      END IF;
   END PROCESS;


END trans;


