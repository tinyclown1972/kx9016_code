# kx9016 16-bit cpu based on fpga with simple ASM compiler based on python



## 各个指令含义

## ALU 数据运算器

| 功能    | 指令 | 备注         |
| ------- | ---- | ------------ |
| alupass | 0000 | C = A直通    |
| and     | 0001 | C = A & B    |
| or      | 0010 | C = A ｜ B   |
| not     | 0011 | C = not A    |
| xor     | 0100 | C = A 异或 B |
| plus    | 0101 | C = A + B    |
| sub     | 0110 | C = A - B    |
| inc     | 0111 | C = A++      |
| dec     | 1000 | C = A--      |
| zero    | 1001 | C = 0        |



## COMP 比较器

| 功能 | 指令 | 备注     |
| ---- | ---- | -------- |
| eq   | 000  | ab相等   |
| neq  | 001  | ab不相等 |
| gt   | 010  | a>b      |
| gte  | 011  | a>=b     |
| lt   | 100  | a<b      |
| lte  | 101  | a<=b     |



## REG16A 

简单的寄存器，时钟到达时即直通信号，用于缓冲寄存器 指令寄存器

| clk         | a             | c_out           |
| ----------- | ------------- | --------------- |
| rising_edge | X<sub>t</sub> | X<sub>t</sub>   |
| other       | X<sub>t</sub> | X<sub>t-1</sub> |

> X<sub>t</sub> 为当前时刻的输入值，X<sub>t-1</sub>为前一时刻的输入值，即不发生变化



## REGT 三态输出的寄存器 

| en   | rst  | a      | c_out  | clk         |
| ---- | ---- | ------ | ------ | ----------- |
| 1    | 1    | 0xFFFF | 0x0000 | rising_edge |
| 1    | 0    | 0xFFFF | 0xFFFF | rising_edge |
| 0    | 1    | 0xFFFF | 高阻态 | rising_edge |
| 0    | 0    | 0xFFFF | 高阻态 | rising_edge |

 

## REGA 用于PC寄存器

| load | rst  | clk         | a             | c_out           |
| ---- | ---- | ----------- | ------------- | --------------- |
| 0    | 1    | rising_edge | X<sub>t</sub> | 0x0000          |
| 0    | 0    | rising_edge | X<sub>t</sub> | X<sub>t-1</sub> |
| 1    | 1    | rising_edge | X<sub>t</sub> | 0x0000          |
| 1    | 0    | rising_edge | X<sub>t</sub> | X<sub>t</sub>   |

> X<sub>t</sub> 为当前时刻的输入值，X<sub>t-1</sub>为前一时刻的输入值，即不发生变化



## 指令对照表

