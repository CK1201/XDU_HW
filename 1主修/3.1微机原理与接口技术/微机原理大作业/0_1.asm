DATAS SEGMENT
	TIPInputString DB 'Please input string:','$'
	TIPOriginalString DB 'Original string:','$'
	TIPNewString DB 'New string:','$'
	BUFFSTRING  DB 100
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
    
	CALL CapitalizeString
    
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;函数定义区;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;把字符变为大写
;入口参数：无
;出口参数：无
CapitalizeString PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
    ;输入字符串
	CALL InputString
    ;把输入字符串个数转化为字类型给CX来循环处理
    LEA BX,BUFFSTRING+2
    MOV AL,BUFFSTRING+1
    CBW
    MOV CX,AX
    ADD BX,AX
    MOV BYTE PTR [BX],'$'
    ;显示原字符串
    LEA DX,TIPOriginalString
    MOV AH,9
    INT 21H
    LEA DX,BUFFSTRING+2
    MOV AH,9
    INT 21H
    
    MOV DL,10
    MOV AH,02H
    INT 21H
    ;转换为大写
    LEA BX,BUFFSTRING+2
	Capitalize:
		CMP BYTE PTR [BX],65;判断是字母还是数字
		JB NoCapitalize
		AND BYTE PTR [BX],5FH
    	NoCapitalize:
    		INC BX
	LOOP Capitalize
	;;显示新字符串
	LEA DX,TIPNewString
    MOV AH,9
    INT 21H
    LEA DX,BUFFSTRING+2
    MOV AH,9
    INT 21H
    
    
    POP DI
    POP SI
    POP BP
    POP SP
    POP DX
 	POP CX
 	POP BX
 	POP AX
 	RET
CapitalizeString ENDP
;输入字符串
InputString PROC FAR
    INPUTStr:
		LEA DX,TIPInputString
    	MOV AH,9
    	INT 21H
    	LEA DX,BUFFSTRING
    	MOV AH,0AH
    	INT 21H
    	CMP [BUFFSTRING+1],0
    	JZ INPUTStr
    MOV DL,10
    MOV AH,02H
    INT 21H
    RET
InputString ENDP
   	
CODES ENDS
    END START



















