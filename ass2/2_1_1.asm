data segment
  org 0000h
  buff db 256 dup(0)
  buff1 db 0dh,0ah
  asc db 256 dup(0)
  asc1 db 256 dup(0)
data ends

stack segment
  db 128 dup(0)
stack ends

code segment
  assume cs:code,ds:data,ss:stack
  start:
  mov ax,data
  mov ds,ax
  mov es,ax
  lea si,buff
  lea di,asc
  mov ax,0
  l1:
  mov cx,0
  mov dh,10
  mov bh,1
  mov bl,0
  sub dh,bh
  mov cl,dh
  mov al,' '
  stosb
  loop l1
  r3:
  movsb
  inc bl
  cmp bl,bh
  jb r3
  mov al,0dh
  mov [di],al
  inc di
  mov al,0ah
  mov [di],al
  inc di
  jmp l1
  mov al,'$'
  mov [di],al
  l2:
  lea di,asc1
  lea si,buff
  dec si
  mov bl,0
  mov dh,10
  mov bh,10
  sub dh,bh
  mov cl,dh
  mov al,' '
  stosb
  loop l1
  r4:
  mov al,[si]
  dec si
  dec bl
  cmp bl,bh
  jb r4
  dec bh
  mov al,0dh
  stosb
  mov al,0ah
  stosb
  jmp l2
  lea dx,buff1
  mov ah,9
  int 21h
  lea dx,asc1
  mov ah,9
  int 21h
  mov ax,4c00h
  int 21h
code ends
end start
zh proc
  mov cx,10
  mov bh,1
  mov bl,0
  r1:
  mov al,1
  stosb
  inc bl
  mov dh,bh
  sub dh,bl
  jz ed
  r0:
  dec dh
  jnz s1
  mov al,1
  stosb
  s1:
  mov al,[di-2]
  mov dl,[di-3]
  add al,dl
  stosb
  jmp r0
  ed:
  inc bh
  mov bl,0
  loop r1
  ret
zh endp
