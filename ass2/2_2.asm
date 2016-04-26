;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/20 2:26PM
;; Title: 实验二(2):
;; 对CSTRN地址起的30个字节长的字符串，删除其中的数字符，后续字符向前递补。
;; 用带有交换标志的冒泡排序将字符串中的剩余字符按照升序排。输出修改之前和修改之后的CSTRN字符串。
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
;删除数字
;-----------------------------------------------------;
DELETE_NUM MACRO STR
  LOCAL s, ge0, le9, next
	PUSH CX
	PUSH BX
	PUSH AX																		;寄存器入栈

  MOV CX, strSize
	DEC CX
	MOV SI, 0
s:
  MOV BL, BYTE PTR STR[SI]
  ;判断是否是数字，然后删除
  CMP BL, 30H
  JGE ge0
  JMP next
ge0:
  CMP BL, 39H
  JLE le9
  JMP next
le9:
  MOV BYTE PTR STR[SI], 20H										;将数字替换成空格
next:
  INC SI
  LOOP s

	POP AX																   ;寄存器出栈
	POP BX
	POP CX
ENDM
;-----------------------------------------------------;
;堆栈段
;-----------------------------------------------------;
STACKSG SEGMENT STACK 'S'
  DW 64 DUP('ST')
STACKSG ENDS

;-----------------------------------------------------;
;数据段
;-----------------------------------------------------;
DATASG SEGMENT
  CSTRN DB '1q2w3e4r5tzxcvbnmkjh09876gtyhk$'
  strSize EQU $-CSTRN    ;字符串的大小
  strIndex DB 0          ;遍历字符串的索引
  beforeModifiedMsg DB 'Before modified, CSTRN:$'
  afterModifiedMsg DB 'After modified,  CSTRN:$'
	lt1 DB '<1$'
	gt9 DB '>9$'
	numberOK DB '[0, 9]$'
	COMMA DB ','
DATASG ENDS

;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODESG SEGMENT
  ASSUME CS: CODESG, SS: STACKSG, DS: DATASG
MAIN PROC
  MOV AX, DATASG
  MOV DS, AX

  PRINTSTR beforeModifiedMsg      ;输出修改之前的字符串提示符
  PRINTLNSTR CSTRN                ;输出修改之前的字符串
  PRINTSTR afterModifiedMsg       ;输出修改之后的字符串提示符
  DELETE_NUM CSTRN                ;首先将数字删除
	PRINTSTR CSTRN								  ;输出删除数字之后的字符串
  RETURN                          ;返回程序
MAIN ENDP
CODESG ENDS
END MAIN
