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
    ;�˴��������ݶδ���  
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX

    
    ;CALL CorrectTIME
    CALL DispRealTIME
    
    ;�˴��������δ���
    MOV AH,4CH
    INT 21H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;����������;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�����ַ���
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
;��ʮ���������
;��ڲ�����ʮ��������ַSI
;���ڲ�������
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
	
;���ʱ��
;��ڲ�����ʱ�仺����ARRAY
;���ڲ�������
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
    
;���ַ���תΪ���ַ�������,��ð�ŷָ��ͽ�β
;��ڲ�������
;���ڲ�������
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
		MOV DH,0			;���ڴ���������
		MOV DL,0			;���ڴ�Ÿ�����λ��
		MOV AL,0			;���ڴ�Ÿ�����ʮ����
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
				INC SI;ָ�򶺺���һ��
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
	
;��ʮ�����������
;��ڲ�����ʮ��������ַSI
;���ڲ�������
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
;�������
;��ڲ����������׵�ַSI������CX
;���ڲ�������
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
	
;ʱ�����ʱ��
;��ڲ�������
;���ڲ�������
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

;ʵʱ���ʱ��
;��ڲ�����ʱ�仺����ARRAY
;���ڲ�������
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


























