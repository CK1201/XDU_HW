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
	;检测键盘输入是否为Esc，若是则返回主菜单，否则重做
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION1

MISSION2:
	CALL FindMaxStr
	;检测键盘输入是否为Esc，若是则返回主菜单，否则重做
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION2

MISSION3:
	CALL SortTheArray
	;检测键盘输入是否为Esc，若是则返回主菜单，否则重做
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION3	

MISSION4:
	CALL ShowTime
	;检测键盘输入是否为Esc，若是则返回主菜单，否则重做
	MOV AH,8
	INT 21H
	CMP AL,1BH
	JZ ReturnMenu
	JMP MISSION4

MISSION5:
    ;此处输入代码段代码
    ;清屏
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;函数定义区;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Menu PROC FAR
	;清屏
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
	;第一条提示
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,1
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu1
	INT 21H
	;第二条提示
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,2
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu2
	INT 21H
	;第三条提示
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,3
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu3
	INT 21H
	;第四条提示
	MOV AH,2
	MOV BH,0
	MOV DL,0
	MOV DH,4
	INT 10H
	MOV AH,9
	LEA DX,TIPMenu4
	INT 21H
	;第五条提示
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
;把十进制数输出
;入口参数：无
;出口参数：无
ShowTime PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
 	;清屏
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
;时间矫正时间
;入口参数：无
;出口参数：无
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
;实时输出时间
;入口参数：时间缓冲区ARRAY
;出口参数：无
DispRealTIME PROC FAR
	PUSH SI
	;清屏
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
;把数组按升序排列，十六进制输出
;入口参数：无
;出口参数：无
SortTheArray PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
 	;清屏
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
 	
 	MOV AH,2
	MOV BH,1
	MOV DL,0
	MOV DH,0
	INT 10H
	
	MOV [SpiltSymbol],',';输入以逗号分隔
	;输入字符串
	LEA SI,TIPInputArray
	CALL InputString
	;清屏
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
    ;把字符串转为数字放入数组
    CALL Str2Num
    ;输出原数组
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
    ;递增排序
    CALL SortARRAY
    
    
	;输出新数组
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
;把字符串转为数字放入数组,以逗号分隔和结尾
;入口参数：无
;出口参数：无
Str2Num PROC FAR
	MOV AL,BUFFSTRING+1
    CBW
    MOV CX,AX
    
	LEA SI,BUFFSTRING+2
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
	RET
Str2Num ENDP
;递增排序
;入口参数：无
;出口参数：无
SortARRAY PROC FAR
	LEA BX,ARRAY
	LEA BP,ARRAYSorted
	MOV SI,0
	MOV DI,0
		
	MOV AL,[ARRAYLength];外循环
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
;把十六进制数输出
;入口参数：十六进制数地址SI
;出口参数：无
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
;把字符变为大写
;入口参数：无
;出口参数：无
FindMaxStr PROC FAR
	PUSH AX
 	PUSH BX
 	PUSH CX
 	PUSH DX
 	PUSH SP
 	PUSH BP
 	PUSH SI
 	PUSH DI
 	
 	;清屏
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
 	
 	MOV AH,2
	MOV BH,1
	MOV DL,0
	MOV DH,0
	INT 10H
    ;输入字符串
    LEA SI,TIPInputString
    CALL InputString
    ;清屏
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
    ;把输入字符串个数转化为字类型给CX来循环处理，并在结尾加上'$'
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
    ;输出最大值提示符
    LEA DX,TIPMax
    MOV AH,9
    INT 21H
    ;找出最大值
    LEA BX,BUFFSTRING+2
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
 	
 	;清屏
    MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
 	
 	MOV AH,2
	MOV BH,1
	MOV DL,0
	MOV DH,0
	INT 10H
    ;输入字符串
    LEA SI,TIPInputString
	CALL InputString
	;清屏
	MOV AH,0
	MOV AL,3
	MOV BL,0
	INT 10H
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

