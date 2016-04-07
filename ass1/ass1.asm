;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/1 2:24PM
;; Title: 实验一:分支程序设计

;-------------------------栈段-------------------------;
stacksg segment stack 'S'
  dw 64 dup('ST')
stacksg ends
;-------------------------数据段-----------------------;
datasg segment
  numA dw 0
  numB dw 0
  flag dw 0
  msgA dw 'Please input A: ', '$' ;定义提示输入A的消息
  msgB dw 'Please input B: ', '$' ;定义提示输入B的消息
datasg ends
