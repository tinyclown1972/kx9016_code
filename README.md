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

