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
  db '$'
  sizeA equ ($-arrA-1)                              ;数组A元素个数
  db	0
  indexA db 0                                   ;输出数组A时的下标
  db	0

  arrB db 3, 7, 9, 8, 1, 55, 33, 22, 10, 19, 21, 35, 60, 31, 14, 15, 23, 69, 93, 172 ;数组B
  db '$'
  sizeB equ ($-arrB-1)                              ;数组B元素个数
  db	0
  indexB db 0                                   ;输出数组B时的下标
  db	0

  arrC db 40 dup(?)                             ;数组C
  db '$'
  sizeC db 0                                      ;数组C元素个数,初始状态为0
  db	0
  indexC db 0                                   ;输出数组C时的下标
  db	0

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
printArrAContet:
    call printArrA
;----------------------输出B原来的值--------------------;

    ;返回程序
    mov ax, 4c00h
    int 21h
main endp

;-----------------------打印字符串,---------------------;
printS proc
  mov ah, 2
  mov dl, ','
  int 21h
  ret
printS endp
;-----------------------打印字符串,---------------------;

;---------------------打印数组A的内容-------------------;
printArrA proc
printA:
  cmp indexA, sizeA
  jge exitA                                     ;如果索引大于等于数组长度则退出
  mov di, indexA
  mov bx, word ptr arrA[di]
  and bx, 00ffh                                 ;and 00ffh
  call bin2dec                                  ;二进制转为十进制输出
  call printS                                   ;输出,
  inc indexA                                    ;累加索引
  jmp printA

exitA:
    ret
printArrA endp

;----------------------二进制转十进制--------------------;
bin2dec proc
  mov flag, 0                         ;标志位清零

  mov cx, 10000
  call dec_div

  mov cx, 1000
  call dec_div

  mov cx, 100
  call dec_div

  mov cx, 10
  call dec_div

  mov cx, 1
  call dec_div

  cmp flag, 0                       ;若flag为0则证明要输出的二进制数为0
  jg 	exit
  mov ah, 2 		                    ;若要输出的二进制数为0,则这个数不会被dec_div输出
  MOV DL, '0' 		                  ;因此在这里输出0
  INT 21h
exit:
  ret
bin2dec endp
;----------------------二进制转十进制--------------------;
;------------------------dec_div-----------------------;
dec_div proc
  mov ax, bx
  mov dx, 0

  div cx
  mov bx, dx

  mov dl, al
  add dl, 30h

  cmp flag, 0
  jg flag1 		                     ;flag为1,说明之前有非0位,直接输出
  cmp dl, '0' 		                 ;flag非0,说明之前全部为0位,将当前位于0比较
  je exit1   		                   ;当前位为0,不输出
  mov flag, 1 		                 ;当前位不为0,将flag置1

flag1:                             ;输出当前位
  mov ah, 2
  int 21h
exit1:
  ;跳转至此则不输出当前位
  ret
dec_div endp
;------------------------dec_div-----------------------;
codesg ends
end main
