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
  sizeA equ ($-arrA)                              ;数组A元素个数
  indexA db 0                                   ;输出数组A时的下标

  arrB db 3, 7, 9, 8, 1, 55, 33, 22, 10, 19, 21, 35, 60, 31, 14, 15, 23, 69, 93, 172 ;数组B
  ;db '$'
  sizeB equ ($-arrB)                              ;数组B元素个数
  indexB db 0                                   ;输出数组B时的下标

  arrC db 40 dup(?)                             ;数组C
  ctC db 0                                      ;数组C元素个数,初始状态为0
  indexC db 0                                   ;输出数组C时的下标

  flag db 0                                     ;输出0判断flag

  ;下面是输出的字符串常量
  arrABeforeSortMsg  db 'Before sort, array A: ', '$'  ;输出'Before sort, array A: '
  arrBBeforeSortMsg  db 'Before sort, array B: ', '$'  ;输出'Before sort, array B: '
  arrAAfterSortMsg   db 'After sort, array A: ', '$'   ;输出'After sort, array A: '
  arrBAfterSortMsg   db 'After sort, array B: ', '$'   ;输出'After sort, array B: '
  arrCContentMsg     db 'The content of array C:','$'  ;输出'The content of array C: '

datasg ends
;-------------------------代码段-----------------------;
codesg segment
  assume cs: codesg, ss: stacksg, ds: datasg    ;指定寄存器的关系
;-------------------------主过程-----------------------;
main proc far
  mov ax, datasg
  mov ds, ax
;----------------------输出A原来的值--------------------;
arrABeforeSortMsgInfo:                           ;arrABeforeSortMsgInfo输出'Before sort, array A: '
    mov ah, 9
    lea dx, arrABeforeSortMsg
    int 21h

;----------------------输出B原来的值--------------------;

    ;返回程序
    mov ax, 4c00h
    int 21h
main endp

;---------------------打印数组A的内容-------------------;
printArrA proc
printA:
  cmp indexA, sizeA
  jge exitA                                     ;如果索引大于等于数组长度则退出

exitA:
    ret
printArrA endp
codesg ends
end main
