;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/5/2 1:48PM
;; Title: 实验二(5):递归程序实现斐波拉数列

;------------------------定义符号----------------------;
CR EQU 0DH                            ;回车符的ASCII值
LF EQU 0AH                            ;换行符的ASCII值

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
;输出一个字符的内容
;-----------------------------------------------------;
PRINTCHAR MACRO CHAR
	PUSH AX
	PUSH DX

  MOV AH, 2
  MOV DL, CHAR
  INT 21H

	POP DX
	POP AX
ENDM

;-----------------------------------------------------;
;堆栈段
;-----------------------------------------------------;
STACKSG SEGMENT STACK 'S'
  DW 256 DUP('ST')
STACKSG ENDS

;-----------------------------------------------------;
;数据段
;-----------------------------------------------------;
DATASG SEGMENT
  MSG_INPUT DB 'Please input n:$'
DATASG ENDS
