CR        MACRO
          PUSH  AX
          PUSH  DX

          MOV  	AH,2 		    ;OUTPUT CR
          MOV  	DL,0DH    	;OUTPUT CR
       	  INT  	21H       	;OUTPUT CR
         	MOV  	DL,0AH    	;OUTPUT CR
         	INT  	21H       	;OUTPUT CR

          POP   DX
          POP   AX
          ENDM
STACKSG   SEGMENT   STACK 'S'
          DW  256  DUP('ST')
STACKSG	  ENDS

DATA      SEGMENT
          FLAG  DB  0
          TEMP1 DW  0
          TEMP2 DW  0
DATA		  ENDS

CODE      SEGMENT
          ASSUME 	CS:CODE, DS:DATA, SS:STACKSG
MAIN      PROC	FAR
          MOV 	AX,DATA
      		MOV		DS,AX

INPUTS:
		      ;循环读入A
		      MOV 	AH,1
		      INT 	21H
          SUB 	AL,30H		;ASCII转化为二进制数
          JL		CP
		      CMP		AL,9
		      JG		CP 		    ;输入不是数字则终止A的输入
          CBW					    ;AL-->AX,AL位拓展
		      XCHG	AX,BX
		      MOV		CX,10
		      MUL		CX			  ;AX*10-->AX
		      XCHG	AX,BX
          ;以上代码将原来BX中的数据乘10
          ADD		BX,AX 		;AX+BX-->BX
          JMP 	INPUTS	  ;继续输入A
CP:
          CALL  FIBONACCI


          MOV   BX,CX
          CALL  TERN

M_EXIT:
          MOV   AX,4C00H
          INT   21H
MAIN	    ENDP

FIBONACCI PROC
          PUSH  BX
          PUSH  DX

          CMP   BX,1
          JLE   D1

          DEC   BX
          CALL  FIBONACCI
          MOV   DX,CX


          DEC   BX
          CALL  FIBONACCI
          MOV   AX,CX

          ADD   AX,DX
          MOV   CX,AX
          JMP   F_EXIT
D1:
          MOV   CX,1
F_EXIT:
          POP   DX

          POP   BX
          RET
FIBONACCI ENDP
;===============================================
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
;===============================================

;===============================================
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
;===============================================

CODE	    ENDS
          END   MAIN
