;-----------------------------------------------------;;输入宏定义;-----------------------------------------------------;HUANH MACRO  MOV AH, 2  MOV DL, 13  INT 21H  MOV DL, 10  INT 21HENDMDATA SEGMENT  MSG DB 'Please input a number: $'  RESULT DB 'The YiangHui triangle:$'  CON DB 'Do you want to continue?(Y/N): $'  ERROR DB 'Data out of range!$'  AHEAD DB ' $'  BETWEEN DB ' $'  BACK DB ' $'  a DW ?  b DW ?  cc DW ?  d DW ?DATA ENDSCODE SEGMENT  ASSUME CS:CODE,DS:DATA;-----------------------------------------------------;;输入子程序;-----------------------------------------------------;SHURU PROC  XOR BP,BP ;BP清零  MOV BX,10  MOV CX,3input:  MOV AH,1  INT 21H  CMP AL,0DH  JZ OK       ;如果回车则输入完毕  SUB AL,30H  ;转为二进制  CBW  XCHG AX,BP  MUL BX  ADD BP,AX  LOOP inputOK:  RETSHURU ENDPSTART: MOV AX,DATA  MOV DS,AX  MAIN: MOV DX,OFFSET MSG  INT 21H  CALL SHURU  CMP BP,15  JB MZTJ  HUANH  MOV  MOV  INT  HUANH JMP  MZTJ: HUANH  MOV  MOV  INT  HUANH  MOV  CALL  MOV  MOV  INT  CMP  JZ  MOV  MOV  MOV  DEC  CALL  exit: HUANH  MOV  CALL  MOV  MOV  INT  JMP  yhsj: MOV  HUANH  DEC  MOV  CALL  MOV  DX,OFFSET ERROR AH,9 21H MAIN DX,OFFSET RESULT AH,9 21H AX,BP Showspace DL,'1' AH,2 21H BP,1 exit b,2 CX,BP a,BP a yhsj AX,BP Showspace DL,'1' AH,2 21H NEAR PTR input1 cc,1 BP AX,BP Showspace DL,'1' 18  江苏理工学院—10计1.张逸凡  MOV AH,2  INT 21H  MOV DX,OFFSET BETWEEN MOV AH,9  INT 21H  MOV AX,1  PUSH b  CALL Calculate  POP b  INC b DEC CX  CMP CX,1  JA yhsj  input1: HUANH MOV DX,OFFSET CON MOV AH,9  INT 21H  MOV AH,1 INT 21H  CMP AL,59H JNZ exit1  HUANH  JMP NEAR PTR MAIN  exit1: MOV AH,4CH  INT 21H  Showspace:  MOV BX, AX MOV AH, 9  MOV DX,OFFSET AHEAD nexts:  CMP BX, 0 JZ dones  INT 21H  DEC BX  JMP nexts  dones:  RET  Calculate: DEC b  MUL b  DIV cc  INC cc  CMP b,0  JZ ok1  汇编语言课程设计报告—杨辉三角 19  PUSH  MOV  CALL  MOV  SUB  CALL  POP  CALL  ok1:  RET  ShowNum: MOV  CMP  JZ  INC  DIV  PUSH  AND  CALL  POP  MOV  OR DL, 30H MOV  INT  ok2:  RET  Showspace1:MOV  MOV  MOV  next: CMP  JZ  INT  DEC  JMP  done:  RETCODE ENDSEND STARTAX d,0 ShowNum AX,6 AX,d Showspace1 AX Calculate BX, 10 AX, 0 ok2 d BL AX AX, 00FFH SHOWNum DX DL, DH AH, 2 21H BX, AX AH, 9 DX,OFFSET BACK BX, 0 done 21H BX next 20