| 指令  | 名称   | 作用                       | 单双指令 | 调用 参数高位为n，依次向下递增m              | 备注                                                    | 实现 | 验证 | RUN_TEST | CI   |
| ----- | ------ | -------------------------- | -------- | -------------------------------------------- | ------------------------------------------------------- | ---- | ---- | -------- | ---- |
| 00000 | nop    | 空操作                     | 单       | nop                                          |                                                         | 是   | 是   | 是       | 0    |
| 00001 | LD     | 装载数据到寄存器           | 单       | LD R<sub>n</sub> , [R<sub>m</sub>]           | 从R<sub>m</sub>指定的RAM取数据送R<sub>n</sub>           | 是   | 是   | 懒得测   | 2    |
| 00010 | STA    | 将寄存器的数据装载到存储器 | 单       | STA [R<sub>n</sub>] , R<sub>m</sub>          | 将R<sub>m</sub>的内容存入R<sub>n</sub>指定的RAM单元     | 是   | 是   | 懒得测   | 2    |
| 00011 | MOV    | 寄存器间传送操作数         | 单       | MOV  R<sub>n</sub> , R<sub>m</sub>           | 复制R<sub>n</sub> 的数据到 R<sub>m</sub>                | 是   | 是   | 是       | 2    |
| 00100 | LDR    | 将立即数装入寄存器         | 双       | LDR R<sub>n</sub> ， #0000                   | 将立即数 0x0000 装入R<sub>n</sub>                       | 是   | 是   | 是       | 5    |
| 00101 | JMPI   | 转移到由立即数指定的地址   | 双       | JMPI  #0000                                  | PC立即跳转0x0000位置                                    | 是   | 是   | 是       | 4    |
| 00110 | JMPGTI | 大于时转移至立即数地址     | 双       | JMPGTI R<sub>n</sub> , R<sub>m</sub> ，#0000 | 当R<sub>n</sub> 大于 R<sub>m</sub> 时跳转到立即数的地址 | 是   | 是   | 是       | 7    |
| 00111 | INC    | 加一后放回寄存器           | 单       | INC R<sub>n</sub>                            | INC R<sub>n</sub>                                       | 是   | 是   | 是       | 3    |
| 01000 | DEC    | 减一后放回寄存器           | 单       | DEC R<sub>n</sub>                            | DEC R<sub>n</sub>                                       | 是   | 是   | 是       | 3    |
| 01001 | AND    | 寄存器间相与操作           | 单       | AND R<sub>n</sub> , R<sub>m</sub>            | R<sub>n</sub> 与R<sub>m</sub> 相与，结果默认放置R3      | 是   | 是   | 是       | 3    |
| 01010 | OR     | 寄存器间相或操作           | 单       | OR R<sub>n</sub> , R<sub>m</sub>             | R<sub>n</sub> 与R<sub>m</sub> 相或，结果默认放置R3      | 是   | 是   | 是       | 3    |
| 01011 | XOR    | 寄存器间相异或操作         | 单       | XOR R<sub>n</sub> , R<sub>m</sub>            | R<sub>n</sub> 与R<sub>m</sub> 相异或，结果默认放置R3    | 是   | 是   | 是       | 3    |
| 01100 | NOT    | 寄存器取反                 | 单       | NOT R<sub>n</sub>                            | 将R<sub>n</sub>取反后放回                               | 是   | 是   | 是       | 3    |
| 01101 | ADD    | 寄存器间相加操作           | 单       | ADD R<sub>n</sub> , R<sub>m</sub>            | R<sub>n</sub> 与R<sub>m</sub> 相加，结果默认放置R3      | 是   | 是   | 是       | 3    |
| 01110 | SUB    | 寄存器间相减操作           | 单       | SUB R<sub>n</sub> , R<sub>m</sub>            | R<sub>n</sub> -R<sub>m</sub> ，结果默认放置R3           | 是   | 是   | 是       | 3    |
| 01111 | IN     | 外设数据输入指令           | 单       |                                              |                                                         | 是   |      |          | 3    |
| 10000 | JMPLTI | 小于时转移至立即数地址     | 双       | JMPLTI R<sub>n</sub> , R<sub>m</sub> ，#0000 | 当R<sub>n</sub> 小于 R<sub>m</sub> 时跳转到立即数的地址 | 是   | 是   | 是       | 7    |
| 10001 | JMPGT  | 大于跳转指令               | 单       |                                              | 使用JMPGTI代替                                          | 否   |      |          |      |
| 10010 | OUT    | 外设输出指令               | 单       |                                              |                                                         | 是   |      |          | 3    |
| 10011 | MTAD   | 16位乘法累加               | 双       |                                              |                                                         | 否   |      |          |      |
| 10100 | MULT   | 16位乘法                   | 双       |                                              |                                                         | 否   |      |          |      |
| 10101 | JMP    | 无条件跳转指令             | 单       |                                              | 使用JMPI代替                                            | 否   |      |          | 4    |
| 10110 | JMPEQ  | 相等跳转                   | 单       |                                              | 使用JMPEQI代替                                          | 否   |      |          |      |
| 10111 | JMPEQI | 相等跳转立即数地址         | 双       | JMPEQI R<sub>n</sub> , R<sub>m</sub> ，#0000 | 当R<sub>n</sub> 等于R<sub>m</sub> 时跳转到立即数的地址  | 是   | 是   | 是       | 7    |
| 11000 | DIV    | 16位除法                   | 单       |                                              |                                                         | 否   |      |          |      |
| 11001 | JMPLTE | 小于等于时转移至立即数地址 | 双       |                                              | 使用JMPLTI代替                                          | 否   |      |          |      |
| 11010 | SHL    | 左逻辑移位                 | 单       | SHL R<sub>n</sub>                            | 全部数据向左移动，缺位补0                               | 是   | 是   | 是       | 2    |
| 11011 | SHR    | 右逻辑移位                 | 单       | SHR R<sub>n</sub>                            | 全部数据向右移动，缺位补0                               | 是   | 是   | 是       | 2    |
| 11100 | ROTR   | 左循环移位                 | 单       | ROTR R<sub>n</sub>                           | 全部数据循环向左移位                                    | 是   | 是   | 是       | 2    |
| 11101 | ROTL   | 右循环移位                 | 单       | ROTL R<sub>n</sub>                           | 全部数据循环向右移位                                    | 是   | 是   | 是       | 2    |

