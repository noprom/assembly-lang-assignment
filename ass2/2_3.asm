;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/30 10:25AM
;; Title: 实验二(3):
;; (1)键入某组学生的学号、姓名、组成原理考试成绩、数据结构考试成绩、汇编语言考试成绩;
;; (2)对学生数据进行排序，按照三科总分降序排列;
;; (3)按此排序结果在屏幕上显示前三名学生的成绩;
;; (4)在屏幕上显示学号最靠前的5名学生的成绩

;------------------------定义符号----------------------;
CR EQU 0DH                            ;回车符的ASCII值
LF EQU 0AH                            ;换行符的ASCII值

;-----------------------------------------------------;
;输入字符串
;-----------------------------------------------------;
INPUTSTR	MACRO	STR
  MOV AH, 0AH     ;接受一串字符串
  LEA DX, STR
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
;输出一个字符串的内容,并且换行
;-----------------------------------------------------;
PRINTLNSTR MACRO ASC
	PUSH AX
	PUSH DX

	MOV	AH, 9
	LEA	DX, ASC
	INT	21H
  PRINTCHAR CR
  PRINTCHAR LF

	POP DX
	POP AX
ENDM

;-----------------------------------------------------;
;换行
;-----------------------------------------------------;
HUANHANG MACRO
	PRINTCHAR CR
  PRINTCHAR LF
ENDM

;-----------------------------------------------------;
;返回程序
;-----------------------------------------------------;
RETURN MACRO
	MOV AX, 4C00H
  INT 21H
ENDM

;-----------------------------------------------------;
;输入学生姓名获得学号的宏定义
;参数: TAB中的偏移量
;-----------------------------------------------------;
INPUT_INFO MACRO OFFSET
  LOCAL LOOP_INPUT
  PUSH AX
  PUSH BX
  PUSH BP
  PUSH CX
  PUSH DX
  PUSH SI               ;寄存器入栈

  INPUTSTR BUF
  HUANHANG
  MOV BL, BUF + 1       ;输入字符串真实长度
  AND BX, 00FFH         ;BX存放字符串长度
  MOV BYTE PTR BUF[2+BX], '$'
  INC BX
  MOV CX, BX            ;设置循环次数
  MOV SI, 0             ;变址寄存器清零, 用来定位输入字符

  ;为BP对应的学生的姓名|学号的对应位置赋值
LOOP_INPUT:
  MOV AL, BYTE PTR BUF[2+SI]
  MOV BYTE PTR TAB[BP + OFFSET][SI], AL
  INC SI
  LOOP LOOP_INPUT

  POP SI
  POP DX
  POP CX
  POP BP
  POP BX
  POP AX                ;寄存器出栈
ENDM

;-----------------------------------------------------;
;输入学生姓名的分数
;参数: 数据段中各科的名称
;-----------------------------------------------------;
INPUT_SCORE MACRO SUBJ
  LOCAL INPUT, MOVE
  PUSH AX
  PUSH BX
  PUSH CX               ;寄存器入栈

  MOV BX, 0
INPUT:
  MOV AH, 1
  INT 21H
  SUB AL, 30H           ;ASCII转化为二进制数
  JL MOVE
  SUB AL, 39H
  JG MOVE               ;输入不是数字则停止输入
  CBW                   ;否则对AL进行位扩展
  XCHG AX, BX
  MOV CX, 10
  MUL CX
  XCHG AX, BX           ;将BX原来的数字乘10
  ADD BX, AX
  JMP INPUT             ;继续输入下一个数字

MOVE:
  MOV WORD PTR TAB[BP].&SUBJ, BX  ;保存分数

  POP CX
  POP BX
  POP AX                ;寄存器出栈
ENDM

;-----------------------------------------------------;
;交换相邻学生结构体中的数据,起始地址位于BX中
;-----------------------------------------------------;
SWAP_STU MACRO
  LOCAL LOP
  PUSH AX
  PUSH CX
  PUSH SI               ;寄存器入栈

  MOV SI, 0
  MOV CX, 30
LOP:
  MOV AL, BYTE PTR TAB[BX][SI]
  MOV AH, BYTE PTR TAB[BX+30][SI]
  MOV BYTE PTR TAB[BX+30][SI], AL
  MOV BYTE PTR TAB[BX][SI], AH
  INC SI
  LOOP LOP

  POP SI
  POP CX
  POP AX                ;寄存器出栈
ENDM

