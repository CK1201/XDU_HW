DATAS SEGMENT
	TIPInputString DB 'Please input string:','$'
	TIPOriginalString DB 'Original string:','$'
	TIPMax DB 'The maximum is ','$'
	StringInput DB 100
				DB ?
				DB 100 DUP(?)
    ;此处输入数据段代码  
DATAS ENDS

STACKS SEGMENT
		DB 100 DUP(?)
	TOP LABEL WORD
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;输入字符串
    CALL InputString
    ;把输入字符串个数转化为字类型给CX来循环处理，并在结尾加上'$'
    LEA BX,StringInput+2
    MOV AL,StringInput+1
    CBW
    MOV CX,AX
    ADD BX,AX
    MOV BYTE PTR [BX],'$'
    ;显示原字符串
    LEA DX,TIP2_2
    MOV AH,9
    INT 21H
    LEA DX,StringInput+2
    MOV AH,9
    INT 21H
    MOV DL,10
    MOV AH,02H
    INT 21H
    ;输出最大值提示符
    LEA DX,TIP2_3
    MOV AH,9
    INT 21H
    ;找出最大值
    LEA BX,StringInput+2
    MOV DL,0
    FindMax:
    	CMP [BX],DL
    	JB NotBigger
    	MOV DL,[BX]
    	NotBigger:
    		INC BX
    LOOP FindMax
    ;输出最大
    MOV AH,02H
    INT 21H
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;函数定义区;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;输入显示
    InputString PROC FAR
    	INPUT1_1:
			LEA DX,TIPInput
    		MOV AH,9
    		INT 21H
    		LEA DX,StringInput
    		MOV AH,0AH
    		INT 21H
    		CMP [StringInput+1],0
    		JZ INPUT1_1
    	MOV DL,10
    	MOV AH,02H
    	INT 21H
    	RET
   	InputString ENDP
    
    
CODES ENDS
    END START










