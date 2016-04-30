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

  POP CX
  POP BP
  POP BX
  POP AX                      ;寄存器出栈
INPUT_STU ENDP
CODESG ENDS
END MAIN
