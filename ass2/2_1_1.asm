HUANH MACRO 
 
 ; 宏定义5句代码实现换行 
 
MOV   AH, 2     
   MOV   DL, 13   
INT  
 
21H    MOV   DL, 10    INT   
21H 
ENDM 
DATA SEGMENT   MSG   DB  'Please input a number: $'   RESULT DB  'The YiangHui triangle:$' 
 
 
CON   
DB  
'Do you want to continue?(Y/N): $' ERROR    DB  
'Data out of range!$' 
  AHEAD    DB   '   $'   BETWEEN DB  '     $'   BACK  DB  ' $'   a 
 
 DW  ?  ;a为阶数   b   DW  ?  
;b是行数 
  c 
 
 DW  ?  
 
d  
 
DW  
? 
 
;记录位数，控制空格数 DATA ENDS CODE SEGMENT   
 
ASSUME  CS:CODE,DS:DATA  
SHURU PROC   
 
 
 
;输入子程序，数字存在BP 
   XOR   BP,BP    MOV   BX,10  
 
 
MOV   
CX,3 
 
;控制输入位数，外加一位回车