OUTALL    MACRO
          PUSH  AX
          PUSH  DX
          PUSH  BX
          MOV   AH,9
          LEA   DX,TAB[BP].NAM
          INT   21H
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   AH,9
          LEA   DX,TAB[BP].ID
          INT   21H
          HUANHANG
          MOV   BX,WORD PTR TAB[BP].S_ZC
          CALL  TERN
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   BX,WORD PTR TAB[BP].S_DS
          CALL  TERN
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   BX,WORD PTR TAB[BP].S_HB
          CALL  TERN
          MOV   AH,2
          MOV   DL,','
          INT   21H
          MOV   BX,WORD PTR TAB[BP].S_AL
          CALL  TERN
          HUANHANG
          POP   BX
          POP   DX
          POP   AX
ENDM

PRINT_STU_ITEM MACRO
  PUSH AX
  PUSH BX
  PUSH BP
  PUSH DX

  PRINTSTR TAB[BP].NAM              ;输出姓名
  ;PRINTCHAR ','
  PRINTSTR TAB[BP].ID               ;输出学号
  ;PRINTCHAR ','
  MOV BX, WORD PTR TAB[BP].S_ZC     ;组成原理成绩
  CALL TERN
  PRINTCHAR ','
  MOV BX, WORD PTR TAB[BP].S_DS     ;数据结构成绩
  CALL TERN
  PRINTCHAR ','
  MOV BX, WORD PTR TAB[BP].S_HB     ;汇编语言成绩
  CALL TERN
  PRINTCHAR ','
  MOV BX, WORD PTR TAB[BP].S_AL     ;总成绩
  CALL TERN
  HUANHANG

  POP DX
  POP BP
  POP BX
  POP AX
ENDM
;-----------------------------------------------------;
;堆栈段
;-----------------------------------------------------;
STACKSG SEGMENT STACK 'S'
  DW 64 DUP('ST')
STACKSG ENDS

;-----------------------------------------------------;
;定义学生信息结构体
;-----------------------------------------------------;
STU STRUC
  NAM  DB 10 DUP(?)   ;姓名
  ID   DB 10 DUP(?)   ;学号
  S_ZC DW ?           ;组成原理成绩
  S_DS DW ?           ;数据结构成绩
  S_HB DW ?           ;汇编成绩
  S_AL DW ?           ;总成绩
  NO   DW ?           ;成绩排名
STU ENDS

;-----------------------------------------------------;
;数据段
;-----------------------------------------------------;
DATASG SEGMENT
  TAB STU 10 DUP(<>)          ;存放10个学生的成绩
  BUF DB  30, ?, 30 DUP(?)    ;输入缓冲区
  STU_NUM DW 3               ;学生的个数
  FLAG DB  0                  ;二进制转十进制用
  MSG_INPUT1 DB 'Please input 10 students'' info, every line please input only one value$'
  MSG_INPUT2 DB 'Order: name, number, component score, data structure score, assemlby score$'
  MSG_INPUT3 DB 'Please input a student'' name, id and score, every line has only one field:$'
  MSG_INPUT4 DB 'The student'' info has been recorded.$'
  MSG_SELECT DB 'Please select a number:$'
  MSG_S_ERR  DB 'Choice must between 1 and 3$'
  MSG_TAB    DB '----- 1: Show top 3       -----', CR, LF
             DB '----- 2: Show NO.1 - NO.5 -----', CR, LF
             DB '----- 3: Quit             -----', CR, LF, '$'    ;菜单提示信息
  JMP_TAB    DW SHOW_TOP_3	  ;地址表（跳转表）
          	 DW SHOW_NO1_5
          	 DW QUIT

DATASG ENDS

;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODESG SEGMENT
  ASSUME CS: CODESG, DS: DATASG, SS: STACKSG

;-----------------------------------------------------;
;主程序
;-----------------------------------------------------;
MAIN PROC
  MOV AX, DATASG
  MOV DS, AX
  PRINTLNSTR MSG_INPUT1       ;输出请输入的提示信息
  PRINTLNSTR MSG_INPUT2
  CALL INPUT_STU              ;输入数据
  ;# TODO:
  MOV AX, STU_NUM
  CALL PRINT_STU
  JMP QUIT

REPEAT:
  PRINTLNSTR MSG_TAB          ;跳转表法来选择所要执行的操作
  PRINTLNSTR MSG_SELECT
READ_SELECT:
  MOV AH, 1                   ;等待输入选择号
  INT 21H
  HUANHANG
  CMP AL, 31H                 ;选择合法性检查
  JB BEEP			                ;若非法则转移
  CMP AL, 33H
  JA BEEP			                ;输入的数字必须在1和3之间

  AND AL, 0FH	   	            ;ASCII码转换为非压缩BCD码
  XOR AH, AH		              ;(AX)＝功能号
  DEC AX			                ;得到索引值
  ADD AX, AX		              ;i项位移量＝(AX)*2
  LEA BX, JMP_TAB		          ;装入表首址
  ADD BX, AX		              ;得到表项地址
  JMP [BX]			              ;按表项地址转移

