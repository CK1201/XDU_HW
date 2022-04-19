DATAS SEGMENT
	VAR1 DB 30H
	VAR2 DB 30H
    ;此处输入数据段代码  
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    MOV ES,AX
    MOV AL,VAR1
    MOV BL,VAR2
    TEST AL,1
    JZ L1
    JMP OVER
    
 L1:
 	TEST BL,1
 	JZ L2
 	MOV VAR1,BL
 	MOV VAR2,AL
 	JMP OVER
 L2:
 	SHR AL,1
 	MOV VAR1,AL
 	SHR BL,1
 	MOV VAR2,BL
 OVER:
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START


