;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/18 9:33AM
;; Title: 实验二(1):计算杨辉三角形的前 n(n<=10)行,并显示在屏幕上

;------------------------定义符号----------------------;
CR EQU 0DH                            ;回车符的ASCII值
LF EQU 0AH                            ;换行符的ASCII值

;-----------------------------------------------------;
;输出一个字符串的内容
;-----------------------------------------------------;
PRINT	MACRO	ASC
	MOV	AH, 9
	LEA	DX, ASC
	INT	21H
ENDM

;-----------------------------------------------------;
;输出一个字符的内容
;-----------------------------------------------------;
PRINTCHAR MACRO CHAR
  MOV AH, 2
  MOV DL, CHAR
  INT 21H
ENDM

;-----------------------------------------------------;
;输出一个字符串的内容,并且换行
;-----------------------------------------------------;
PRINTLN	MACRO	ASC
	MOV	AH, 9
	LEA	DX, ASC
	INT	21H
	PRINTCHAR CR
  PRINTCHAR LF
ENDM

;-----------------------------------------------------;
;换行宏定义
;-----------------------------------------------------;
ENTER MACRO
  MOV AH, 2
  MOV DL, 0DH
  INT 21H
  MOV DL, 0AH
  INT 21H
ENDM

;-----------------------------------------------------;
;输出空格
;-----------------------------------------------------;
PRINTSPACE MACRO
	LOCAL next, done

  MOV BX, AX
  MOV AH, 9
  LEA DX, BACK
next:
  CMP BX, 0
  JZ done
  INT 21H
  DEC BX
  JMP next
done:
  NOP
ENDM

;-----------------------------------------------------;
;输入,数字存放在BP中
;-----------------------------------------------------;
INPUTN MACRO
	LOCAL START, INPUT_N
	PUSH CX
	PUSH BX
	PUSH AX

START:
  PRINT MSG  					 	;输出字符串，请输入一个数
  XOR BP, BP  					;BP清零
  MOV BX, 10
  MOV CX, 3   					;控制输入的位数,2位数加上一个回车
INPUT_N:
  MOV AH, 1   					;从键盘读入数据
  INT 21H
  CMP AL, 0DH
  JZ OK       					;如果回车则输入完毕
  SUB AL, 30H 					;转为十六位二进制数
  CBW         					;字节扩展为字
  XCHG AX, BP 					;交换到AX中
  MUL BX      					;扩大十倍
  ADD BP, AX  					;加一位
  LOOP INPUT_N

	CMP BP, 0             ; 输入的数存在BP，与0比较
	JG J1                 ; 如果输入的数字>0,继续判断
	PRINTLN ERROR         ; 否则提示错误的输入信息
	JMP START             ; 无条件跳转到MAIN，重新开始
	J1:CMP BP,11          ; 输入的数存在BP，与11比较
	JB MZTJ               ; 如果输入的数字<11则满足条件，允许执行
	PRINTLN ERROR         ; 否则提示错误的输入信息
	JMP START             ; 无条件跳转到MAIN，重新开始
OK:
	POP AX
	POP BX
	POP CX
ENDM

;-------------------------堆栈段-----------------------;
STACKSG SEGMENT STACK 'S'
  DW 64 DUP('ST')
STACKSG ENDS
;-----------------------------------------------------;
;数据段定义
;-----------------------------------------------------;
DATA SEGMENT
  MSG DB 'Please input n(n<=10): $'
  CON DB 'Do you want to continue?(Y/N): $'
  ERROR DB 'N must in the range of [1, 10]$'
  BETWEEN DB '     $'     ;第1种是首数字1之后的空格
  BACK DB ' $'            ;第2种是和需显示的数字位数相关的空格
  a DW ?               		;a为阶数
  b DW ?               		;b为行数
  c DW ?               		;c为计算时每一项的中间除数,依次递增
  d DW ?               		;记录位数，用来控制空格的数目
DATA ENDS
;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODE SEGMENT
  ASSUME CS:CODE,DS:DATA,SS:STACKSG
MAIN PROC
  MOV AX,DATA
  MOV DS,AX

	INPUTN								;输入N,直到在1-10之间

MZTJ:
  ENTER                 ; 换行
  MOV AX, BP            ; 准备显示杨辉三角,AX=BP=输入的阶数
  PRINTCHAR '1'         ; 输出第一个1
  CMP BP, 2             ; 将阶数与2进行比较
  JB  exit              ; 小于则直接退出
  MOV b, 2              ; b=2
  MOV CX, BP            ; 此时CX=阶数
  MOV a, BP             ; a=阶数
  DEC a
  CALL CALCYHSJ         ; 调用CALCYHSJ子程序

exit:
  MOV AH,4CH
  INT 21H
;-----------------------------------------------------;
;输出杨辉三角
;-----------------------------------------------------;
CALCYHSJ:
  MOV c, 1
  ENTER
  DEC BP
  MOV AX, BP
  PRINTCHAR '1'        ; 首个数字为1
  PRINT BETWEEN
  MOV AX,1
  PUSH b
  CALL CALCNUM
  POP b
  INC b
  DEC CX
  CMP CX,1
  JA CALCYHSJ

;-----------------------------------------------------;
;核心计算模块
;-----------------------------------------------------;
CALCNUM: DEC b    ; b每次减1相乘
  MUL b
  DIV c             ; 除以c，再加1
  INC c
  CMP b,0           ; b是否为0
  JZ ok1

  PUSH AX           ; 保存所得数据
  MOV d,0           ; 此处d为位数，为了显示后面的空格
  CALL PRINTNUM
  MOV AX,6          ; 预设，总共显示的空格数为6个单位
  SUB AX,d          ; 还需显示多少空格
	PRINTSPACE
  POP AX
  CALL CALCNUM    ; 继续执行
ok1:
  RET
;-----------------------------------------------------;
;显示模块
;-----------------------------------------------------;
PRINTNUM:
  MOV BX, 10       ; BX中存除数10
  CMP AX, 0
  JZ ok2           ; 除法运算是否完毕
  INC d            ; 此处d为位数，以确定输出的空格数
  DIV BL           ; 除以10，整数商存在AL，余数存在AH
  PUSH AX
  AND AX, 00FFH    ; 屏蔽高八位，取商
  CALL PRINTNUM
  POP DX
  MOV DL, DH       ; 取出高八位，即为要显示的余数
  OR DL, 30H       ; 转为ASCII码
  MOV AH, 2        ; 显示出数字
  INT 21H
ok2:
  RET

CODE ENDS
END MAIN
