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
  outA db 'A=', '$'                   ;定义输出A的消息
  outB db 'B=', '$'                   ;定义输出B的消息
datasg ends
;-------------------------代码段-----------------------;
codesg segment
  assume cs: codesg, ss: stacksg, ds: datasg    ;指定寄存器的关系
  ;-------------------------主过程-----------------------;
  main proc far
    mov ax, datasg
    mov ds, ax
                                      ;将ds指向数据段
inputAInfo:                           ;inputAInfo输出'Please input A: '
    mov ah, 9
    lea dx, msgA
    int 21h

inputA:                               ;循环输入numA
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
    mul cx                            ;ax*10->ax
    xchg ax, bx                       ;将bx中原来的数据乘10,之后交换
    add bx, ax                        ;交换之后加上ax
    jmp inputA                        ;继续输入下一个字符

saveA:                                ;保存numA
    mov numA, bx

inputBInfo:                           ;inputBInfo输出'Please input B: '
    mov ah, 9
    lea dx, msgB
    int 21h

inputB:                               ;输入numB
    mov ah, 1
    int 21h
                                      ;输入单个字符,al存放ASCII码
    sub al, 30h                       ;ASCII码转化为数字
    mov bx, 0
    jl saveB
    cmp al, 9                         ;与9比较,判断是否为数字
    jg saveB
    cbw

    xchg ax, bx
    mov cx, 10
    mul cx                            ;ax*10->ax
    xchg ax, bx                       ;将bx中原来的数据乘10,之后交换
    add bx, ax                        ;交换之后加上ax
    jmp inputB                        ;继续输入下一个字符

saveB:                                ;保存numB
    mov numB, bx

judgeA:                               ;判断numA的奇偶
    mov ax, numA
    and ax, 0001h
    cmp ax, 0                         ;与0比较,如果大于零则numA为奇数
    jg AIsOddJudgeB                   ;numA为奇数,跳转到AIsOddJudgeB判断B的奇偶

AisEvenJudgeB:                        ;此时numA为偶数,需要判断numB的奇偶
    mov ax, numB
    and ax, 0001h
    cmp ax, 0                         ;与0比较,如果大于零则numB为奇数
    jg exchangeAB                     ;numB为奇数,跳转到exchangeAB,将numA和numB交换
    jmp printAB                       ;跳转到printAB,打印AB的值

AIsOddJudgeB:                         ;此时numA为奇数,需要判断numB的奇偶
    mov ax, numB
    and ax, 0001h
    cmp ax, 0                         ;与0比较,如果大于零则numB为奇数
    jg incAB                          ;numB为奇数,跳转到incAB,将numA和numB均加1
    jmp printAB                       ;跳转到printAB,打印AB的值

exchangeAB:                           ;交换numA与numB的值
    mov ax, numA
    mov bx, numB
    mov numA, bx
    mov numB, ax
    jmp printAB

incAB:                                ;numA与numB均为奇数,分别加1
    inc word ptr numA
    inc word ptr numB

printAB:                              ;输出numA与numB
    mov ah, 9
    lea dx, outA
    int 21h                           ;输出'A='

    mov ax, 4c00h
    int 21h                           ;返回程序
  main endp
codesg ends
end main
