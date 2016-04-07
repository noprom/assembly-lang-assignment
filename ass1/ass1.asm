;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/7 8:43AM
;; Title: 实验一(1):分支程序设计
;------------------------定义符号----------------------;
CR EQU 0DH                            ;回车符的ASCII值
LF EQU 0AH                            ;换行符的ASCII值
;-------------------------堆栈段-----------------------;
stacksg segment stack 'S'
  dw 64 dup('ST')
stacksg ends
;-------------------------数据段-----------------------;
datasg segment
  numA dw 0                           ;保存输入的数字A
  numB dw 0                           ;保存输入的数字B
  flag db 0                           ;判断标志位
  msgA db 'Please input A: ', '$'     ;定义提示输入A的消息
  msgB db 'Please input B: ', '$'     ;定义提示输入B的消息
datasg ends
;-------------------------代码段-----------------------;
codesg segment
  assume cs: codesg, ss: stacksg, ds: datasg    ;指定寄存器的关系
  ;-------------------------主过程-----------------------;
  main proc far
    mov ax, datasg
    mov ds, ax
                                      ;将ds指向数据段
inputAInfo:
    mov ah, 9
    lea dx, msgA
    int 21h
                                      ;inputAInfo输出'Please input A: '
inputA:
    mov ah, 1
    int 21h
                                      ;输入单个字符,al存放ASCII码
    sub al, 30h                       ;ASCII码转化为数字
    mov bx, 0
    jl saveA
    cmp al, 9                         ;与9比较,判断是否为数字
    jg saveA
    cbw                               ;对al进行位扩展

    xchg ax, bx
    mov cx, 10
    mul cx
    xchg ax, bx                       ;将bx中原来的数据乘10
    add bx, ax                        ;乘完之后加上ax
    jmp inputA                        ;继续输入下一个字符

saveA:
    mov numA, bx
    mov bx, 0

inputBInfo:
    mov ah, 9
    lea dx, msgB
    int 21h                           ;inputBInfo输出'Please input B: '

    mov ax, 4c00h
    int 21h                           ;返回程序
  main endp
codesg ends
end main
