;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/5/2 1:48PM
;; Title: 实验二(5):递归程序实现斐波那契数列

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
;输出一个FIN(n)=
;-----------------------------------------------------;
PRINTFIB MACRO
  PUSH BX
  PRINTSTR MSG_FIN      ;输出FIB(
  CALL TERN
  PRINTCHAR ')'
  PRINTCHAR '='
  MOV BX, CX
  CALL TERN             ;输出FIB(N)的值
  POP BX
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
  MSG_FIN DB 'FIN($'
  FLAG DB 0
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

  ;输出结果
  PRINTFIB

  MOV AX, 4C00H
  INT 21H
MAIN ENDP

;-----------------------------------------------------;
;递归求斐波那契,N存放在BX中,结果存放在CX中
;-----------------------------------------------------;
FIB PROC
  PUSH BX
  PUSH DX            ;寄存器入栈

  CMP BX, 2
  JLE FIB1            ;FIB(1)和FIB(2)

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

;-----------------------------------------------------;
;二进制转化为十进制输出
;-----------------------------------------------------;
TERN	PROC
		;二进制十进制转化
    PUSH  CX
		MOV 	FLAG,0		;标志位初始化

		MOV		CX,10000
		CALL	DEC_DIV

		MOV		CX,1000
		CALL	DEC_DIV

		MOV		CX,100
		CALL 	DEC_DIV

		MOV		CX,10
		CALL 	DEC_DIV

		MOV		CX,1
		CALL	DEC_DIV

		CMP 	FLAG,0 		;若FLAG为0则证明要输出的二进制数为0
		JG 		TEXIT
		MOV 	AH,2 		  ;若要输出的二进制数为0,则这个数不会被DIV_DEC输出
		MOV 	DL,'0' 		;因此在这里输出0
		INT 	21H
TEXIT:
    POP   CX
		RET
TERN 	ENDP

DEC_DIV PROC

    PUSH  AX
		MOV		AX,BX
		MOV 	DX,0

		DIV 	CX
		MOV		BX,DX

		MOV 	DL,AL
		ADD 	DL,30H

		CMP		FLAG,0
		JG 		FLAG1 		;FLAG为1,说明之前有非0位,直接输出
		CMP 	DL,'0' 		;FLAG非0,说明之前全部为0位,将当前位于0比较
		JE 		NP   		  ;当前位为0,不输出
		MOV 	FLAG,1 		;当前位不为0,将FLAG置1
FLAG1:
		;输出当前位
		MOV		AH,2
		INT 	21H
NP:
		;跳转至此则不输出当前位
    POP   AX
		RET
DEC_DIV	ENDP

CODESG ENDS
END MAIN
