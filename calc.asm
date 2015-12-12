TITLE 	Fancy Calculator
PAGE	60,132
;
;
;Created by Eric Wilson on or about 12/01/2015
;
;Define constants
CR EQU 0DH 		;define carriage return
LF EQU 0AH		;define line feed
EOT EQU '$'		;define end of text marker
;
JMP START 		;Jump to that startsssss
;
;What's a variable?
;
INFOP:	DB LF,CR,"*****FANCY CALCULATOR*******"
 		DB LF,CR,"|     By: Eric Wilson      |"
 		DB LF,CR,"| Calculates simple        |"
 		DB LF,CR,"| mathematical expressions |"
 		DB LF,CR,"| with pinpoint integer    |"
 		DB LF,CR,"| accuracy faster than     |"
 		DB LF,CR,"| Einstein's smart brother!|"
 		DB LF,CR,"| Supports [+,-,*,/] and   |"
 		DB LF,CR,"| non-negative operands.   |"
 		DB LF,CR,"****************************"
 		DB LF,LF,CR,EOT
;		
IFORM: 	DB LF,CR,"                          "
PROMP:  DB LF,CR,"Please express yourself mathematicallly:"
		DB LF,CR,EOT
INBUF  DB "                                      "
		DB LF,CR,EOT
OPND1:  DB 203 			;operand storage
OPND2:  DB 5 			;operand storage
OPRTR:  DB "*" 			;operator storage
RESLT: 	DB "*****",EOT ;5 bytes reserved for ascii result
RMNDR: 	DB "     ",EOT ;5 bytes reserved for ascii remainder
RSSTR: 	DB LF,CR,"Result: ",EOT
RMSTR:  DB "Remndr: ",EOT
OPST1:  DB "&&&"
OPST2:  DB "&&&"
START:
 	;print info panel
 	MOV AH, 09H
 	LEA DX,INFOP
 	INT 21H
STRT1:
	;reset memory values
	MOV B[RMNDR]," "  	 	;reset remainder to check for division
	;CALL INRST 			 	;reset input buffer

	;prompt user input
	MOV AH,09H
	LEA DX,PROMP
	INT 21H

 	;TODO get user input
 	MOV AH,0AH
 	MOV DX,OFFSET INBUF
 	INT 21H

 	;TODO parse user input
 	CALL PARSE

 	;DEBUG
 	CALL VALUS
	
 	;call calculation subroutine
 	;CALL CALC 	

 	;Remove leading 0s from result
 	LEA SI,RESLT
 	CALL LDZRO

 	;Print result string
 	MOV AH, 09H
 	LEA DX,RSSTR
 	INT 21H

 	;Print result
 	MOV AH, 09H
 	LEA DX,RESLT
 	INT 21H

 	;special for division
 	LEA SI,RMNDR
 	CMP B[SI],"0" 	;if remainder has been modified
 	JE PRTRM 		;jump to print remainder

EXSTR:
 	;exit
 	CALL EXIT

PRTRM:
	;next line
	MOV AH,02H
	MOV DL,LF
	INT 21H
	MOV AH,02H
	MOV DL,CR
	INT 21H

	;remove leading 0s from remainder
	LEA SI,RMNDR
	CALL LDZRO

	;Print remainder string
	MOV AH, 09H
	LEA DX,RMSTR
	INT 21H

	;Print remainder
	MOV AH, 09H
	LEA DX, RMNDR
	INT 21H

	CALL EXIT
;***************************************************************
PARSE:
	LEA SI,INBUF + 2 	;point SI at beginning of
						;user input
	;get first operand
	MOV AH,0 		;reset AH
	MOV AL,0 		;reset AL
PRSE1:
	CMP B[SI]," " 		;check for space
	JE PRSE2X 		;copy 1st operand to memory
	INC SI 			;next character
	INC AH 			;position count + 1
	JMP PRSE1
PRSE2X:
	MOV AL,AH 		;copy position count
	LEA DI,OPST1 + 2
PRSE2: 				;copy first operand into memory
	CMP AH,0
	JE PRSE3
	DEC SI
	MOV BH,B[SI]
	MOV B[DI],BH
	DEC AH
	DEC DI
	JMP PRSE2
