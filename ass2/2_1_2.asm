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
;判断输入的数字是否在允许的范围之内
;-----------------------------------------------------;
MAIN:
  MOV DX,OFFSET MSG ;输出字符串，请输入一个数
  MOV AH,9   ; 9号功能调用，输出字符串
  INT 21H
  CALL SHURU ; 调用输入函数,显示输入的数
  CMP BP,15  ; 输入的数存在BP，与15比较
  JB MZTJ    ; 满足条件，允许执行
  HUANH      ; 否则换行
  MOV DX, OFFSET ERROR  ; 否则提示错误的输入信息
  MOV AH,9
  INT 21H
  HUANH ; 继续换行
  JMP MAIN ; 无条件跳转到MAIN，重新开始
  AX d,0 ShowNum AX,6 AX,d Showspace1 AX Calculate BX, 10 AX, 0 ok2 d BL AX AX, 00FFH SHOWNum DX DL, DH AH, 2 21H BX, AX AH, 9 DX,OFFSET BACK BX, 0 done 21H BX next 20
MZTJ: HUANH
  MOV
  MOV
  INT
  HUANH
  MOV
  CALL
  MOV
  MOV
  INT
  CMP
  JZ
  MOV
  MOV
  MOV
  DEC
  CALL
  exit: HUANH
  MOV
  CALL
  MOV
  MOV
  INT
  JMP
  yhsj: MOV
  HUANH
  DEC
  MOV
  CALL
  MOV
  DX,OFFSET ERROR AH,9 21H MAIN DX,OFFSET RESULT AH,9 21H AX,BP Showspace DL,'1' AH,2 21H BP,1 exit b,2 CX,BP a,BP a yhsj AX,BP Showspace DL,'1' AH,2 21H NEAR PTR input1 cc,1 BP AX,BP Showspace DL,'1' 18

  MOV AH,2
  INT 21H
  MOV DX,OFFSET BETWEEN MOV AH,9
  INT 21H
  MOV AX,1
  PUSH b
  CALL Calculate
  POP b
  INC b DEC CX
  CMP CX,1
  JA yhsj
;-----------------------------------------------------;
;输入询问模块
;-----------------------------------------------------;
input1:
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
;输出空格模块
;-----------------------------------------------------;
Showspace:
  MOV BX, AX
  MOV AH, 9
  MOV DX,OFFSET AHEAD   ; 首行显示空格，空格数即为输入的阶数
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
  DIV cc            ; 除以cc，再加1
  INC cc
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
  AND AX, 00FFH    ; 屏蔽高八位，取商
  PUSH AX
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
  MOV DX,OFFSET BACK
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
