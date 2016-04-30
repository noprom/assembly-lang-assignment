;宏指令输出回车
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
;宏指令输出信息
OUTMSG    MACRO MSG
          PUSH  AX
          PUSH  DX
          MOV   AH,9
          LEA   DX,MSG
          INT   21H
          POP   DX
          POP   AX
          ENDM
;宏指令读入成绩，CLA为科目，默认的TAB表起始地址存储在BP中
INSCORE   MACRO CLA
          LOCAL INPUTS,CP   ;CP(COPY)
          PUSH  AX
          PUSH  BX
          PUSH  CX
          MOV   BX,0
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
          MOV   WORD PTR TAB[BP].&CLA,BX  ;将分数存入表中
          POP   CX
          POP   BX
          POP   AX
          ENDM
;输出一个表项的全部内容 格式为  姓名，学号
;                          成绩1，成绩2，成绩3，总分
OUTALL    MACRO
          PUSH  AX
          PUSH  DX
          PUSH  BX
          MOV   AH,9
          LEA   DX,TAB[BP]
          INT   21H
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   AH,9
          LEA   DX,TAB[BP+11]
          INT   21H
          CR
          MOV   BX,WORD PTR TAB[BP].S1
          CALL  TERN
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   BX,WORD PTR TAB[BP].S2
          CALL  TERN
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   BX,WORD PTR TAB[BP].S3
          CALL  TERN
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   BX,WORD PTR TAB[BP].TT
          CALL  TERN
          CR
          POP   BX
          POP   DX
          POP   AX
          ENDM
;测试用简易输出
OUTNAME   MACRO
          PUSH  AX
          PUSH  BP
          PUSH  BX
          PUSH  DX
          MOV   AH,9
          LEA   DX,TAB[BP]
          INT   21H
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   AH,9
          LEA   DX,TAB[BP+11]
          INT   21H
          CR
          POP   DX
          POP   BX
          POP   BP
          POP   AX
          ENDM
;相邻交换宏指令，起始地址存储在BP内，将BP单元的内容与BP＋30单元的内容交换
SWAP      MACRO
          LOCAL CNT
          PUSH  AX
          PUSH  CX
          PUSH  DI
          MOV   DI,0
          MOV   CX,30
CNT:
          MOV   AL,BYTE PTR TAB[BX][DI]
          MOV   AH,BYTE PTR TAB[BX+30][DI]
          MOV   BYTE PTR TAB[BX][DI],AH
          MOV   BYTE PTR TAB[BX+30][DI],AL
          INC   DI
          CMP   DI,CX
          JL    CNT
          POP   DI
          POP   CX
          POP   AX
          ENDM
;输出宏指令，X内为要输出的信息的个数，执行后输出前X项
OUTSCRIPT MACRO X
          LOCAL LOP
          PUSH  BP
          PUSH  BX
          PUSH  AX
          MOV   AX,X
          MOV   BP,0
          MOV   BX,0
LOP:
          OUTALL
          ADD   BP,30
          INC   BX
          CMP   BX,AX
          JL    LOP
          POP   AX
          POP   BX
          POP   BP
          ENDM

STACKSG   SEGMENT   STACK 'S'
          DW  64  DUP('ST')
STACKSG	  ENDS
;学生信息结构
STU       STRUC
          NAM   DB  11 DUP(?)   ;姓名
          NUM   DB  11 DUP(?)   ;学好
          S1    DW  ?
          S2    DW  ?
          S3    DW  ?
          TT    DW  ?           ;总分
STU       ENDS

DATA      SEGMENT
          BUF   DB  50
                DB  0
                DB  50  DUP(?)
          TAB   STU 10  DUP(<>)
          SZ    DB  30
          FLAG  DB  0
          HM    DW  10      ;HOW MANY，即输入项个数，上限为10（TAB表上限为10）
          MSG0  DB  '====INPUT START!====',13,10,'$'
          MSG1  DB  '====INPUT NAME,NUMBER,S1,S2,S3====',13,10,'$'
          MSG2  DB  '====SINGLE INPUT DONE====',13,10,'$'
          MSG3  DB  '====ALL INPUTS DONE====',13,10,'$'
          MSG4  DB  '====SOTR START====',13,10,'$'
          MSG5  DB  '========TEST=========',13,10,'$'
          MSG6  DB  '=============================',13,10,'$'
          OPTS1 DB  '====1:SHOW TOP 3 STUDENTS====',13,10,'$'
          OPTS2 DB  '====2:SHOW NO.1 - N0.5   ====',13,10,'$'
          OPTS3 DB  '====3:EXIT               ====',13,10,'$'
          MSG7  DB  '====INPUT NUMBER MUST BETWEEN 1 AND 3====',13,10,'$'
DATA		  ENDS

CODE      SEGMENT
          ASSUME 	CS:CODE, DS:DATA, SS:STACKSG
MAIN      PROC	FAR
          MOV 	AX,DATA
      		MOV		DS,AX
          OUTMSG  MSG0

          CALL  INPUTALL  ;输入子程序

          OUTMSG  MSG6
          OUTMSG  OPTS1
          OUTMSG  OPTS2
          OUTMSG  OPTS3
          OUTMSG  MSG6