PRSE3: 				;loop to find space again
	CMP B[SI]," "
	JE PRSE4
	INC SI
	JMP PRSE3
PRSE4: 				;save operator to memory
	INC SI
	MOV BH,B[SI]
	LEA DI,OPRTR
	MOV B[DI],BH
	MOV AH,0
	MOV AL,0
	INC SI 		;move to expected pos of oprnd2
	INC SI
PRSE5:
	CMP B[SI]," " 		;check for space
	JE PRSE6X 		;copy 2nd operand to memory
	INC SI 			;next character
	INC AH 			;position count + 1
	JMP PRSE5
PRSE6X:
	MOV AL,AH
	LEA DI, OPST2 + 2
	DEC SI
	DEC AH
PRSE6:
	CMP AH,0
	JE PRSE7
	DEC SI
	MOV BH,B[SI]
	MOV B[DI],BH
	DEC AH
	DEC DI
	JMP PRSE6
PRSE7:
	RET
;***************************************************************
;Subroutine CALC
;Performs integer calculations
CALC:
	MOV BH,B[OPND1] 	;load first operand into BH register
	MOV BL,B[OPND2] 	;load second operand into BL register
	MOV DH,B[OPRTR] 	;load operator byte into DH register

	;find appropriate operation
	CMP DH,"+" 	;check for addition
	JE ADDTN
	CMP DH,"-" 	;check for subtraction
	JE SUBTN
	CMP DH,"*" 	;check for multiplication
	JE MULTN
	CMP DH,"/" 	;check for division
	JE DIVSN
	JMP NOOPR 	;if invalid operand
ADDTN: 	;perform addition
	MOV AH,0 		;clear upper half of destination
	MOV AL,BH 		;move 1st operand into AX
	MOV BH,0 		;clear upper half of source
 	ADD AX,BX 		;AX should now contain binary result
 	LEA SI,RESLT 	;point SI at result buffer
 	CALL BA16
 	RET
SUBTN: 	;perform subtraction
 	MOV AH,0 		;clear upper half of destination
	MOV AL,BH 		;move 1st operand into AX
	MOV BH,0 		;clear upper half of source
 	SUB AX,BX 		;AX should now contain binary result
 	LEA SI,RESLT 	;point SI at result buffer
 	CALL BA16
 	RET
MULTN: 	;perform multiplication
	MOV AH,0 		;clear upper half of AX
	MOV AL,BH 		;move 1st operand into AL
	MUL BL 			;multiply it
	LEA SI,RESLT 	;point SI at result buffer
	CALL BA16 
	RET
DIVSN: 	;perform division
	MOV AH,0 		;clear AH
	MOV AL,BH 		;load numerator into AH
	DIV BL 			;divide it
	MOV CL,AH 		;keep remainder in CL temporarily
	MOV AH,0 		;clear upper half of AX
	LEA SI,RESLT	
	CALL BA16 		;put quotient in result buffer
	MOV AL,CL 		;load remainder into AL
	MOV AH,0 		;clear upper half of AX
	LEA SI,RMNDR 	;point SI at remainder buffer
	CALL BA16 		
	RET
NOOPR: 	;tell the user they're being stupid
	;TODO do this
;***************************************************************
;Subroutine LDZRO
;
;Eliminates leading 0s in 5 byte string
;
;ENTRY: SI points to string buffer location
;
;Exit: Where did the zeros go?
LDZRO:
	CMP B[SI],"0"
	JNE ZRTRN
	MOV B[SI]," "
	CMP B[SI+1],"0"
	JNE ZRTRN
	MOV B[SI+1]," "
	CMP B[SI+2],"0"
	JNE ZRTRN
	MOV B[SI+2]," "
	CMP B[SI+3],"0"
	JNE ZRTRN
	MOV B[SI+3]," "
	RET

ZRTRN:
	RET

INRST:
	LEA SI,INBUF
	MOV AL,20
INRS1:
	DEC AL
	CMP AL,0
	JE INRS2
	MOV B[SI],"_"
	INC SI
	JMP INRS1
