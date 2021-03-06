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
;输出一个字符串的内容
;-----------------------------------------------------;
PRINTSTR MACRO ASC
	PUSH AX
	PUSH DX

	MOV	AH, 9
	LEA	DX, ASC
	INT	21H

	POP DX
	POP AX
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
  MOV DL, CR
  INT 21H
  MOV DL, 0AH
  INT 21H
ENDM

;-----------------------------------------------------;
;输入,数字存放在BP中
;-----------------------------------------------------;
INPUTN MACRO
	LOCAL START, INPUT_N, JUDGE, CONTINUE
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
  CMP AL, CR
  JZ JUDGE       			  ;如果回车则输入完毕
  SUB AL, 30H 					;转为十六位二进制数
  CBW         					;字节扩展为字
  XCHG AX, BP 					;交换到AX中
  MUL BX      					;扩大十倍
  ADD BP, AX  					;加一位
  LOOP INPUT_N

JUDGE:
	CMP BP, 0             ;输入的数存在BP，与0比较
	JG CONTINUE           ;如果输入的数字>0,继续判断
	PRINTLN ERROR         ;否则提示错误的输入信息
	JMP START             ;无条件跳转到MAIN，重新开始
CONTINUE:
	CMP BP,11             ;输入的数存在BP，与11比较
	JB OK                 ;如果输入的数字<11则满足条件，允许执行
	PRINTLN ERROR         ;否则提示错误的输入信息
	JMP START             ;无条件跳转到MAIN，重新开始
OK:
	ENTER                 ;换行
	POP AX
	POP BX
	POP CX
ENDM

;-----------------------------------------------------;
;计算杨辉三角
;-----------------------------------------------------;
CALCULATE MACRO
LOCAL START, EXIT
	MOV AX, BP            ;准备显示杨辉三角,AX=BP=输入的阶数
  PRINTCHAR '1'         ;输出第一个1
  CMP BP, 2             ;将阶数与2进行比较
  JB EXIT               ;小于则直接退出
  MOV b, 2              ;b=2
  MOV CX, BP            ;此时CX=阶数
  MOV a, BP             ;a=阶数
  DEC a
START:
  MOV c, 1
  ENTER
  DEC BP
  MOV AX, BP						;此时AX=阶数
  PRINTCHAR '1'         ;首个数字为1
  PRINT SPACE1
  MOV AX, 1
  PUSH b
  CALL CALCNUM
  POP b
  INC b
  DEC CX
  CMP CX, 1
  JA START
EXIT:
ENDM

;-----------------------------------------------------;
;输出空格
;-----------------------------------------------------;
PRINTSPACE MACRO
	LOCAL S
	PUSH AX
	PUSH CX								;寄存器入栈

	MOV CX, AX						;CX=要显示的空格个数
S:PRINTSTR SPACE2				;打印空格
  LOOP S

	POP CX
	POP AX								;寄存器出栈
ENDM
;-------------------------堆栈段-----------------------;
STACKSG SEGMENT STACK 'S'
  DW 64 DUP('ST')
STACKSG ENDS
;-----------------------------------------------------;
;数据段定义
;-----------------------------------------------------;
DATASG SEGMENT
  MSG DB 'Please input n(n<=10): $'
  ERROR DB 'N must in the range of [1, 10]$'
  SPACE1 DB '     $'      ;首数字1之后的空格
  SPACE2 DB ' $'          ;与数字位数相关的空格
  a DW ?               		;a为阶数
  b DW ?               		;b为行数
  c DW ?               		;c为计算时每一项的中间除数,依次递增
  d DW ?               		;记录位数，用来控制空格的数目
DATASG ENDS
;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODESG SEGMENT
  ASSUME CS: CODESG,DS: DATASG,SS: STACKSG
MAIN PROC
  MOV AX,DATASG
  MOV DS,AX

	INPUTN							 	 ;输入N,直到在1-10之间
	CALCULATE						 	 ;计算并且显示杨辉三角

  MOV AH,4CH
  INT 21H
MAIN ENDP

;-----------------------------------------------------;
;计算每一项数值
;-----------------------------------------------------;
CALCNUM PROC
	DEC b     						;b每次减1相乘
  MUL b
  DIV c             		;除以c，再加1
  INC c
  CMP b, 0           		;b是否为0
  JZ ok1

  PUSH AX           		;保存所得数据
  MOV d, 0           		;此处d为位数，为了显示后面的空格
  CALL PRINTNUM
  MOV AX, 6          		;预设，总共显示的空格数为6个单位
  SUB AX, d          		;还需显示多少空格
	PRINTSPACE						;打印该数字之后的空格
  POP AX								;恢复AX中的数据
  CALL CALCNUM      		;继续下一次计算
ok1:
  RET
CALCNUM ENDP

;-----------------------------------------------------;
;显示一项数字
;-----------------------------------------------------;
PRINTNUM PROC
  MOV BX, 10       			;BX中存除数10
  CMP AX, 0
  JZ ok2           			;除法运算是否完毕
  INC d            			;此处d为位数，以确定输出的空格数
  DIV BL           			;除以10，整数商存在AL，余数存在AH
  PUSH AX
  AND AX, 00FFH    			;屏蔽高八位，取商
  CALL PRINTNUM
  POP DX
  MOV DL, DH       			;取出高八位，即为要显示的余数
  OR DL, 30H       			;转为ASCII码
  MOV AH, 2        			;显示出数字
  INT 21H
ok2:
  RET
PRINTNUM ENDP

CODESG ENDS
END MAIN