HEAD:
          MOV   AH,1
          INT   21H
          SUB   AL,30H
          CR
          CMP   AL,1
          JE    F1      ;成绩排序，输出前三
          CMP   AL,2
          JE    CATCH2  ;学号排序，输出前五
          CMP   AL,3
          JE    CATCH3  ;结束
          OUTMSG  MSG7
          JMP   HEAD
CATCH2:
          JMP   F2
CATCH3:
          JMP   M_EXIT
F1:
          CALL  SORTA
          MOV   AX,3
          OUTSCRIPT   AX
          OUTMSG  MSG6
          JMP   HEAD
F2:
          CALL  SORTB
          MOV   AX,5
          OUTSCRIPT   AX
          OUTMSG  MSG6
          JMP   HEAD

M_EXIT:
          MOV   AX,4C00H
          INT   21H
MAIN	    ENDP
;根据成绩进行排序
SORTA     PROC
          PUSH  AX
          PUSH  BX
          PUSH  CX
          PUSH  DI
          MOV   DI,HM
          DEC   DI
LOPA1:
          MOV   CX,DI
          MOV   BX,0
LOPA2:
          MOV   AX,WORD PTR TAB[BX].TT
          CMP   AX,WORD PTR TAB[BX+30].TT
          JGE   CONTA1
          SWAP
CONTA1:
          ADD   BX,30
          LOOP  LOPA2
          DEC   DI
          JNZ   LOPA1
          POP   DI
          POP   CX
          POP   BX
          POP   AX
          RET
SORTA     ENDP
;根据学号排序
SORTB     PROC
          PUSH  AX
          PUSH  BX
          PUSH  CX
          PUSH  DI
          PUSH  SI
          MOV   DI,HM
          DEC   DI
LOPB1:
          MOV   CX,DI
          MOV   BX,0
LOPB2:
          MOV   SI,-1
LOPB3:
          INC   SI
          MOV   AL,BYTE PTR TAB[BX+11][SI]
          CMP   AL,BYTE PTR TAB[BX+41][SI]
          JE    LOPB3
          JL    CONTB1
          SWAP
CONTB1:
          ADD   BX,30
          LOOP  LOPB2
          DEC   DI
          JNZ   LOPB1
          POP   SI
          POP   DI
          POP   CX
          POP   BX
          POP   AX
          RET
SORTB     ENDP
;输入函数
INPUTALL  PROC
          PUSH  AX
          PUSH  BX
          PUSH  CX
          PUSH  BP

          MOV   CX,0
          MOV   BP,0
INPUT:
          OUTMSG MSG1
          CALL  INNAME
          CALL  INNUM
          INSCORE   S1
          INSCORE   S2
          INSCORE   S3
          MOV   AX,WORD PTR TAB[BP].S1
          ADD   AX,WORD PTR TAB[BP].S2
          ADD   AX,WORD PTR TAB[BP].S3
          MOV   WORD PTR TAB[BP].TT,AX
          ADD   BP,30
          INC   CX
          CMP   CX,HM
          OUTMSG MSG2
          JL    CATCH
          JMP   EXIT1
CATCH:
          JMP   INPUT
EXIT1:
          POP   BP
          POP   CX
          POP   BX
          POP   AX
          OUTMSG MSG3
          RET
INPUTALL  ENDP
;输入名字
INNAME    PROC
          PUSH  AX
          PUSH  BX
          PUSH  DX
          PUSH  DI
          PUSH  BP
          MOV   AH,10
          LEA   DX,BUF
          INT   21H
          CR
          MOV   BL,BUF+1
          MOV   BH,0
          ;BX内为字符串长度
          MOV   BYTE PTR BUF+2[BX],'$'
          INC   BX
          MOV   DI,0
CPNM:
          MOV   AL,BYTE PTR BUF[2+DI]
          MOV   BYTE PTR TAB[BP][DI],AL
          INC   DI
          CMP   DI,BX
          JL    CPNM
          POP   BP
          POP   DI
          POP   DX
          POP   BX
          POP   AX
          RET
INNAME    ENDP
;输入学好
INNUM     PROC
          PUSH  AX
          PUSH  BX
          PUSH  DX
          PUSH  DI
          PUSH  BP
          MOV   AH,10
          LEA   DX,BUF
          INT   21H
          CR
          MOV   BL,BUF+1
          MOV   BH,0
          ;BX内为字符串长度
          MOV   BYTE PTR BUF+2[BX],'$'
          INC   BX
          MOV   DI,0
CPNUM:
          MOV   AL,BYTE PTR BUF[2+DI]
          MOV   BYTE PTR TAB[BP+11][DI],AL
          INC   DI
          CMP   DI,BX
          JL    CPNUM
          POP   BP
          POP   DI
          POP   DX
          POP   BX
          POP   AX
          RET
INNUM     ENDP

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

CODE	    ENDS
		      END   MAIN
