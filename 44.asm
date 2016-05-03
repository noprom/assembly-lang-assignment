RAND      MACRO NUM
          LOCAL WLOP
          PUSH  AX
          PUSH  DX
          PUSH  CX
          MOV   CX,1
          XOR   AH,AH
          INT   1AH
          ADD   DL,DH
          MOV   AL,DL
          AND   AL,00111111B
          MOV   CL,NUM
          DIV   CL

          MOV   BX,0
          OR    BL,AH

          POP   CX
          POP   DX
          POP   AX
          ENDM
STACKSG   SEGMENT   STACK 'S'
          DW  64  DUP('ST')
STACKSG	  ENDS

DATA      SEGMENT
          FLAG  DB  0
          COLOR DB  0FH
          CNT1  DB  2
          CNT2  DB  10
          X     DW  40
          Y     DW  10
DATA		  ENDS

CODE      SEGMENT
          ASSUME 	CS:CODE, DS:DATA, SS:STACKSG
MAIN      PROC	FAR
          MOV 	AX,DATA
      		MOV		DS,AX

          MOV     AH,35H		;取原1CH中断向量
	        MOV     AL,1CH
	        INT     21H

	        PUSH    ES		;保存原1CH中断向量
	        PUSH    BX

	        PUSH    DS
	        MOV     DX,SEG INT_1CH
	        MOV     DS,DX
	        LEA     DX,INT_1CH
	        MOV     AH,25H		  ;设置新1CH中断向量
	        MOV     AL,1CH
	        INT     21H
	        POP     DS

	        IN      AL,21H
	        AND     AL,11111100B	  ;增设键盘和定时器中断
	        OUT     21H,AL

          STI
          MOV   AH,6
          MOV   AL,0
          MOV   BH,0FH
          MOV   CH,0
          MOV   CL,0
          MOV   DH,80
          MOV   DL,80
          INT   10H

          MOV   AH,2
          MOV   BH,0
          MOV   DL,BYTE PTR X      ;X
          MOV   DH,BYTE PTR Y      ;Y
          INT   10H
Q:
          PUSH  AX
          MOV   AH,1
          INT   21H
          OR    AL,20H
          CMP   AL,'q'
          JE    M_EXIT
          JMP   Q

M_EXIT:
          MOV   AX,4C00H
          INT   21H
MAIN	    ENDP

INT_1CH PROC	FAR		;新1CH中断处理子程序
        	PUSH	AX		;保存寄存器
        	PUSH	BX
        	PUSH	CX
        	PUSH	DX
        	PUSH	DS

        	STI			;开中断
CHK1:
          DEC   CNT1
          CMP   CNT1,1
          JE    MOVE
CHK2:
          DEC   CNT2
          CMP   CNT2,0
          JE    BG
          JMP   EXIT
MOVE:
          CALL  MOVESTAR
          MOV   CNT1,2
          JMP   CHK2
BG:
          CALL  CHANGEBG
          MOV   CNT2,10
EXIT:
          CLI			;关中断

	        POP	DS
	        POP	DX
	        POP	CX
	        POP	BX
         	POP	AX		;恢复寄存器

         	IRET			;中断返回

INT_1CH   ENDP

CHANGEBG  PROC
          PUSH  AX
          PUSH  BX
          PUSH  CX
          PUSH  DX

          ADD   COLOR,10H
          AND   COLOR,01111111B

          MOV   BH,COLOR
          MOV   AH,6
          MOV   AL,0
          MOV   CH,0
          MOV   CL,0
          MOV   DH,80
          MOV   DL,80
          INT   10H

          POP   DX
          POP   CX
          POP   BX
          POP   AX
          RET
CHANGEBG  ENDP

MOVESTAR  PROC
          PUSH  AX
          PUSH  BX
          PUSH  CX
          PUSH  DX

          RAND  10

          CMP   BX,0
          JE    D0
          CMP   BX,1
          JE    D1
          CMP   BX,2
          JE    D2
          CMP   BX,3
          JE    D3
          CMP   BX,4
          JE    D4
          CMP   BX,5
          JE    D5
          CMP   BX,6
          JE    D6
          CMP   BX,7
          JE    D7
          CMP   BX,8
          JE    D0
          CMP   BX,9
          JE    D2
D0:
          SUB   X,1
          SUB   Y,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
D7:
          SUB   Y,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
D3:
          ADD   X,1
          SUB   Y,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
D1:
          SUB   X,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
D4:
          ADD   X,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
D5:
          SUB   X,1
          ADD   Y,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
D6:
          ADD   Y,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
D2:
          ADD   X,1
          ADD   Y,1
          CALL  SHOWSTAR
          JMP   MO_EXIT
MO_EXIT:
          POP   DX
          POP   CX
          POP   BX
          POP   AX
          RET
MOVESTAR  ENDP

SHOWSTAR  PROC
          PUSH  AX
          PUSH  BX
          PUSH  DX

          MOV   BH,COLOR
          MOV   AH,6
          MOV   AL,0
          MOV   CH,0
          MOV   CL,0
          MOV   DH,80
          MOV   DL,80
          INT   10H

          MOV   AH,2
          MOV   BH,0
          MOV   DL,BYTE PTR X      ;X
          MOV   DH,BYTE PTR Y      ;Y
          INT   10H

          MOV   AH,2
          MOV   DL,'*'
          INT   21H

          POP   DX
          POP   BX
          POP   AX
          RET
SHOWSTAR  ENDP
CODE	    ENDS
          END   MAIN
