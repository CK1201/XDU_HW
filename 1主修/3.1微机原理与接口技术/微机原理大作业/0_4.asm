DATAS SEGMENT
	TIPInputTIME DB 'Please input TIME(HH:MM:SS:):','$'
	StringInput DB 100
				DB ?
				DB 100 DUP(?)
	ARRAY DB 100 DUP(0)
	ARRAYLength DB 0
	Decimal DB 10
	HEX DB 16
	SpiltSymbol DB ':'
	TEMP DB 0
	TIMEBUFF DB 3 DUP(0)
	NNN DB 47
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

    
    ;CALL CorrectTIME
    CALL DispRealTIME
    
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;函数定义区;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;输入字符串
    InputString PROC FAR
    	INPUT1_1:
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
;把十进制数输出
;入口参数：十进制数地址SI
;出口参数：无
	DispDec PROC FAR
		PUSH AX
 		PUSH BX
 		PUSH CX
 		PUSH DX
 		
 		MOV AL,[SI]
		CBW
		DIV Decimal
		ADD AH,'0'
		MOV BH,AH
		ADD AL,'0'
		
		MOV DL,AL
    	MOV AH,02H
    	INT 21H
    	
    	MOV DL,BH
    	INT 21H
			
		POP DX
 		POP CX
 		POP BX
 		POP AX
		RET
	DispDec ENDP
	
;输出时间
;入口参数：时间缓冲区ARRAY
;出口参数：无
	DispTIME PROC FAR
		PUSH SI
		LEA SI,ARRAY
    	CALL DispDec
    
    	MOV DL,':'
    	MOV AH,02H
    	INT 21H
    
    	INC SI
    	CALL DispDec
    
    	MOV DL,':'
    	MOV AH,02H
    	INT 21H
    
    	INC SI
    	CALL DispDec
    	POP SI
    	RET
	DISPTIME ENDP
    
;把字符串转为数字放入数组,以冒号分隔和结尾
;入口参数：无
;出口参数：无
    Str2Num PROC FAR
    	PUSH AX
 		PUSH BX
 		PUSH CX
 		PUSH DX
    
    
		MOV AL,StringInput+1
    	CBW
    	MOV CX,AX
    	
		LEA SI,StringInput+2
		LEA DI,ARRAY
		MOV DH,0			;用于存放数组个数
		MOV DL,0			;用于存放该数字位数
		MOV AL,0			;用于存放该数字十进制
		Spilt:
			MOV BL,[SpiltSymbol]
			CMP BYTE PTR [SI],BL
			JZ AddNum
			INC SI
			INC DL
			JMP NotSpilt
			AddNum:
				INC DH
				PUSH CX
				PUSH SI
				
				MOV AL,DL
				CBW
    			MOV CX,AX
    			
    			Return:
    				DEC SI
    				;MOV DL,[SI]
    				;MOV AH,02H
    				;INT 21H
    				LOOP Return
    			
    			MOV CX,AX
    			DEC CX
    			
    			MOV AL,0
    			MOV AH,0
    			
    			MOV AL,[SI]
    			SUB AL,'0'
    			
    			
    			
				Str2Dec:
					INC SI
					MUL Decimal
					MOV BL,[SI]
					SUB BL,'0'
					ADD AL,BL
					LOOP Str2Dec
					
				MOV [DI],AL
				INC DI
				MOV DL,0
				MOV AL,0
				POP SI
				INC SI;指向逗号下一个
				POP CX
			NotSpilt:
			LOOP Spilt
		MOV [ARRAYLength],DH
		
		POP DX
 		POP CX
 		POP BX
 		POP AX
		RET
	Str2Num ENDP
	
;把十六进制数输出
;入口参数：十进制数地址SI
;出口参数：无
	Disp PROC FAR
		PUSH AX
 		PUSH BX
 		PUSH CX
 		PUSH DX
 		
		MOV AL,[SI]
		NEXTNum:
			CBW
			DIV HEX
			CMP AH,9
			JA LETTER
			ADD AH,'0'
			JMP NotLETTER
			LETTER:
				SUB AH,10
				ADD AH,'A'
			
			NotLETTER:
				PUSH AX
				INC [TEMP]
			
				CMP AL,0
				JZ NoMore
			
				JMP NEXTNum
			
		NoMore:
			MOV AL,[TEMP]
			CBW
			MOV CX,AX
			
			OUTNum:
				POP DX
				XCHG DL,DH
    			MOV AH,02H
    			INT 21H
    			LOOP OUTNum
			
			
			
		MOV [TEMP],0
		POP DX
 		POP CX
 		POP BX
 		POP AX
		RET
	Disp ENDP
;输出数组
;入口参数：数组首地址SI，长度CX
;出口参数：无
	DISPARRRY PROC FAR
		PUSH AX
 		PUSH BX
 		PUSH CX
 		PUSH DX
 		
		MOV AL,[ARRAYLength]
		MOV AH,0
		MOV CX,AX
		DEC CX
		CALL Disp
		INC SI
		DispNextNum:
			MOV DL,[SpiltSymbol]
    		MOV AH,02H
    		INT 21H
			CALL Disp
    		INC SI
    	LOOP DispNextNum
    	
    	POP DX
 		POP CX
 		POP BX
 		POP AX
		RET
	DISPARRRY ENDP
	
;时间矫正时间
;入口参数：无
;出口参数：无
    CorrectTIME PROC FAR
    	LEA DX,TIPInputTIME
    	MOV AH,9
    	INT 21H
    	CALL InputString
    	CALL Str2Num
    	
    	LEA SI,ARRAY
    	MOV CH,[SI]
    	INC SI
    	MOV CL,[SI]
    	INC SI
    	MOV DH,[SI]
    	MOV DL,0
    	MOV AH,2DH
    	INT 21H
    	RET
	CorrectTIME ENDP

;实时输出时间
;入口参数：时间缓冲区ARRAY
;出口参数：无
	DispRealTIME PROC FAR
		PUSH SI
		DISPREALTIME1:
			MOV AH,2
			MOV BH,0
			MOV DL,72
			MOV DH,0
			INT 10H
			
			MOV AH,2CH
    		INT 21H
    		MOV [ARRAY],CH
    		MOV [ARRAY+1],CL
    		MOV [ARRAY+2],DH
    
    		CALL DispTIME
    		
    		MOV AH,2
    		MOV DX,090AH
    		MOV BH,0
    		INT 10H
    		
    		MOV CX,0FFFFH
    	DELAY:LOOP DELAY
    		MOV AH,01H
    		INT 16H
    		;CMP AL,0
    		JNZ StopShow
    		JMP DISPREALTIME1
    	StopShow:
    	
    	POP SI
    	RET
	DispRealTIME ENDP

CODES ENDS
    END START


























