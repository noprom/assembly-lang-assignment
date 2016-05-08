;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/5/2 1:44PM
;; Title: 实验二(4):*在界面以0.1s的间隔随机移动,每隔0.5s界面背景颜色改变

;------------------------定义符号----------------------;
CR EQU 0DH                            ;回车符的ASCII值
LF EQU 0AH                            ;换行符的ASCII值

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
;改变背景颜色,时间间隔为0.5秒
;-----------------------------------------------------;
CHG_COLOR MACRO
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX

  ADD COLOR, 10H								;每次时间间隔颜色改变
  AND COLOR, 01111111B					;变色
  MOV BH, COLOR
  MOV AH, 6
  MOV AL, 0
  MOV CH, 0
  MOV CL, 0
  MOV DH, 80
  MOV DL, 80
  INT 10H

  POP DX
  POP CX
  POP BX
  POP AX
ENDM

;-----------------------------------------------------;
;改变*位置,时间间隔为0.1秒
;-----------------------------------------------------;
CHG_POS MACRO
	MOV AH, 2									;设置光标
	MOV BH, 0
	MOV DH, BYTE PTR Y									;Y行
	MOV DL, BYTE PTR X									;X列
	INT 10H
	PRINTCHAR MSG_START
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
  MSG_START DB '*'            ;显示的*号
  COLOR DB 0FH                ;背景颜色
  CNT_COLOR DB 10             ;颜色改变计数器
	CNT_NUM   DB 10							;数字移动计数器
	X					DW 3							;初始化光标所在列
	Y 				DW 12							;初始化光标所在行
DATASG ENDS

;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODESG SEGMENT
  ASSUME CS: CODESG, DS: DATASG, SS: STACKSG
MAIN PROC FAR
  MOV AX, DATASG
  MOV DS, AX

  MOV AH, 35H
  MOV AL, 1CH
  INT 21H                     ;(1)取原1CH中断向量

  PUSH ES
  PUSH BX                     ;(2)保存原1CH中断向量

  PUSH DS
  MOV DX, SEG INT_1CH
  MOV DS, DX
  LEA DX, INT_1CH
  MOV AH, 25H
  MOV AL, 1CH
  INT 21H                     ;(3)设置新1CH中断向量
  POP DS

  IN AL, 21H
  AND AL, 11111100B	          ;(4)增设键盘和定时器中断
  OUT 21H, AL

  STI                         ;(5)开中断
;------------------主程序其他功能----------------------;

  ;OTHER  FUNCTION
	MOV	AH, 6		   ;以蓝底白字清屏
	MOV	AL, 0
	MOV	BH, 1FH
	MOV	CX, 0
	MOV	DX, 184FH
	INT	10H

	MOV	AL, 0
PRINT0:
	PUSH AX			 	;保存显示的字符
	MOV AH, 1		 	;等待输入
	INT 21H
	OR AL, 20H		;大写字母转换为小写
	CMP AL, 'q'		;退出？
	POP AX				;恢复显示的字符
	JE EXIT_MAIN	;若退出则转

;------------------恢复原中断向量----------------------;
EXIT_MAIN:
  POP DX                      ;(6)恢复1CH中断向量
  POP DS
  MOV AH, 25H
  MOV AL, 1CH
  INT 21H

  MOV	AH, 6		  							;以黑底白字清屏
  MOV	AL, 0
  MOV	BH, 07H
  MOV	CX, 0
  MOV	DX, 184FH
  INT	10H

	MOV AH, 2								  	;恢复光标位置
	MOV BH, 0
	MOV DH, 0										;0行
	MOV DL, 0										;0列
	INT 10H

  MOV AX, 4C00H               ;返回操作系统
  INT 21H
MAIN ENDP

;-----------------------------------------------------;
;中断处理子程序
;-----------------------------------------------------;
INT_1CH PROC FAR              ;新1CH中断处理子程序
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DS                     ;(1)保存寄存器
  STI                         ;(2)开中断
;------------------(3)处理中断----------------------;
  MOV	AX, DATASG
  MOV	DS, AX

M1:
	DEC CNT_NUM
	CMP CNT_NUM, 0
	JE CH_POS

M2:
  DEC CNT_COLOR
  CMP CNT_COLOR, 0
  JE CH_BG
  JMP EXIT

CH_POS:
	CALL CHG_XY
	CHG_POS
	MOV CNT_NUM, 1
	JMP M2
CH_BG:
  CHG_COLOR
  MOV CNT_COLOR, 10

EXIT:
  CLI                         ;(4)关中断
	POP DS
	POP	DX
	POP	CX
	POP	BX
  POP	AX		                  ;(5)恢复寄存器
  IRET                        ;(6)中断返回
INT_1CH ENDP

;-----------------------------------------------------;
;改变显示*的x, y
;-----------------------------------------------------;
CHG_XY PROC
	PUSH AX

	MOV AX, X									;每次X加上Y的值
	ADD AX, Y
	MOV X, AX

	MOV AX, Y									;每次Y加上X的值
	ADD AX, X
	MOV Y, AX

	POP AX
	RET
CHG_XY ENDP
CODESG ENDS
END MAIN
