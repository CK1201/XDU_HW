DATAS SEGMENT
	TIPInput DB 'Please input array:','$'
	TIP3_2 DB 'Original array:','$'
	TIP3_3 DB 'New array:','$'
	StringInput DB 100
				DB ?
				DB 100 DUP(?)
	ARRAY DB 100 DUP(0)
	ARRAYLength DB 0
	ARRAYSorted DB 100 DUP(0)
	SpiltSymbol DB ','
	TEMP DB 0
	Decimal DB 10
	HEX DB 16
	NNN DB 47
    ;�˴��������ݶδ���  
DATAS ENDS

STACKS SEGMENT
	DB 100 DUP(?)
	TOP LABEL WORD
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;�����ַ���
	CALL InputString
    ;���ַ���תΪ���ַ�������
    CALL Str2Num
    ;���ԭ����
    LEA DX,TIP3_2
    MOV AH,9
    INT 21H
    
    MOV AL,[ARRAYLength]
    MOV AH,0
    MOV CX,AX
    LEA SI,ARRAY
	CALL DISPARRRY
	
	MOV DL,10
    MOV AH,02H
    INT 21H
    ;��������
    CALL SortARRAY
    
    
	;���������
	LEA DX,TIP3_3
    MOV AH,9
    INT 21H
    
    LEA SI,ARRAYSorted
	CALL DISPARRRY
    
    
	MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;����������;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�����ַ���
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
;���ַ���תΪ���ַ�������,�Զ��ŷָ��ͽ�β
;��ڲ�������
;���ڲ�������
	Str2Num PROC FAR
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
		RET
	Str2Num ENDP
;��������
;��ڲ�������
;���ڲ�������
	SortARRAY PROC FAR
		LEA BX,ARRAY
		LEA BP,ARRAYSorted
		MOV SI,0
		MOV DI,0
		
		MOV AL,[ARRAYLength];��ѭ��
		SORT:
			MOV AH,[ARRAYLength]
			MOV DH,127
			FindMin:
				CMP DH,[BX][SI]
				JB FindMinNEXT
				MOV DH,[BX][SI]
				MOV CX,SI
				FindMinNEXT:
				INC SI
				DEC AH
				JNZ FindMin
			MOV [BP][DI],DH
			INC DI
			MOV SI,CX
			MOV DH,127
			MOV [BX][SI],DH
			MOV SI,0
			DEC AL
			JNZ SORT

		;MOV DL,[BX]
		
		RET
	SortARRAY ENDP
;��ʮ�����������
;��ڲ�����ʮ����������ַSI
;���ڲ�������
	Disp PROC FAR
		PUSH CX
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
		POP CX
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





CODES ENDS
    END START























