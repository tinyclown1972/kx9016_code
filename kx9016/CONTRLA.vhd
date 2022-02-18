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
      not3   , not4   , sub2   , sub3    , sub4   , jmplte1, jmplte2, jmplte3,
      jmplte4, jmplte5, jmplte6, jmplte7 , jmpgte1, jmpgte2, jmpgte3, jmpgte4,
      jmpgte5, jmpgte6, jmpgte7

      );

   SIGNAL current_state : state ;
   SIGNAL next_state    : state ;
BEGIN
-- PROCESS (current_state, instrReg, compout)
   PROCESS (current_state, instrReg , compout )
   BEGIN
      -- ÿ����ѯ״̬�����Ὣ����״̬����
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

      -- ���е�ǰ״̬���жϲ����ж�Ӧ΢ָ�����
      CASE current_state IS
         -- ����λ������ǰ������Ϊ����λ��ϵͳ��ӵ��������ȼ�
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

         -- �漴����ִ��ָ��������жϣ����ݵ�ǰָ�������ſ���֪������ָ��ø���
         WHEN execute =>
            CASE instrReg(15 DOWNTO 11) IS

               -- nopָ�ֱ����ת��һ��ָ��
               WHEN "00000" =>
                  next_state <= incPc;

               -- װ�����ݵ��Ĵ���
               WHEN "00001" =>
                  next_state <= load2;

               -- ���Ĵ�������ֵ����洢��
               WHEN "00010" =>
                  next_state <= store2;

               -- �ڼĴ����䴫�Ͳ�����
               WHEN "00011" =>
                  next_state <= move1;

               -- ��������װ��Ĵ���
               WHEN "00100" =>
                  progCntrRd <= '1';
                  aluSel <= inc;
                  shiftSel <= shftpass;
                  next_state <= loadI2;

               -- ת�Ƶ���������ַ
               WHEN "00101" =>
                  next_state <= jmp1;

               -- ����ת��ָ�������ת��������ַ
               WHEN "00110" =>
                  next_state <= jmpgt1;

               -- ��ĳ���Ĵ�����ֵ��һ��Ż�
               WHEN "00111" =>
                  next_state <= inc2;

               -- ��ĳ���Ĵ�����ֵ��һ��Ż�
               WHEN "01000" =>
                  next_state <= dec2;

               -- �����Ĵ������룬Ĭ�ϴ���R3
               WHEN "01001" =>
                  next_state <= and2;

               -- �����Ĵ������Ĭ�ϴ���R3
               WHEN "01010" =>
                  next_state <= or2;

               -- �����Ĵ��������Ĭ�ϴ���R3
               WHEN "01011" =>
                  next_state <= xor2;

               -- �Ĵ���ȡ��
               WHEN "01100" =>
                  next_state <= not2;

               -- �����Ĵ�����ӣ�Ĭ�ϴ���R3
               WHEN "01101" =>
                  next_state <= add2;

               -- �����Ĵ��������Ĭ�ϴ���R3
               WHEN "01110" =>
                  next_state <= sub2;

               -- JMPLTIָ�С����ת
               WHEN "10000" =>
                  next_state <= jmplt1;

               -- JMPIָ�������ת
               WHEN "10101" =>
                  next_state <= jmp1;

               -- JMPEQIָ������ת������ָ��
               WHEN "10111" =>
                  next_state <= jmpeq1;

               -- JMPLTEָ�С�ڵ�����ת
               WHEN "11001" =>
                  next_state <= jmplte1;

               -- SHLָ�����һλ
               WHEN "11010" =>
                  next_state <= shftl1;

               -- SHRָ�����һλ
               WHEN "11011" =>
                  next_state <= shftr1;

               -- ROTRָ�ѭ������һλ
               WHEN "11100" =>
                  next_state <= rotr1;

               -- ROTLָ�ѭ������һλ
               WHEN "11101" =>
                  next_state <= rotl1;


               WHEN OTHERS =>
                  next_state <= incPc;
            END CASE;


         ----------------------------------------------
         --JMPEQI ������תָ��
         when jmpeq1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmpeq2;   --������Ĵ����е�ֵ����ALU��1��˫��ָ��ڶ��ֵ�RAM��ַ��ͨ����λ��д������Ĵ���
         when jmpeq2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmpeq3;   --ָ��ڶ���RAM��ַ������Ĵ����������ߣ����Ҵ�����д�س���������͵�ַ�Ĵ���
         when jmpeq3 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmpeq4;   --��Դ�Ĵ����е�ֵ��ͨ������д�빤���Ĵ����������Ƚ���A�����
         when jmpeq4 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= eq;
            next_state <= jmpeq5;  --��Ŀ�ļĴ�����ֵ��ͨ�����������Ƚ���B����ˣ�AB�������е��ڱȽ�
         when jmpeq5 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            compsel <= eq;
            if compout = '1' then
               next_state <= jmpeq6;   --���ڱȽϳ�������̬����jmpeq6����ȡת�Ƶ�ַ
            else
               next_state <= incPc;       --���ڱȽϲ���������̬����˳��ָ�������incPc��ȡ��һָ��
            end if;
         when jmpeq6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmpeq7; --��ȡRAM�б����ת�Ƶ�ַ�����ߣ�ע��Ҫ�ӳ�T1+RAM��ʱ������Ч��
         when jmpeq7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --ת�Ƶ�ַд�����Ĵ�������Ϊ�üĴ�����д�����ʱT1��������jmpeq6״̬���У�

         ----------------------------------------------
         --JMPLTI ������תָ��
         when jmplt1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmplt2;   --������Ĵ����е�ֵ����ALU��1��˫��ָ��ڶ��ֵ�RAM��ַ��ͨ����λ��д������Ĵ���
         when jmplt2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmplt3;   --ָ��ڶ���RAM��ַ������Ĵ����������ߣ����Ҵ�����д�س���������͵�ַ�Ĵ���
         when jmplt3 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmplt4;   --��Դ�Ĵ����е�ֵ��ͨ������д�빤���Ĵ����������Ƚ���A�����
         when jmplt4 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= lt;
            next_state <= jmplt5;  --��Ŀ�ļĴ�����ֵ��ͨ�����������Ƚ���B����ˣ�AB�������е��ڱȽ�
         when jmplt5 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= lt;
            if compout = '1' then
               next_state <= jmplt6;   --���ڱȽϳ�������̬����jmpeq6����ȡת�Ƶ�ַ
            else
               next_state <= incPc;       --���ڱȽϲ���������̬����˳��ָ�������incPc��ȡ��һָ��
            end if;
         when jmplt6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmplt7; --��ȡRAM�б����ת�Ƶ�ַ�����ߣ�ע��Ҫ�ӳ�T1+RAM��ʱ������Ч��
         when jmplt7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --ת�Ƶ�ַд�����Ĵ�������Ϊ�üĴ�����д�����ʱT1��������jmpeq6״̬���У�

         ----------------------------------------------
         --JMPGTI ������תָ��
         when jmpgt1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmpgt2;   --������Ĵ����е�ֵ����ALU��1��˫��ָ��ڶ��ֵ�RAM��ַ��ͨ����λ��д������Ĵ���
         when jmpgt2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmpgt3;   --ָ��ڶ���RAM��ַ������Ĵ����������ߣ����Ҵ�����д�س���������͵�ַ�Ĵ���
         when jmpgt3 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmpgt4;   --��Դ�Ĵ����е�ֵ��ͨ������д�빤���Ĵ����������Ƚ���A�����
         when jmpgt4 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= gt;
            next_state <= jmpgt5;  --��Ŀ�ļĴ�����ֵ��ͨ�����������Ƚ���B����ˣ�AB�������е��ڱȽ�
         when jmpgt5 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= gt;
            if compout = '1' then
               next_state <= jmpgt6;   --���ڱȽϳ�������̬����jmpgt6����ȡת�Ƶ�ַ
            else
               next_state <= incPc;       --���ڱȽϲ���������̬����˳��ָ�������incPc��ȡ��һָ��
            end if;
         when jmpgt6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmpgt7; --��ȡRAM�б����ת�Ƶ�ַ�����ߣ�ע��Ҫ�ӳ�T1+RAM��ʱ������Ч��
         when jmpgt7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --ת�Ƶ�ַд�����Ĵ�������Ϊ�üĴ�����д�����ʱT1��������jmpeq6״̬���У�


         ----------------------------------------------
         --JMPLTEI ������תָ��
         when jmplte1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmplte2;   --������Ĵ����е�ֵ����ALU��1��˫��ָ��ڶ��ֵ�RAM��ַ��ͨ����λ��д������Ĵ���
         when jmplte2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmplte3;   --ָ��ڶ���RAM��ַ������Ĵ����������ߣ����Ҵ�����д�س���������͵�ַ�Ĵ���
         when jmplte3 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmplte4;   --��Դ�Ĵ����е�ֵ��ͨ������д�빤���Ĵ����������Ƚ���A�����
         when jmplte4 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= lte;
            next_state <= jmplte5;  --��Ŀ�ļĴ�����ֵ��ͨ�����������Ƚ���B����ˣ�AB�������е��ڱȽ�
         when jmplte5 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= lte;
            if compout = '1' then
               next_state <= jmplte6;   --���ڱȽϳ�������̬����jmpeq6����ȡת�Ƶ�ַ
            else
               next_state <= incPc;       --���ڱȽϲ���������̬����˳��ָ�������incPc��ȡ��һָ��
            end if;
         when jmplte6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmplte7; --��ȡRAM�б����ת�Ƶ�ַ�����ߣ�ע��Ҫ�ӳ�T1+RAM��ʱ������Ч��
         when jmplte7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --ת�Ƶ�ַд�����Ĵ�������Ϊ�üĴ�����д�����ʱT1��������jmpeq6״̬���У�

         ----------------------------------------------
         --JMPGTEI ������תָ��
         when jmpgte1 =>
            progcntrRd<='1';
            alusel<=inc;
            shiftSel<=shftpass;
            outregWr <= '1';
            next_state <= jmpgte2;   --������Ĵ����е�ֵ����ALU��1��˫��ָ��ڶ��ֵ�RAM��ַ��ͨ����λ��д������Ĵ���
         when jmpgte2 =>
            outregRd <= '1';
            progcntrWr <= '1';
            addrregWr <= '1';
            next_state <= jmpgte3;   --ָ��ڶ���RAM��ַ������Ĵ����������ߣ����Ҵ�����д�س���������͵�ַ�Ĵ���
         when jmpgte3 =>
            regSel <= instrReg(2 downto 0);
            regRd <= '1';
            opRegWr <= '1';
            next_state <= jmpgte4;   --��Դ�Ĵ����е�ֵ��ͨ������д�빤���Ĵ����������Ƚ���A�����
         when jmpgte4 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= gte;
            next_state <= jmpgte5;  --��Ŀ�ļĴ�����ֵ��ͨ�����������Ƚ���B����ˣ�AB�������е��ڱȽ�
         when jmpgte5 =>
            regSel <= instrReg(5 downto 3);
            regRd <= '1';
            compsel <= gte;
            if compout = '1' then
               next_state <= jmpgte6;   --���ڱȽϳ�������̬����jmpgte6����ȡת�Ƶ�ַ
            else
               next_state <= incPc;       --���ڱȽϲ���������̬����˳��ָ�������incPc��ȡ��һָ��
            end if;
         when jmpgte6 =>
            vma <= '1';
            rw <= '0';
            next_state <= jmpgte7; --��ȡRAM�б����ת�Ƶ�ַ�����ߣ�ע��Ҫ�ӳ�T1+RAM��ʱ������Ч��
         when jmpgte7 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --ת�Ƶ�ַд�����Ĵ�������Ϊ�üĴ�����д�����ʱT1��������jmpeq6״̬���У�

         ----------------------------------------------
         --JMPI ��ת
         when jmp1 =>
            progcntrRd <= '1';
            alusel <= inc;
            shiftsel <= shftpass;
            outregWr <= '1';
            next_state <= jmp2;   --������Ĵ����е�ֵ����ALU��1��˫��ָ��ڶ��ֵ�RAM��ַ��ͨ����λ��д������Ĵ���
         when jmp2 =>
            outregRd <= '1';
            progcntrWr<='1';
            addrregWr<='1';
            next_state <= jmp3;  --ת��ָ��ڶ���RAM��ַ������Ĵ����������ߣ����Ҵ�����д�س���������͵�ַ�Ĵ���
         when jmp3 =>
            vma<='1';
            rw<='0';
            next_state <= jmp4;  --��ȡRAM�б����ת�Ƶ�ַ�����ߣ�ע��Ҫ�ӳ�T1+RAM��ʱ������Ч��
         when jmp4 =>
            vma <= '1';
            rw <= '0';
            progcntrWr <= '1';
            next_state <= loadPc1;  --ת�Ƶ�ַд�����Ĵ�������Ϊ�üĴ���д�����ʱT1��������jmp3״̬���У�


         ----------------------------------------------
         -- PC��תָ��
         when loadPc1 =>
            progcntrRd <= '1';
            addrRegWr <= '1';
            next_state <= loadPc2;		--��������Ĵ����еĳ���ת�Ƶ�ַ��ͨ������д���ַ�Ĵ���
         when loadPc2 =>
            vma <= '1';
            rw <= '0';
            instrWr <= '1';
            next_state <= execute;       	--���洢����ת�Ƶ�ַ��ָ�ͨ������д��ָ��Ĵ���


         ----------------------------------------------
         --SHL ��ĳ���Ĵ����е�ֵ����һλ��ŻظüĴ���
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
         --SHR ��ĳ���Ĵ����е�ֵ����һλ��ŻظüĴ���
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
         --ROTL ��ĳ���Ĵ����е�ֵѭ������һλ��ŻظüĴ���
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
         --ROTR ��ĳ���Ĵ����е�ֵѭ������һλ��ŻظüĴ���
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
         --DEC ��ĳ���Ĵ����е�ֵ��һ�ŻظüĴ���
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
         --NOT ��ĳ���Ĵ����е�ֵȡ���ŻظüĴ���
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
         --AND �������Ĵ����е�ֵ����
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
         --OR �������Ĵ����е�ֵ���
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
         --XOR �������Ĵ����е�ֵ�����
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
            regSel <= instrReg(2 DOWNTO 0);
            regRd <= '1';
            next_state <= sub3;
            opRegWr <= '1';
         WHEN sub3 =>
            regSel <= instrReg(5 DOWNTO 3);
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

         -- ���¾�Ϊ��ȷָ����������޸�
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
      -- ��λ��������ʱ�����
      IF (reset = '1') THEN
         current_state <= reset1;
      -- ������ָ������ܵ�ʱ�����
      ELSIF (clock'EVENT AND clock = '1') THEN
         current_state <= next_state;
      END IF;
   END PROCESS;


END trans;

