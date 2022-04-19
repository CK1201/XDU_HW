DATAS SEGMENT
	TIPMenu1 DB 'Push 1 To Capitalize String','$'
	TIPMenu2 DB 'Push 2 To Find The Maximum of The String','$'
	TIPMenu3 DB 'Push 3 To Sort The Array','$'
	TIPMenu4 DB 'Push 4 To Show Time in Real Time','$'
	TIPMenu5 DB 'Push 5 To Exit','$'
	
	TIPInputString DB 'Please input string:','$'
	TIPOriginalString DB 'Original string:','$'
	TIPNewString DB 'New string:','$'
	
	TIPMax DB 'The maximum is ','$'
	
	TIPInputArray DB 'Please input array:','$'
	TIPOriginalArray DB 'Original array:','$'
	TIPNewArray DB 'New array:','$'
	
	TIPInputTIME DB 'Please input TIME(HH:MM:SS:):','$'
	
	
	BUFFSTRING  DB 100
				DB ?
				DB 100 DUP(?)
	ARRAY DB 100 DUP(0)
	ARRAYLength DB 0
	ARRAYSorted DB 100 DUP(0)
	SpiltSymbol DB ?
	TIMEBUFF DB 3 DUP(0)
	
	TEMP DB 0
	Decimal DB 10
	HEX DB 16
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
    
ReturnMenu:
	CALL Menu

Redo:
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,0
	INT 10H
	
	MOV AH,1
	INT 21H
	
	
	CMP AL,'1'
	JZ MISSION1
	CMP AL,'2'
	JZ MISSION2
	CMP AL,'3'
	JZ MISSION3
	CMP AL,'4'
	JZ MISSION4
	CMP AL,'5'
	JZ MISSION5
	JMP Redo
	
MISSION1:
	CALL CapitalizeString
	;�����������Ƿ�ΪEsc�������򷵻����˵�����������
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION1

MISSION2:
	CALL FindMaxStr
	;�����������Ƿ�ΪEsc�������򷵻����˵�����������
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION2

MISSION3:
	CALL SortTheArray
	;�����������Ƿ�ΪEsc�������򷵻����˵�����������
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION3	

MISSION4:
	CALL ShowTime
	;�����������Ƿ�ΪEsc�������򷵻����˵�����������
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION4

MISSION5:
    ;�˴��������δ���
    ;����
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;����������;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Menu PROC FAR
	;����
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
	;��һ����ʾ
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,1
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu1
	INT 21H
	;�ڶ�����ʾ
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,2
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu2
	INT 21H
	;��������ʾ
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,3
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu3
	INT 21H
	;��������ʾ
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,4
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu4
	INT 21H
	;��������ʾ
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,5
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu5
	INT 21H
	
	RET
Menu ENDP
;��ʮ���������
;��ڲ�������
;���ڲ�������
ShowTime PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
 	;����
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
 	
 	MOV AH,2
	MOV BH,1
	MOV DL,0
	MOV DH,0
	INT 10H
	
	MOV [SpiltSymbol],':'
	CALL CorrectTIME
    CALL DispRealTIME
    
	POP DI
    POP SI
    POP BP
    POP SP
    POP DX
 	POP CX
 	POP BX
 	POP AX
    RET
ShowTime ENDP
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
;ʱ�����ʱ��
;��ڲ�������
;���ڲ�������
    CorrectTIME PROC FAR
    	LEA DX,TIPInputTIME
    	MOV AH,9
    	INT 21H
    	LEA SI,TIPInputTIME
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
	;����
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
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
    	JNZ StopShow
    	JMP DISPREALTIME1
    StopShow:
    	
    POP SI
    RET
DispRealTIME ENDP
;�����鰴�������У�ʮ���������
;��ڲ�������
;���ڲ�������
SortTheArray PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
 	;����
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
 	
 	MOV AH,2
	MOV BH,1
	MOV DL,0
	MOV DH,0
	INT 10H
	
	MOV [SpiltSymbol],',';�����Զ��ŷָ�
	;�����ַ���
	LEA SI,TIPInputArray
	CALL InputString
	;����
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
    ;���ַ���תΪ���ַ�������
    CALL Str2Num
    ;���ԭ����
    LEA DX,TIPOriginalArray
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
	LEA DX,TIPNewString
    MOV AH,9
    INT 21H
    
    LEA SI,ARRAYSorted
	CALL DISPARRRY
	
    POP DI
    POP SI
    POP BP
    POP SP
    POP DX
 	POP CX
 	POP BX
 	POP AX
    RET
SortTheArray ENDP
;���ַ���תΪ���ַ�������,�Զ��ŷָ��ͽ�β
;��ڲ�������
;���ڲ�������
Str2Num PROC FAR
	MOV AL,BUFFSTRING+1
    CBW
    MOV CX,AX
    
	LEA SI,BUFFSTRING+2
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
;���ַ���Ϊ��д
;��ڲ�������
;���ڲ�������
FindMaxStr PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
 	;����
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
 	
 	MOV AH,2
	MOV BH,1
	MOV DL,0
	MOV DH,0
	INT 10H
    ;�����ַ���
    LEA SI,TIPInputString
    CALL InputString
    ;����
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
    ;�������ַ�������ת��Ϊ�����͸�CX��ѭ���������ڽ�β����'$'
    LEA BX,BUFFSTRING+2
    MOV AL,BUFFSTRING+1
    CBW
    MOV CX,AX
    ADD BX,AX
    MOV BYTE PTR [BX],'$'
    ;��ʾԭ�ַ���
    LEA DX,TIPOriginalString
    MOV AH,9
    INT 21H
    LEA DX,BUFFSTRING+2
    MOV AH,9
    INT 21H
    MOV DL,10
    MOV AH,02H
    INT 21H
    ;������ֵ��ʾ��
    LEA DX,TIPMax
    MOV AH,9
    INT 21H
    ;�ҳ����ֵ
    LEA BX,BUFFSTRING+2
    MOV DL,0
    FindMax:
    	CMP [BX],DL
    	JB NotBigger
    	MOV DL,[BX]
    	NotBigger:
    		INC BX
    LOOP FindMax
    ;������
    MOV AH,02H
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
FindMaxStr ENDP
;���ַ���Ϊ��д
;��ڲ�������
;���ڲ�������
CapitalizeString PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
 	;����
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
 	
 	MOV AH,2
	MOV BH,1
	MOV DL,0
	MOV DH,0
	INT 10H
    ;�����ַ���
    LEA SI,TIPInputString
	CALL InputString
	;����
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
    ;�������ַ�������ת��Ϊ�����͸�CX��ѭ������
    LEA BX,BUFFSTRING+2
    MOV AL,BUFFSTRING+1
    CBW
    MOV CX,AX
    ADD BX,AX
    MOV BYTE PTR [BX],'$'
    ;��ʾԭ�ַ���
    LEA DX,TIPOriginalString
    MOV AH,9
    INT 21H
    LEA DX,BUFFSTRING+2
    MOV AH,9
    INT 21H
    
    MOV DL,10
    MOV AH,02H
    INT 21H
    ;ת��Ϊ��д
    LEA BX,BUFFSTRING+2
	Capitalize:
		CMP BYTE PTR [BX],65;�ж�����ĸ��������
		JB NoCapitalize
		AND BYTE PTR [BX],5FH
    	NoCapitalize:
    		INC BX
	LOOP Capitalize
	;;��ʾ���ַ���
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
;�����ַ���
InputString PROC FAR
    INPUTStr:
		MOV DX,SI
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

