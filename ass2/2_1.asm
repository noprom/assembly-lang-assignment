;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/18 9:33AM
;; Title: 实验二(1):计算杨辉三角形的前 n(n<=10)行,并显示在屏幕上

;------------------------定义符号----------------------;
CR EQU 0DH                            ;回车符的ASCII值
LF EQU 0AH                            ;换行符的ASCII值

;-----------------------宏定义区域---------------------;
;-----------------------------------------------------;
;显示内容
;-----------------------------------------------------;
PRINT	MACRO	ASC
	MOV	AH, 9
	LEA	DX, ASC
	INT	21H
ENDM

;-----------------------------------------------------;
;显示内容,并且换行
;-----------------------------------------------------;
PRINTLN	MACRO	ASC
  MOV	AH, 9
	LEA	DX, ASC
	INT	21H
	MOV	AH, 9
	LEA	DX, CR
	INT	21H
  LEA	DX, LF
	INT	21H
ENDM

;-----------------------------------------------------;
;输入字符串
;-----------------------------------------------------;
INPUT	MACRO	ASC
  MOV AH, 0AH     ;接受一串字符串
  LEA DX, ASC
  INT 21H
ENDM

;-----------------------------------------------------;
;判断输入数据是否合法
;-----------------------------------------------------;
JUDGE_INPUT MACRO NUM
  PUSH AX
  MOV AX, NUM
  CMP AX, 1
  JL L
  MOV AX, NUM
  CMP AX, 10
  JG G
L: ;输入小于1
  PRINT inputLower
  POP AX
  RETURN
G: ;输入大于10
  PRINT inputGreater
  POP AX
  RETURN

ENDM
;-----------------------------------------------------;
;十进制数转换成16位二进制
;输入:
;    ASC: ASCII 码
;    BIN: 转化之后的二进制形式
;-----------------------------------------------------;
ASC_BIN MACRO ASC, BIN
  LOCAL M1, M2

  LEA SI, ASC + 1		 ;建立输入缓冲区的地址指针
  ;SI指向十进制数缓冲区，其中第一个字节存放要转
  ;换的十进制位数，从第二个字节开始存放着十进制
  ;数的ASCII码。AX中存放转换结果。

  XOR   AX,AX
  MOV   CL,[SI]
  XOR   CH,CH     	;CX中为十进制位数
  INC   SI
  JCXZ  M2
  M1:
  MOV BX, 10
  MUL BX  		      ;(AX)乘以10

  MOV BL, [SI]		  ;得到一位十进制数的ASCII码
  INC SI	    	    ;修改地址指针
  AND BX,000FH		  ;把十进制数的ASCII码转换成十进制数
  ADD AX,BX
	LOOP M1
  M2:
  MOV BIN, AX		    ;存放输入的二进制值
ENDM

;-----------------------------------------------------;
;16位二进制转换成十进制数
;输入:
;    ASC: ASCII 码
;    BIN: 转化之后的二进制形式
;-----------------------------------------------------;
BIN_DEC	MACRO	BIN, ASC
	LOCAL	L1,L2

	LEA	SI,ASC+4
	MOV	AX,BIN
	MOV	CX,10
  L1:
	CMP	AX,0
	JE	L2
	MOV	DX,0
	DIV	CX
	OR	DL,30H
	MOV	[SI],DL
	DEC	SI
	JMP	SHORT	L1
  L2:
	NOP
ENDM

;-----------------------------------------------------;
;程序返回
;-----------------------------------------------------;
RETURN	MACRO
	MOV	AX, 4C00H
	INT	21H
ENDM
;-----------------------宏定义区域---------------------;

;-------------------------堆栈段-----------------------;
STACKSG SEGMENT STACK 'S'
  DW 64 DUP('ST')
STACKSG ENDS
;-------------------------堆栈段-----------------------;

;-------------------------数据段-----------------------;
DATASG SEGMENT
  inputMsg DB 'Please input n (n<=10):$'
  inputErr DB 'Error: n should be in range [1, 10]$'
  inputLower DB 'Error: n < 1$'
  inputGreater DB 'Error: n > 10$'
  resultMsg DB 'Result: $'
  numASC DB 5 , ? , 5 DUP(?)
  numBIN DW ?         ;输入数字的二进制
  flag DB 0                           ;判断标志位
DATASG ENDS
;-------------------------数据段-----------------------;

;-------------------------代码段-----------------------;
CODESG SEGMENT
  ASSUME CS: CODESG, DS: DATASG, SS: STACKSG
MAIN PROC FAR
  MOV AX, DATASG
  MOV DS, AX

  PRINT inputMsg  ;输入数字提示符号
  INPUT numASC    ;输入数字
  ASC_BIN numASC, numBIN  ;把输入的ASCII码转化为二进制保存到numBIN中
  ;换行回车
  mov ah, 2
  mov dl, CR
  int 21h
  mov dl, LF
  int 21h                           ;以上代码输出换行回车

  mov bx, numBIN
  call bin2dec                      ;输出numB的值
  ;JUDGE_INPUT numBIN      ;判断输入的数据是否合法
  RETURN          ;调用程序返回宏定义
MAIN ENDP

;----------------------二进制转十进制--------------------;
bin2dec proc
  mov flag, 0                         ;标志位清零

  mov cx, 10000
  call dec_div

  mov cx, 1000
  call dec_div

  mov cx, 100
  call dec_div

  mov cx, 10
  call dec_div

  mov cx, 1
  call dec_div

  cmp flag, 0                       ;若flag为0则证明要输出的二进制数为0
  jg 	exit
  mov ah, 2 		                    ;若要输出的二进制数为0,则这个数不会被dec_div输出
  MOV DL, '0' 		                  ;因此在这里输出0
  INT 21h
exit:
  ret
bin2dec endp
;----------------------二进制转十进制--------------------;
;------------------------dec_div-----------------------;
dec_div proc
  mov ax, bx
  mov dx, 0

  div cx
  mov bx, dx

  mov dl, al
  add dl, 30h

  cmp flag, 0
  jg flag1 		                     ;flag为1,说明之前有非0位,直接输出
  cmp dl, '0' 		                 ;flag非0,说明之前全部为0位,将当前位于0比较
  je exit1   		                   ;当前位为0,不输出
  mov flag, 1 		                 ;当前位不为0,将flag置1

flag1:                             ;输出当前位
  mov ah, 2
  int 21h
exit1:
  ;跳转至此则不输出当前位
  ret
dec_div endp
;------------------------dec_div-----------------------;
CODESG ENDS
END MAIN
;-------------------------代码段-----------------------;