BEEP:
	PRINTLNSTR MSG_S_ERR        ;输出错误信息
  JMP REPEAT            ;转重新选择

SHOW_TOP_3:                   ;显示排名前三的同学的成绩
  CALL  SORT_BY_SCORE
  MOV AX, 3
  ;PRINTCHAR '3'
  CALL PRINT_STU

  MOV AH, 0
  INT 16H			                ;等待键盘输入
  JMP REPEAT		              ;返回菜单

SHOW_NO1_5:                   ;显示学号前5的同学的成绩
  CALL  SORT_BY_ID
  MOV AX, 5
  ;PRINTCHAR '5'
  CALL PRINT_STU

  MOV AH, 0
  INT 16H			                ;等待键盘输入
  JMP REPEAT		              ;返回菜单
QUIT:
  RETURN
MAIN ENDP

;-----------------------------------------------------;
;输入学生数据子程序
;-----------------------------------------------------;
INPUT_STU PROC
  PUSH AX
  PUSH BX
  PUSH BP
  PUSH CX                     ;寄存器入栈

  MOV CX, 0                   ;循环10次
  MOV BP, 0                   ;BP用来索引每个学生的数据,初始化为0
INPUT:
  PRINTLNSTR MSG_INPUT3
  INPUT_INFO 0                ;输入学生姓名
  INPUT_INFO 10               ;输入学生学号
  INPUT_SCORE S_ZC            ;输入组成原理成绩
  INPUT_SCORE S_DS            ;输入数据结构成绩
  INPUT_SCORE S_HB            ;输入汇编语言成绩
  ;将输入的成绩累加并且存放到S_AL字段中
  MOV AX, WORD PTR TAB[BP].S_ZC
  ADD AX, WORD PTR TAB[BP].S_DS
  ADD AX, WORD PTR TAB[BP].S_HB
  MOV WORD PTR TAB[BP].S_AL, AX
  PRINTLNSTR MSG_INPUT4
  ADD BP, 30                  ;寻址下一个学生的地址
  ;累加寄存器输入的次数
  INC CX
  CMP CX, STU_NUM
  JL LOP
  JMP EXIT
LOP:
  JMP INPUT
EXIT:
  POP CX
  POP BP
  POP BX
  POP AX                      ;寄存器出栈
  RET
INPUT_STU ENDP

;-----------------------------------------------------;
;按照成绩从高到低排序子程序,冒泡排序
;-----------------------------------------------------;
SORT_BY_SCORE PROC
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH SI                     ;寄存器入栈

  MOV SI, STU_NUM             ;设置外层循环次数
  DEC SI
LOP_SCORE1:
  MOV CX, SI
  MOV BX, 0
LOP_SCORE2:
  MOV AX, WORD PTR TAB[BX].S_AL
  CMP AX, WORD PTR TAB[BX+30].S_AL
  JGE CNT_SCORE
  SWAP_STU                    ;如果小于则交换
CNT_SCORE:
  ADD BX, 30
  LOOP LOP_SCORE2
  DEC SI
  JNE LOP_SCORE1

  POP SI
  POP CX
  POP BX
  POP AX                     ;寄存器出栈
  RET
SORT_BY_SCORE ENDP

;-----------------------------------------------------;
;按照学号从低到高排序子程序,冒泡排序
;-----------------------------------------------------;
SORT_BY_ID PROC
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH SI
  PUSH DI                   ;寄存器入栈

  MOV DI, STU_NUM
  DEC DI
LOP_NO1:
  MOV CX, DI
  MOV BX, 0
LOP_NO2:
  MOV SI, -1
LOP_NO3:
  INC SI
  MOV AL, BYTE PTR TAB[BX].ID[SI]
  MOV AH, BYTE PTR TAB[BX+30].ID[SI]
  JE LOP_NO3
  JL CNT_ID
  SWAP_STU
CNT_ID:
  ADD BX, 30
  LOOP LOP_NO2
  DEC DI
  JNZ LOP_NO1

  POP DI
  POP SI
  POP CX
  POP BX
  POP AX                    ;寄存器出栈
  RET
SORT_BY_ID ENDP


;-----------------------------------------------------;
;打印学生的信息,AX中存放多少个学生
;-----------------------------------------------------;
PRINT_STU PROC
  PUSH AX
  PUSH BX
  PUSH BP
  PUSH CX                           ;寄存器入栈

  MOV BP, 0
  MOV BX, 0
LOP_PRINT_STU:
  ;PRINT_STU_ITEM
  OUTALL
  ADD BP, 30                        ;下一个学生的成绩
  INC BX
  CMP BX, AX
  JL LOP_PRINT_STU

  POP CX
  POP BP
  POP BX
  POP AX                ;寄存器出栈
  RET
PRINT_STU ENDP

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
