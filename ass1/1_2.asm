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
  arrA db 1, 9, 2, 3, 7, 8, 4, 5, 10, 6, 20, 19, 18, 13, 14, 15, 32, 96, 100, 32     ;数组A
  db '$'
  sizeA equ ($-arrA-1)                              ;数组A元素个数
  db	0
  indexA db 0                                       ;输出数组A时的下标
  db	0

  arrB db 3, 7, 9, 8, 1, 55, 33, 22, 10, 19, 21, 35, 60, 31, 14, 15, 23, 69, 93, 0 ;数组B
  db '$'
  sizeB equ ($-arrB-1)                              ;数组B元素个数
  db	0
  indexB db 0                                       ;输出数组B时的下标
  db	0

  arrC db 40 dup(?)                                 ;数组C
  db '$'
  sizeC db 0                                        ;数组C元素个数,初始状态为0
  db	0
  indexC db 0                                       ;输出数组C时的下标
  db	0

  flag db 0                                         ;输出0判断flag

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
    call printCRLF
;----------------------输出B原来的值--------------------;
arrBBeforeSortMsgInfo:                          ;arrBBeforeSortMsgInfo输出'Before sort, array B: '
    mov ah, 9
    lea dx, arrBBeforeSortMsg
    int 21h
printBContent:
    call printArrB
    call printCRLF

;---------------------输出排序之后的值-------------------;
arrAAfterSortMsgInfo:                           ;arrAAfterSortMsgInfo输出'After sort, array A: '
    mov ah, 9
    lea dx, arrAAfterSortMsg
    int 21h

;-----------------对数组A进行冒泡排序,并输出---------------;
sortArrA:
    mov di, sizeA - 1                           ;外层循环次数
loopA1:
    mov cx, di                                  ;内层循环次数
    mov bx, 0
loopA2:
    mov al, arrA[bx]
    cmp al, arrA[bx+1]
    jle contA                                   ;小于等于则不做变化

    xchg al, arrA[bx+1]                         ;否则对两数进行交换
    xchg arrA[bx], al
contA:
    add bx, 1
    loop loopA2
    dec di
    jnz loopA1                                  ;不为0则继续外层循环

    mov indexA, 0
    call printArrA
    call printCRLF
;-----------------对数组A进行冒泡排序,并输出---------------;

;---------------------输出排序之后的值-------------------;
arrBAfterSortMsgInfo:                           ;arrBAfterSortMsgInfo输出'After sort, array B: '
    mov ah, 9
    lea dx, arrBAfterSortMsg
    int 21h

;-----------------对数组B进行冒泡排序,并输出---------------;
sortArrB:
    mov di, sizeB - 1                           ;外层循环次数
loopB1:
    mov cx, di                                  ;内层循环次数
    mov bx, 0
loopB2:
    mov al, arrB[bx]
    cmp al, arrB[bx+1]
    jle contB                                   ;小于等于则不做变化

    xchg al, arrB[bx+1]                         ;否则对两数进行交换
    xchg arrB[bx], al
contB:
    add bx, 1
    loop loopB2
    dec di
    jnz loopB1                                  ;不为0则继续外层循环

    mov indexB, 0
    call printArrB
    call printCRLF
;-----------------对数组A进行冒泡排序,并输出---------------;
;-----------------依次遍历数组A和B,找出相同的--------------;
    mov indexA, sizeA - 1                       ;初始化循环遍历数组A的下标
    mov indexB, sizeB - 1                       ;初始化循环遍历数组B的下标
    mov sizeC, 0                                ;初始化数组C的大小

process:
    mov bl, indexA
    cmp bl, 0
    jl done
                                                ;判断数组A是否遍历结束,如果结束则跳转至done
    mov bl, indexB
    cmp bl, 0
    jl done
                                                ;判断数组A是否遍历结束,如果结束则跳转至done
    mov bx, word ptr indexA
    mov ax, word ptr arrA[bx]
    and ax, 00ffh
                                                ;将数组A当前元素存放在ax中
    mov bx, word ptr indexB
    mov bx, word ptr arrB[bx]
    and bx, 00ffh
                                                ;将数组B当前元素存放在bx中
    cmp ax, bx                                  ;比较数组A和数组B当前遍历的元素的值
    je equal                                    ;数组A和数组B当前元素相等
    jl lower                                    ;数组A当前元素<数组B当前元素
    jg greater                                  ;数组A当前元素>数组B当前元素

equal:                                          ;数组A和数组B当前元素相等
    mov bx, word ptr sizeC
    and bx, 00ffh
    mov arrC[bx], al
                                                ;将相等的元素存入数组C
    dec indexA                                  ;将遍历数组A的索引减1
    dec indexB                                  ;将遍历数组B的索引减1
    inc sizeC                                   ;增加数组C的大小
    jmp process                                 ;继续跳转处理

lower:                                          ;数组A当前元素<数组B当前元素
    dec indexB                                  ;此时需要将遍历数组B的索引减少1
    jmp process                                 ;继续跳转处理

greater:                                        ;数组A当前元素>数组B当前元素
    dec indexA                                  ;此时需要将遍历数组A的索引减少1
    jmp process                                 ;继续跳转处理

done:                                           ;循环遍历结束
arrCContentMsgInfo:                             ;arrCContentMsgInfo输出'The content of array C: '
    mov ah, 9
    lea dx, arrCContentMsg
    int 21h

    mov indexC, 0
    call printArrC                              ;打印数组C的内容

;-----------------依次遍历数组A和B,找出相同的--------------;

    ;返回程序
    mov ax, 4c00h
    int 21h
main endp

;------------------------打印字符,----------------------;
printS proc
  mov ah, 2
  mov dl, ','
  int 21h
  ret
printS endp
;------------------------打印字符,----------------------;
;----------------------输出回车符号----------------------;
printCRLF proc
  mov ah, 2
  mov dl, CR
  int 21h
  mov dl, LF
  int 21h
  ret
printCRLF endp
;----------------------输出回车符号----------------------;

;---------------------打印数组A的内容-------------------;
printArrA proc
printA:
  mov bx, word ptr indexA
  cmp bx, word ptr sizeA
  jge exitA                                     ;如果索引大于等于数组长度则退出
  mov di, word ptr indexA
  mov bx, word ptr arrA[di]
  and bx, 00ffh                                 ;and 00ffh
  call bin2dec                                  ;二进制转为十进制输出
  call printS                                   ;输出,
  inc indexA                                    ;累加索引
  jmp printA
exitA:
    ret
printArrA endp

;---------------------打印数组B的内容-------------------;
printArrB proc
printB:
  mov bx, word ptr indexB
  cmp bx, word ptr sizeB
  jge exitB                                     ;如果索引大于等于数组长度则退出
  mov di, word ptr indexB
  mov bx, word ptr arrB[di]
  and bx, 00ffh                                 ;and 00ffh
  call bin2dec                                  ;二进制转为十进制输出
  call printS                                   ;输出,
  inc indexB                                    ;累加索引
  jmp printB
exitB:
    ret
printArrB endp

;---------------------打印数组C的内容-------------------;
printArrC proc
printC:
  mov bx, word ptr indexC
  cmp bx, word ptr sizeC
  jge exitC                                     ;如果索引大于等于数组长度则退出
  mov di, word ptr indexC
  mov bx, word ptr arrC[di]
  and bx, 00ffh                                 ;and 00ffh
  call bin2dec                                  ;二进制转为十进制输出
  call printS                                   ;输出,
  inc indexC                                    ;累加索引
  jmp printC
exitC:
    ret
printArrC endp

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
