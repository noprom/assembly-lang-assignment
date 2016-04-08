;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/7 9:03PM
;; Title: 实验一(2):循环程序设计
;------------------------定义符号----------------------;
CR EQU 0DH                            ;回车符的ASCII值
LF EQU 0AH                            ;换行符的ASCII值
;-------------------------堆栈段-----------------------;
stacksg segment stack 'S'
  dw 64 dup('ST')
stacksg ends
;-------------------------数据段-----------------------;
datasg segment
  arrA db 1, 9, 2, 3, 7, 8, 4, 5, 10, 6, 20, 19, 18, 13, 14, 15, 32, 96, 193, 132     ;数组A
  ;db '$'
  ctA equ ($-arrA)                              ;数组A长度
  indexA db 0                                   ;输出数组A的下标

  arrB db 3, 7, 9, 8, 1, 55, 33, 22, 10, 19, 21, 35, 60, 31, 14, 15, 23, 69, 93, 172 ;数组B
  ;db '$'
  ctB equ ($-arrB)                              ;数组B长度
  indexB db 0                                   ;输出数组B的下标

datasg ends
;-------------------------代码段-----------------------;
codesg segment
  assume cs: codesg, ss: stacksg, ds: datasg    ;指定寄存器的关系
;-------------------------主过程-----------------------;
main proc far

main endp
codesg ends
end main
