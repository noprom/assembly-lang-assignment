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
;删除数字, 入口参数:字符串, 字符串长度
;-----------------------------------------------------;
DELETE_NUM MACRO STR, STR_SIZE
  LOCAL s, ge0, le9, next
	PUSH CX
	PUSH BX
	PUSH AX																		;寄存器入栈

  MOV CX, STR_SIZE
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
  MOV BYTE PTR STR[SI], 20H								;将数字替换成空格
next:
  INC SI
  LOOP s

	POP AX																  ;寄存器出栈
	POP BX
	POP CX
ENDM

;-----------------------------------------------------;
;对字符串进行从小到大的冒泡排序
;-----------------------------------------------------;
SORT_STR MACRO STR, STR_SIZE
	LOCAL loopA1, loopA2
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX														;寄存器入栈

	MOV DI, STR_SIZE - 1							;外层循环次数
loopA1:
	MOV CX, DI												;内层循环次数
	MOV BX, 0
loopA2:
	MOV AL, STR[BX]
	CMP AL, STR[BX + 1]
	JLE CONT													;小于等于则不做变化

	XCHG AL, STR[BX + 1]							;否则对两数进行交换
	XCHG STR[BX], AL
CONT:
	INC BX
	LOOP loopA2
	DEC DI
	JNZ loopA1												;不为0则继续外层循环

	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX														;寄存器出栈
ENDM

;-----------------------------------------------------;
;输出排序之后的字符串
;-----------------------------------------------------;
PRINT_STR MACRO STR
  LOCAL s, next

	PUSH CX
	PUSH BX
	PUSH AX																		;寄存器入栈

  MOV CX, strSize
	MOV SI, 0
s:
  MOV BL, BYTE PTR STR[SI]
  CMP BL, 20H
  JE next
  PRINTCHAR BL
next:
	INC SI
  LOOP s

	POP AX																  ;寄存器出栈
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
  strSize EQU $-CSTRN-1  ;字符串的大小
  strIndex DB 0          ;遍历字符串的索引
  beforeModifiedMsg DB 'Before modified, CSTRN:$'
  afterModifiedMsg DB 'After modified,  CSTRN:$'
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
  DELETE_NUM CSTRN, strSize       ;首先将数字删除
	SORT_STR CSTRN, strSize 				;对删除数字之后的字符串进行排序
	PRINT_STR CSTRN								  ;输出删除数字之后的字符串
  RETURN                          ;返回程序
MAIN ENDP
CODESG ENDS
END MAIN