INRS2:
	RET	
;***************************************************************
;	SUBROUTINE BA16
;
;	This subroutine converts a 16 bit binary value into 5 bytes
;	of printable decimal ASCII.
;
;	ENTRY:	The 16 bit value is in register AX
;		Regster SI points to the external 5 byte buffer
;	EXIT:	The external buffer contains the 5 characters
;
;****************************************************************
;
BA16:	MOV	DX, 0		;clear upper half of dividend
	MOV	BX, 10000	;set divisor
	DIV	BX		;create 10K character
	MOV	B[SI], AL	;save 10K count
	MOV	AX, DX		;get remainder
	MOV	DX, 0		;clear upper half of dividend
	MOV	BX, 1000	;set divisor
	DIV	BX		;create 1K character
	MOV	B[SI+1], AL	;save 1K count
	MOV	AX, DX		;get remainder
	MOV	DX,0		;clear upper half of dividend
	MOV	BX, 100		;set divisor
	DIV	BX		;create 100 character
	MOV	B[SI+2], AL	;save 100 count
	MOV	AX, DX		;get remainder
	MOV	BL, 10		;set divisor
	DIV	BL		;create tens and units
	MOV	B[SI+3], AL	;save tens count
	MOV	B[SI+4], AH	;save units count
	ADD	B[SI], 30H	;convert binary digits to ASCII
	ADD	B[SI+1], 30H
	ADD	B[SI+2], 30H
	ADD	B[SI+3], 30H
	ADD	B[SI+4], 30H
	MOV	B[SI+5], EOT	;place end of message mark
	MOV	BX, 5
	ADD	SI, BX		;point to byte after conversion
	RET
;*******************************************************************

; 	SUBROUTINE EXIT
EXIT:
	MOV AX,4C00H
	INT 21H
	RET

;*******************************************************************

;Subroutine A2B8
;
;This subroutine converts up to 3 bytes of ASCII into 8 bit binary
;The input value must not exceed 255 - base 10
;No error checking is performed
;
;ENTRY: SI points to input buffer
;EXIT: AL holds binary value
;
A2B8:
    PUSH    SI                ;save SI on entry
    LEA    DI, MULT            ;point to placeholder values
    SUB    B[SI], 30H            ;remove ASCII bias from numbers
    SUB    B[SI + 1], 30H
    SUB    B[SI + 2], 30H
    MOV    CX, 3                 ;initialize loop counter
    MOV    BL, 0                ;initialize sum register
AB1:    MOV    AL, [SI]            ;get first byte
    MOV    AH, 0                ;clear upper byte of AX
    MUL    B[DI]                ;multiply by placeholder
    ADD    BL, AL                ;save value
    INC    DI                ;point to next place holder
    INC    SI                ;point to next byte
    LOOP    AB1
    MOV    AL, BL                ;place sum into output register
    POP    SI                ;restore SI
    RET
MULT    DB    100, 10, 1

;*******************
;*******************
;print values subroutine for debug purposes
VALUS:
	;next line
	MOV AH,02H
	MOV DL,LF
	INT 21H
	MOV AH,02H
	MOV DL,CR
	INT 21H

	;print 1st operand
	MOV AH,02H
	MOV DL,B[OPST1]
	INT 21H
	MOV AH,02H
	MOV DL,B[OPST1 + 1]
	INT 21H
	MOV AH,02H
	MOV DL,B[OPST1 + 2]
	INT 21H

	;next line
	MOV AH,02H
	MOV DL,LF
	INT 21H
	MOV AH,02H
	MOV DL,CR
	INT 21H

	;print operator
	MOV AH,02H
	MOV DL,B[OPRTR]
	INT 21H

	;next line
	MOV AH,02H
	MOV DL,LF
	INT 21H
	MOV AH,02H
	MOV DL,CR
	INT 21H

	;print 2nd operand
	MOV AH,02H
	MOV DL,B[OPST2]
	INT 21H
	MOV AH,02H
	MOV DL,B[OPST2 + 1]
	INT 21H
	MOV AH,02H
	MOV DL,B[OPST2 + 2]
	INT 21H

	RET

