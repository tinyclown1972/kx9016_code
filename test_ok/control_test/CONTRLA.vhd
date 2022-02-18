LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY CONTRLA IS
   PORT (
      clock       : IN STD_LOGIC;
      reset       : IN STD_LOGIC;
      instrReg    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      compout     : IN STD_LOGIC;
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

   -- shift
   constant shftpass  : std_logic_vector(2 downto 0 ) := "000";
   constant sftl      : std_logic_vector(2 downto 0 ) := "001";
   constant sftr      : std_logic_vector(2 downto 0 ) := "010";
   constant rotl      : std_logic_vector(2 downto 0 ) := "011";
   constant rotr      : std_logic_vector(2 downto 0 ) := "100";

   -- comp
   constant eq     : std_logic_vector(2 downto 0) := "000";
   constant neq    : std_logic_vector(2 downto 0) := "001";
   constant gt     : std_logic_vector(2 downto 0) := "010";
   constant gte    : std_logic_vector(2 downto 0) := "011";
   constant lt     : std_logic_vector(2 downto 0) := "100";
   constant lte    : std_logic_vector(2 downto 0) := "101";

   -- alu
   constant OP_and      : std_logic_vector(3 downto 0 )  := "0001";
   constant OP_or       : std_logic_vector(3 downto 0 )  := "0010";
   constant OP_not      : std_logic_vector(3 downto 0 )  := "0011";
   constant OP_xor      : std_logic_vector(3 downto 0 )  := "0100";
   constant sub         : std_logic_vector(3 downto 0 )  := "0110";
   constant dec         : std_logic_vector(3 downto 0 )  := "1000";
   CONSTANT alupass     : std_logic_vector(3 downto 0)   := "0000";
   CONSTANT zero        : std_logic_vector(3 downto 0)   := "1001";
   CONSTANT inc         : std_logic_vector(3 downto 0)   := "0111";
   CONSTANT plus        : std_logic_vector(3 downto 0)   := "0101";


   type state is (
      reset1 , reset2 , reset3 , execute , load2  , load3  , store2 , store3 ,
      incPC  , incPc2 , incPc3 , loadI2  , loadI3 , loadI4 , loadI5 , loadI6 ,
      inc2   , inc3   , inc4   , move1   , move2  , add2   , add3   , add4   ,
      jmpeq1 , jmpeq2 , jmpeq3 , jmpeq4  , jmpeq5 , jmpeq6 , jmpeq7 , jmplt1 ,
      jmplt2 , jmplt3 , jmplt4 , jmplt5  , jmplt6 , jmplt7 , jmpgt1 , jmpgt2 ,
      jmpgt3 , jmpgt4 , jmpgt5 , jmpgt6  , jmpgt7 , jmp1   , jmp2   , jmp3   ,
      jmp4   , loadPc1, loadPc2, shftl1  , shftl2 , shftr1 , shftr2 , rotl1  ,
      rotl2  , rotr1  , rotr2  , dec2    , dec3   , dec4   , and2   , and3   ,
      and4   , or2    , or3    , or4     , xor2   , xor3   , xor4   , not2   ,
      not3   , not4   , sub2   , sub3    , sub4

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

               -- 在寄存器间传送操作数
               WHEN "00011" =>
                  next_state <= move1;

               -- 将立即数装入寄存器
               WHEN "00100" =>
                  progCntrRd <= '1';
                  aluSel <= inc;
                  shiftSel <= shftpass;
                  next_state <= loadI2;

               -- 转移到立即数地址
               WHEN "00101" =>
                  next_state <= jmp1;

               -- 条件转移指令，大于跳转
               WHEN "00110" =>
                  next_state <= jmpgt1;

               -- 将某个寄存器数值加一后放回
               WHEN "00111" =>
                  next_state <= inc2;

               -- 将某个寄存器数值减一后放回
               WHEN "01000" =>
                  next_state <= dec2;

               -- 两个寄存器相与，默认存入R3
               WHEN "01001" =>
                  next_state <= and2;

               -- 两个寄存器相或，默认存入R3
               WHEN "01010" =>
                  next_state <= or2;

               -- 两个寄存器相异或，默认存入R3
               WHEN "01011" =>
                  next_state <= xor2;

               -- 寄存器取反
               WHEN "01100" =>
                  next_state <= not2;

               -- 两个寄存器相加，默认存入R3
               WHEN "01101" =>
                  next_state <= add2;

               -- 两个寄存器相减，默认存入R3
               WHEN "01110" =>
                  next_state <= sub2;

               -- JMPLT指令，小于跳转
               WHEN "10000" =>
                  next_state <= jmplt1;

               -- JMPGT指令，大于跳转
               WHEN "10001" =>
                  next_state <= jmpgt1;

               -- JMPI指令，立即跳转
               WHEN "10101" =>
                  next_state <= jmp1;

               -- JMPE指令，相等跳转
               WHEN "10110" =>
                  next_state <= jmpeq1;

               -- JMPLTE指令，小于等于跳转
               WHEN "11001" =>
                  next_state <= jmplt1;

               -- SHL指令，左移一位
               WHEN "11010" =>
                  next_state <= shftl1;

               -- SHR指令，右移一位
               WHEN "11011" =>
                  next_state <= shftr1;

               -- ROTR指令，循环右移一位
               WHEN "11100" =>
                  next_state <= rotr1;

               -- ROTL指令，循环左移一位
               WHEN "11101" =>
                  next_state <= rotl1;


               WHEN OTHERS =>
                  next_state <= incPc;
            END CASE;


         ----------------------------------------------
         --JMPEQI 等于跳转指令
         when jmpeq1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmpeq2;   --读程序寄存器中的值，至ALU加1成双字指令第二字的RAM地址，通过移位器写入输出寄存器
         when jmpeq2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmpeq3;   --指令第二字RAM地址从输出寄存器读到总线，并且从总线写回程序计数器和地址寄存器
         when jmpeq3 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmpeq4;   --读源寄存器中的值，通过总线写入工作寄存器，送至比较器A输入端
         when jmpeq4 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= eq;
            next_state <= jmpeq5;  --读目的寄存器的值，通过总线送至比较器B输入端，AB输入运行等于比较
         when jmpeq5 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= eq;
            if compout = '1' then
               next_state <= jmpeq6;   --等于比较成立，次态进入jmpeq6，读取转移地址
            else
               next_state <= incPc;       --等于比较不成立，次态进入顺序指令公共流程incPc，取下一指令
            end if;
         when jmpeq6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmpeq7; --读取RAM中保存的转移地址到总线（注意要延迟T1+RAM读时间后才有效）
         when jmpeq7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --转移地址写入程序寄存器（因为该寄存器的写入仅延时T1，不能在jmpeq6状态进行）

         ----------------------------------------------
         --JMPLTI 等于跳转指令
         when jmplt1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmplt2;   --读程序寄存器中的值，至ALU加1成双字指令第二字的RAM地址，通过移位器写入输出寄存器
         when jmplt2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmplt3;   --指令第二字RAM地址从输出寄存器读到总线，并且从总线写回程序计数器和地址寄存器
         when jmplt3 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmplt4;   --读源寄存器中的值，通过总线写入工作寄存器，送至比较器A输入端
         when jmplt4 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= lt;
            next_state <= jmplt5;  --读目的寄存器的值，通过总线送至比较器B输入端，AB输入运行等于比较
         when jmplt5 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= lt;
            if compout = '1' then
               next_state <= jmplt6;   --等于比较成立，次态进入jmpeq6，读取转移地址
            else
               next_state <= incPc;       --等于比较不成立，次态进入顺序指令公共流程incPc，取下一指令
            end if;
         when jmplt6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmplt7; --读取RAM中保存的转移地址到总线（注意要延迟T1+RAM读时间后才有效）
         when jmplt7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --转移地址写入程序寄存器（因为该寄存器的写入仅延时T1，不能在jmpeq6状态进行）

         ----------------------------------------------
         --JMPGTI 等于跳转指令
         when jmpgt1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmpgt2;   --读程序寄存器中的值，至ALU加1成双字指令第二字的RAM地址，通过移位器写入输出寄存器
         when jmpgt2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmpgt3;   --指令第二字RAM地址从输出寄存器读到总线，并且从总线写回程序计数器和地址寄存器
         when jmpgt3 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmpgt4;   --读源寄存器中的值，通过总线写入工作寄存器，送至比较器A输入端
         when jmpgt4 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= gt;
            next_state <= jmpgt5;  --读目的寄存器的值，通过总线送至比较器B输入端，AB输入运行等于比较
         when jmpgt5 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= gt;
            if compout = '1' then
               next_state <= jmpgt6;   --等于比较成立，次态进入jmpgt6，读取转移地址
            else
               next_state <= incPc;       --等于比较不成立，次态进入顺序指令公共流程incPc，取下一指令
            end if;
         when jmpgt6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmpgt7; --读取RAM中保存的转移地址到总线（注意要延迟T1+RAM读时间后才有效）
         when jmpgt7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --转移地址写入程序寄存器（因为该寄存器的写入仅延时T1，不能在jmpeq6状态进行）

         ----------------------------------------------
         --JMPI 跳转
         when jmp1 =>
            progcntrRd <= '1';
            alusel <= inc;
            shiftsel <= shftpass;
            outregWr <= '1';
            next_state <= jmp2;   --读程序寄存器中的值，至ALU加1成双字指令第二字的RAM地址，通过移位器写入输出寄存器
         when jmp2 =>
            outregRd <= '1';
            progcntrWr<='1';
            addrregWr<='1';
            next_state <= jmp3;  --转移指令第二字RAM地址从输出寄存器读到总线，并且从总线写回程序计数器和地址寄存器
         when jmp3 =>
            vma<='1';
            rw<='0';
            next_state <= jmp4;  --读取RAM中保存的转移地址到总线（注意要延迟T1+RAM读时间后才有效）
         when jmp4 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --转移地址写入程序寄存器（因为该寄存器写入仅延时T1，不能在jmp3状态进行）


         ----------------------------------------------
         --JMPI PC跳转
         when loadPc1 =>
            progcntrRd <= '1';
            addrRegWr <= '1';
            next_state <= loadPc2;		--读出程序寄存器中的程序转移地址，通过总线写入地址寄存器
         when loadPc2 =>
            vma <= '1';
            rw <= '0';
            instrWr <= '1';
            next_state <= execute;       	--读存储器中转移地址的指令，通过总线写入指令寄存器


         ----------------------------------------------
         --SHL 将某个寄存器中的值左移一位后放回该寄存器
         when shftl1=>
            regSel<=instrReg(2 downto 0);
            regRd<='1';
            aluSel<=alupass ;
            shiftSel<="001";
            outregWr <= '1';
            next_state<=shftl2;
         when shftl2=>
            outRegRd<='1';
            regSel<=instrReg(2 downto 0);
            regWr<='1';
            next_state <= incPc;

         ----------------------------------------------
         --SHR 将某个寄存器中的值右移一位后放回该寄存器
         when shftr1=>
            regSel<=instrReg(2 downto 0);
            regRd<='1';
            aluSel<=alupass ;
            shiftSel<="010";
            outregWr <= '1';
            next_state<=shftr2;
         when shftr2=>
            outRegRd<='1';
            regSel<=instrReg(2 downto 0);
            regWr<='1';
            next_state <= incPc;

         ----------------------------------------------
         --ROTL 将某个寄存器中的值循环左移一位后放回该寄存器
         when rotl1=>
            regSel<=instrReg(2 downto 0);
            regRd<='1';
            aluSel<=alupass ;
            shiftSel<="011";
            outregWr <= '1';
            next_state<=rotl2;
         when rotl2=>
            outRegRd<='1';
            regSel<=instrReg(2 downto 0);
            regWr<='1';
            next_state <= incPc;

         ----------------------------------------------
         --ROTR 将某个寄存器中的值循环右移一位后放回该寄存器
         when rotr1=>
            regSel<=instrReg(2 downto 0);
            regRd<='1';
            aluSel<=alupass ;
            shiftSel<="100";
            outregWr <= '1';
            next_state<=rotr2;
         when rotr2=>
            outRegRd<='1';
            regSel<=instrReg(2 downto 0);
            regWr<='1';
            next_state <= incPc;

         ----------------------------------------------
         --DEC 将某个寄存器中的值减一放回该寄存器
         WHEN dec2 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= dec;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= dec3;
         WHEN dec3 =>
            outRegRd <= '1';
            next_state <= dec4;
         WHEN dec4 =>
            outRegRd <= '1';
            regSel <= instrReg(2 DOWNTO 0);
            regWr <= '1';
            next_state <= incPc;

         ----------------------------------------------
         --NOT 将某个寄存器中的值取反放回该寄存器
         WHEN not2 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= OP_not;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= not3;
         WHEN not3 =>
            outRegRd <= '1';
            next_state <= not4;
         WHEN not4 =>
            outRegRd <= '1';
            regSel <= instrReg(2 DOWNTO 0);
            regWr <= '1';
            next_state <= incPc;

         ----------------------------------------------
         --AND 将两个寄存器中的值相与
         WHEN and2 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            next_state <= and3;
            opRegWr <= '1';
         WHEN and3 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= OP_and;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= and4;
         WHEN and4 =>
            regSel <= "011";
            outRegRd <= '1';
            regWr <= '1';
            next_state <= incPc;

         ----------------------------------------------
         --OR 将两个寄存器中的值相或
         WHEN or2 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            next_state <= or3;
            opRegWr <= '1';
         WHEN or3 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= OP_or;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= or4;
         WHEN or4 =>
            regSel <= "011";
            outRegRd <= '1';
            regWr <= '1';
            next_state <= incPc;

         ----------------------------------------------
         --XOR 将两个寄存器中的值相异或
         WHEN xor2 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            next_state <= xor3;
            opRegWr <= '1';
         WHEN xor3 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= OP_xor;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= xor4;
         WHEN xor4 =>
            regSel <= "011";
            outRegRd <= '1';
            regWr <= '1';
            next_state <= incPc;

         WHEN sub2 =>
            regSel <= instrReg(5 DOWNTO 3);
            regRd <= '1';
            next_state <= sub3;
            opRegWr <= '1';
         WHEN sub3 =>
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            aluSel <= sub;
            shiftSel <= shftpass;
            outRegWr <= '1';
            next_state <= sub4;
         WHEN sub4 =>
            regSel <= "011";
            outRegRd <= '1';
            regWr <= '1';
            next_state <= incPc;

         -- 以下均为正确指令，无需另外修改
         --
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


