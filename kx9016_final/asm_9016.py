import re
import sys
import time

asm_content = ""
line_num = 0
real_line_num = 0
asm_prefix = """WIDTH=16;
DEPTH=127;

ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;

CONTENT BEGIN
"""
asm_suffix = """END;"""

def get_instruction(instruction):       #切片传入参数，获取对应指令及内容并将其传递至对应函数
    instruction = instruction.upper()
    instruction = str(instruction).strip(" ").strip("\n")
    if instruction == "NOP":
        return "0000000000000000"
    elif instruction == "IN":
        return "0111100000000000"
    elif instruction == "OUT":
        return "1001000000000000"
    elif instruction == "ADD":
        return "0110100000"
    elif instruction == "SUB":
        return "0111000000"
    elif instruction == "LD":
        return "0000100000"
    elif instruction == "STA":
        return "0001000000"
    elif instruction == "MOV":
        return "0001100000"
    elif instruction == "LDR":
        return "0010000000000"
    elif instruction == "JMPI":
        return "0010100000000000"
    elif instruction == "JMPGTI":
        return "0011000000"
    elif instruction == "INC":
        return "0011100000000"
    elif instruction == "DEC":
        return "0100000000000"
    elif instruction == "AND":
        return "0100100000"
    elif instruction == "OR":
        return "0101000000"
    elif instruction == "XOR":
        return "0101100000"
    elif instruction == "NOT":
        return "0110000000000"
    elif instruction == "SHL":
        return "1101000000000"
    elif instruction == "SHR":
        return "1101100000000"
    elif instruction == "ROTR":
        return "1110000000000"
    elif instruction == "ROTL":
        return "1110100000000"
    elif instruction == "JMPEQI":
        return "1011100000"
    elif instruction == "JMPLTI":
        return "1000000000"
    else:
        print("Error: Invalid instruction:"+instruction)
def get_bin(num):                       #将十进制转换为二进制
    num = int(num)
    if(num >= 0 and num <= 7):
        result = str(bin(num))[2:]
        if len(result) == 1:
            result = "00"+result
        elif len(result) == 2:
            result = "0"+result
        return result
    else:
        print("Error: Invalid number , may out of index : "+str(num)+" in line "+str(real_line_num))
        exit(0)
def hex_to_bin(hex_num):                #将十六进制转换为二进制
    if(hex_num == ""):
        return "0000000000000000"
    # while(hex_num.startswith("0")):
    #     hex_num = hex_num[1:]
    # print("hex_to_bin get "+hex_num)
    # hex_num = hex_num.strip("\n")
    res = bin(int(hex_num,16))[2:]
    unmatch_num = 16 - len(res)
    res = "0"*unmatch_num + res
    return res
def get_hex(num):                       #将十进制转换为十六进制
    result = str(hex(eval(num)))[2:]
    result = result.upper()
    if len(result) == 1:
        result = "0"+result
    return result
def bintohex(bin_num):                  #将二进制转换为十六进制
    result = hex(int(bin_num,2))[2:]
    if len(result) < 4:
        result = "0"*(4-len(result))+result
    return result

# 下列函数为指令的解析，将其转换为对应的二进制
def func_nop(line,line_num):
    global asm_content
    line_list = line.split(" ")
    asm_content =  asm_content + str(get_hex(str(line_num)))+" : " + get_instruction(line_list[0]) +";\n"
