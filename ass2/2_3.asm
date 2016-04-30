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
  MSG_INPUT1 DB 'Please input 10 students'' info, every line please input only one value$'
  MSG_INPUT2 DB 'Order: name, number, component score, data structure score, assemlby score$'
  MSG_INPUT3 DB 'Please input a student'' name, id and score, every line has only one field:$'
  MSG_INPUT4 DB 'The student'' info has been recorded.$'
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
  ;输出请输入的提示信息
  PRINTLNSTR MSG_INPUT1
  PRINTLNSTR MSG_INPUT2

  ;输入数据
  CALL INPUT_STU

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

  MOV CX, 0                  ;循环10次
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
  CMP CX, 10
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


CODESG ENDS
END MAIN
