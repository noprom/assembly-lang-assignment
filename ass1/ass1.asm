;; Author: noprom <tyee.noprom@qq.com>
;; Data: 2016/4/1 2:24PM
;; Title: 实验一:分支程序设计

;-------------------------栈段-------------------------;
STACKSG SEGMENT STACK 'S'
  DW 64 DUP('ST')
STACKSG ENDS
;-------------------------数据段-----------------------;
datasg segment
  A dw 0
  B dw 0
  FLAG dw 0
  MSGA dw 'Please input A: ', '$'

datasg ends
