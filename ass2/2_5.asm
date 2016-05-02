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

;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODESG SEGMENT
  ASSUME CS: CODESG, DS: DATASG, SS: STACKSG

MAIN PROC FAR
  MOV AX, DATASG
  MOV DS, AX

  PRINTSTR MSG_INPUT
INPUTN:             ;输入N并且保存在BX中
  MOV AH, 1
  INT 21H
  SUB AL, 30H       ;转为二进制
  JL CONTINUE
  CMP AL, 9
  JG CONTINUE
  CBW               ;AL扩展为AX
  XCHG AX, BX
  MOV CX, 10
  MUL CX
  XCHG AX, BX       ;BX中的数据乘10
  ADD BX, AX        ;加上现在读入的数字
  JMP INPUTN
CONTINUE:
  CALL FIB



  MOV AX, 4C00H
  INT 21H
MAIN ENDP

;-----------------------------------------------------;
;递归求斐波拉,N存放在BX中,结果存放在CX中
;-----------------------------------------------------;
FIB PROC
  PUSH BX
  PUSH DX            ;寄存器入栈

  CMP BX, 1
  JLE FIB1            ;FIB(1)

  DEC BX
  CALL FIB            ;FIB(N-1)
  MOV DX, CX          ;[DX]=FIB(N-1)

  DEC BX
  CALL FIB            ;FIB(N-2)
  MOV AX, CX          ;[AX]=FIB(N-2)

  ADD AX, DX          ;[AX]=FIB(N)
  MOV CX, AX
  JMP EXIT_FIB        ;CX中保存FIB(N)
FIB1:
  MOV CX, 1
EXIT_FIB:
  POP DX
  POP BX             ;寄存器出栈
  RET
FIB ENDP
CODESG ENDS
END MAIN
