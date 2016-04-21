;-----------------------------------------------------;
;换行宏定义
;-----------------------------------------------------;
HUANH MACRO
  MOV AH, 2
  MOV DL, 0DH
  INT 21H
  MOV DL, 0AH
  INT 21H
ENDM
;-----------------------------------------------------;
;数据段定义
;-----------------------------------------------------;
DATA SEGMENT
  MSG DB 'Please input a number: $'
  RESULT DB 'The YiangHui triangle:$'
  CON DB 'Do you want to continue?(Y/N): $'
  ERROR DB 'Data out of range!$'
  AHEAD DB '   $'         ;第一种是首数字1之前的空格
  BETWEEN DB '      $'       ;第二种是首数字1后面的空格
  BACK DB '$'          ;第三种是和需显示的数字位数相关的空格
  a DW ?               ;a为阶数
  b DW ?               ;b为行数
  c DW ?
  d DW ?               ;记录位数，用来控制空格的数目
DATA ENDS
;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODE SEGMENT
  ASSUME CS:CODE,DS:DATA
;-----------------------------------------------------;
;输入子程序,数字存放在BP中
;-----------------------------------------------------;
SHURU PROC
  XOR BP,BP ;BP清零
  MOV BX,10
  MOV CX,3  ;控制输入的位数,2位数加上一个回车
input:
  MOV AH,1  ;从键盘读入数据
  INT 21H
  CMP AL,0DH
  JZ OK       ;如果回车则输入完毕
  SUB AL,30H  ;转为十六位二进制数
  CBW         ;字节扩展为字
  XCHG AX,BP  ;交换到AX中
  MUL BX      ;扩大十倍
  ADD BP,AX   ;加一位
  LOOP input
OK:
  RET
SHURU ENDP

START:
  MOV AX,DATA
  MOV DS,AX
;-----------------------------------------------------;
;判断输入的数字是否在允许的范围之内,直到满足条件才能进行下一步
;-----------------------------------------------------;
MAIN:
  MOV DX,OFFSET MSG     ; 输出字符串，请输入一个数
  MOV AH,9              ; 9号功能调用，输出字符串
  INT 21H
  CALL SHURU            ; 调用输入函数,显示输入的数
  CMP BP,15             ; 输入的数存在BP，与15比较
  JB MZTJ               ; 如果输入的数字<15则满足条件，允许执行
  HUANH                 ; 否则换行
  MOV DX, OFFSET ERROR  ; 否则提示错误的输入信息
  MOV AH,9
  INT 21H
  HUANH                 ; 继续换行
  JMP MAIN              ; 无条件跳转到MAIN，重新开始

MZTJ: HUANH
  MOV DX, OFFSET RESULT ; 显示提示字符串
  MOV AH, 9
  INT 21H

  HUANH                 ; 换行
  MOV AX, BP            ; 准备显示杨辉三角,AX=BP=输入的阶数
  CALL Showspace        ; 显示前面的空格
  MOV DL, '1'           ; 输出第一个1
  MOV AH, 2
  INT 21H
  CMP BP, 1             ; 将阶数与1进行比较
  JZ  exit              ; 小于则直接退出
  MOV b, 2              ; b=2
  MOV CX, BP            ; 此时CX=阶数
  MOV a, BP             ; a=阶数
  DEC a
  CALL yhsj             ; 调用yhsj子程序

exit: HUANH
  MOV AX, BP            ; 准备显示杨辉三角,AX=BP=输入的阶数
  CALL Showspace        ; 显示空格
  MOV DL, '1'           ; 输出第一个1
  MOV AH, 2
  INT 21H
  JMP NEAR PTR input1
;-----------------------------------------------------;
;输出杨辉三角
;-----------------------------------------------------;
yhsj:
  MOV c, 1
  HUANH
  DEC BP
  MOV AX, BP
  CALL Showspace        ; 控制首个数字前面的空格
  MOV DL, '1'           ; 首个数字为1
  MOV AH, 2
  INT 21H
  MOV DX,OFFSET BETWEEN
  MOV AH,9
  INT 21H
  MOV AX,1
  PUSH b
  CALL Calculate
  POP b
  INC b
  DEC CX
  CMP CX,1
  JA yhsj
  DEC b
  CMP b, 2
  JZ ok3
  CALL fyhsj
ok3:HUANH
  INC a
  MOV AX, a
  CALL Showspace
  MOV DL, '1'
  MOV AH, 2
  INT 21H
;-----------------------------------------------------;
;输入询问模块
;-----------------------------------------------------;
input1:             ; 判断是否还需要继续输入
  HUANH
  MOV DX,OFFSET CON ; 显示提问字符串,继续?
  MOV AH,9
  INT 21H
  MOV AH,1          ; 键盘输入数据
  INT 21H
  CMP AL,59H        ; 判断是否继续
  JNZ exit1
  HUANH
  JMP NEAR PTR MAIN ; 段内直接近转移,可以转移到段内
exit1:              ; 不继续输入则退出程序
  MOV AH,4CH
  INT 21H
;-----------------------------------------------------;
;输出反杨辉三角
;-----------------------------------------------------;
fyhsj:
  MOV C, 1
  HUANH
  INC BP
  MOV AX, BP
  CALL Showspace
  MOV DL, '1'
  MOV AH, 2
  INT 21H
  MOV DX, OFFSET BETWEEN
  MOV AH, 9
  INT 21H
  MOV AX, 1
  DEC b
  PUSH b
  CALL Calculate
  POP b
  INC CX
  CMP CX, a
  JB fyhsj
  RET
;-----------------------------------------------------;
;输出空格模块
;-----------------------------------------------------;
Showspace:              ; 首行显示空格，空格数即为输入的阶数
  MOV BX, AX
  MOV AH, 9
  MOV DX,OFFSET AHEAD
nexts:
  CMP BX, 0             ; BX减1，控制输出的空格数
  JZ dones
  INT 21H
  DEC BX
  JMP nexts
dones:
  RET
;-----------------------------------------------------;
;核心计算模块
;-----------------------------------------------------;
Calculate: DEC b    ; b每次减1相乘
  MUL b
  DIV c             ; 除以c，再加1
  INC c
  CMP b,0           ; b是否为0
  JZ ok1

  PUSH AX           ; 保存所得数据
  MOV d,0           ; 此处d为位数，为了显示后面的空格
  CALL ShowNum
  MOV AX,6          ; 预设，总共显示的空格数为6个单位
  SUB AX,d          ; 还需显示多少空格
  CALL Showspace1
  POP AX
  CALL Calculate    ; 继续执行
ok1:
  RET
;-----------------------------------------------------;
;显示模块
;-----------------------------------------------------;
ShowNum:
  MOV BX, 10       ; BX中存除数10
  CMP AX, 0
  JZ ok2           ; 除法运算是否完毕
  INC d            ; 此处d为位数，以确定输出的空格数
  DIV BX           ; 除以10，整数商存在AL，余数存在AH
  PUSH AX
  AND AX, 00FFH    ; 屏蔽高八位，取商
  CALL SHOWNum
  POP DX
  MOV DL, DH       ; 取出高八位，即为要显示的余数
  OR DL, 30H       ; 转为ASCII码
  MOV AH, 2        ; 显示出数字
  INT 21H
ok2:
  RET
;-----------------------------------------------------;
;输出空格模块
;-----------------------------------------------------;
Showspace1:
  MOV BX, AX
  MOV AH, 9
  MOV DX, OFFSET BACK
next:
  CMP BX, 0
  JZ done
  INT 21H
  DEC BX
  JMP next
done:
  RET
CODE ENDS
END START
