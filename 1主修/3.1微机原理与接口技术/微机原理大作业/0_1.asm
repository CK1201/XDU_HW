DATAS SEGMENT
	TIPInputString DB 'Please input string:','$'
	TIPOriginalString DB 'Original string:','$'
	TIPNewString DB 'New string:','$'
	BUFFSTRING  DB 100
				DB ?
				DB 100 DUP(?)
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
    
	CALL CapitalizeString
    
    ;�˴��������δ���
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;����������;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
 	
    ;�����ַ���
	CALL InputString
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



















