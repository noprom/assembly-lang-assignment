;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/5/2 1:44PM
;; Title: 实验二(4):界面小程序

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

DATASG ENDS

;-----------------------------------------------------;
;代码段
;-----------------------------------------------------;
CODESG SEGMENT
  ASSUME CS: CODESG, DS: DATASG, SS: STACKSG
MAIN PROC


  MOV AX, 4C00H
  INT 21H
MAIN ENDP

CODESG ENDS
END MAIN
