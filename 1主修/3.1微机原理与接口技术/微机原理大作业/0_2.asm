DATAS SEGMENT
	TIPInputString DB 'Please input string:','$'
	TIPOriginalString DB 'Original string:','$'
	TIPMax DB 'The maximum is ','$'
	StringInput DB 100
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
    ;�����ַ���
    CALL InputString
    ;�������ַ�������ת��Ϊ�����͸�CX��ѭ���������ڽ�β����'$'
    LEA BX,StringInput+2
    MOV AL,StringInput+1
    CBW
    MOV CX,AX
    ADD BX,AX
    MOV BYTE PTR [BX],'$'
    ;��ʾԭ�ַ���
    LEA DX,TIP2_2
    MOV AH,9
    INT 21H
    LEA DX,StringInput+2
    MOV AH,9
    INT 21H
    MOV DL,10
    MOV AH,02H
    INT 21H
    ;������ֵ��ʾ��
    LEA DX,TIP2_3
    MOV AH,9
    INT 21H
    ;�ҳ����ֵ
    LEA BX,StringInput+2
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
    ;�˴��������δ���
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;����������;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;������ʾ
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










