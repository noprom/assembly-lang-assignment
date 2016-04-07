;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/7 8:43AM
;; Title: 实验一(1):分支程序设计

;-------------------------堆栈段-----------------------;
stacksg segment stack 'S'
  dw 64 dup('ST')
stacksg ends
;-------------------------数据段-----------------------;
datasg segment
  numA dw 0                           ;保存输入的数字A
  numB dw 0                           ;保存输入的数字B
  flag db 0                           ;判断标志位
  msgA db 'Please input A: '          ;定义提示输入A的消息
  msgB db 'Please input B: '          ;定义提示输入B的消息
datasg ends
;-------------------------代码段-----------------------;
codesg segment
  assume cs: codesg, ss: stacksg, ds: datasg    ;指定寄存器的关系
  ;-------------------------主过程-----------------------;
  main proc far

  main endp
codesg ends
end main
