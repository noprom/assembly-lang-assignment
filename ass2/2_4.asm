;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/5/2 1:44PM
;; Title: 实验二(4):*在界面以0.1s的间隔随机移动,每隔0.5s界面背景颜色改变

;-----------------------------------------------------;
;堆栈段
;-----------------------------------------------------;
STACKSG SEGMENT STACK 'S'
  DW 256 DUP 'ST'
STACKSG ENDS

;-----------------------------------------------------;
;数据段
;-----------------------------------------------------;
DATASG SEGMENT
  COUNT DW 1                  ;COUNT为0.5秒的时间计数值
  START DB '*'                ;显示的*号
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
  AND AL, 11111100B	          ;增设键盘和定时器中断
  OUT 21H, AL

  MOV AX, 4C00H
  INT 21H
MAIN ENDP

CODESG ENDS
END MAIN