def func_add(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_sub(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_ld(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_sta(line,lnum):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(lnum))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_mov(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_ldr(line,lnum):
    global asm_content
    global line_num
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(lnum))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
        line_num += 1
        asm_content += get_hex(str(line_num))+ " : "+ hex_to_bin(line_list[2][1:])  +";\n"
def func_jmpi(line,lnum):
    global asm_content
    global line_num
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content =  asm_content + str(get_hex(str(lnum)))+" : " + get_instruction(line_list[0]) +";\n"
        line_num+=1
        asm_content += get_hex(str(line_num))+ " : "+ hex_to_bin(line_list[1][1:])  +";\n"
def func_jmpgti(line,lnum):
    global asm_content
    global line_num
    line_list = line.split(" ")
    if len(line_list) != 4:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
        line_num+=1
        asm_content += get_hex(str(line_num))+ " : "+ hex_to_bin(line_list[3][1:])  +";\n"
def func_inc(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
def func_dec(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
def func_and(line,line_num):
    global asm_content
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_or(line,line_num):
    global asm_content
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_xor(line,line_num):
    global asm_content
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 3:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
def func_not(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
def func_shl(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
def func_shr(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
def func_rotr(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
def func_rotl(line,line_num):
    global asm_content
    line_list = line.split(" ")
    if len(line_list) != 2:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + ";\n"
def func_jmpeqi(line,lnum):
    global asm_content
    global line_num
    line_list = line.split(" ")
    if len(line_list) != 4:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
        line_num+=1
        asm_content += get_hex(str(line_num))+ " : "+ hex_to_bin(line_list[3][1:])  +";\n"
def func_jmplti(line,lnum):
    global asm_content
    global line_num
    line_list = line.split(" ")
    if len(line_list) != 4:
        print("Error: Invalid instruction : "+str(real_line_num)+": "+line)
        exit(0)
    else:
        asm_content += get_hex(str(line_num))+" : " + get_instruction(line_list[0]) + get_bin(line_list[1][1:]) + get_bin(line_list[2][1:])  +";\n"
        line_num+=1
        asm_content += get_hex(str(line_num))+ " : "+ hex_to_bin(line_list[3][1:])  +";\n"
def main():
    global line_num
    global asm_content
    global real_line_num
    # filename = "D:/Documents/Thesis/code/test.txt"
    if len(sys.argv) != 2:
        print("Usage: ./asm_9016.py <filename>")
        sys.exit(1)
    else:
        filename = sys.argv[1]
    with open(filename, "r") as f:
        lines = f.readlines()

    for line in lines:
        if line.startswith("#") or line == "\n" or line == "\r\n" or line == "":
            continue
        else:
            line_instruction  = line.split(" ")[0].strip("\n").upper()
            line = line.strip("\n")
            if line_instruction  =="NOP":
                func_nop(line,line_num)
            elif line_instruction  =="IN":
                func_nop(line,line_num)
            elif line_instruction  =="OUT":
                func_nop(line,line_num)
            elif line_instruction  =="LDR":
                func_ldr(line,line_num)
            elif line_instruction  =="LD":
                func_ld(line,line_num)
            elif line_instruction  =="STA":
                func_sta(line,line_num)
            elif line_instruction  =="MOV":
                func_mov(line,line_num)
            elif line_instruction  =="JMPI":
                func_jmpi(line,line_num)
            elif line_instruction  =="JMPGTI":
                func_jmpgti(line,line_num)
            elif line_instruction  =="INC":
                func_inc(line,line_num)
            elif line_instruction  =="DEC":
                func_dec(line,line_num)
            elif line_instruction  =="AND":
                func_and(line,line_num)
            elif line_instruction  =="OR":
                func_or(line,line_num)
            elif line_instruction  =="XOR":
                func_xor(line,line_num)
            elif line_instruction  =="NOT":
                func_not(line,line_num)
            elif line_instruction  =="ADD":
                func_add(line,line_num)
            elif line_instruction  =="SUB":
                func_sub(line,line_num)
            elif line_instruction  =="JMPEQI":
                func_jmpeqi(line,line_num)
            elif line_instruction  =="JMPLTI":
                func_jmplti(line,line_num)
            elif line_instruction  =="SHL":
                func_shl(line,line_num)
            elif line_instruction  =="SHR":
                func_shr(line,line_num)
            elif line_instruction  =="ROTR":
                func_rotr(line,line_num)
            elif line_instruction  =="ROTL":
                func_rotl(line,line_num)
            else:
                print("Error: Invalid instruction"+line)
            line_num += 1
            real_line_num += 1
    print("BIN source code is:")
    print(asm_content)
    new_asm_content = ""
    asm_content_list = asm_content.split("\n")
    for i in range(len(asm_content_list)) :
        if(asm_content_list[i] == ""):
            continue
        else:
            new_asm_content = new_asm_content + "\t" + asm_content_list[i][:5] + (bintohex(asm_content_list[i][5:-1]))+";\n"
    print("HEX source code is:")
    print(new_asm_content)

    now_line_num = hex(line_num)[2:]
    if(len(now_line_num)<2):
        now_line_num = "0"+now_line_num
    now_line_num = now_line_num.upper()
    # print(now_line_num)

    asm_content = asm_prefix + new_asm_content + "\t" + "[{}..7E] : 0000;\n".format(now_line_num) +asm_suffix

    try:
        filename = filename.replace(".txt",'')
        with open("./MIF/"+filename+".mif" , "w") as f:
            f.write(asm_content)
            end = time.perf_counter()
        print("Success: Generated "+"./MIF/"+filename+".mif")
        print('In %.8s Seconds'%(end-start))
    except Exception as e:
        print(e)

    
if __name__ == "__main__":
    start = time.perf_counter()
    main()


