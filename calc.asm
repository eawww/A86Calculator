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
INFOP:	DB LF,CR,"*****FANCY CALCULATOR*****"
 		DB LF,CR,"     By: Eric Wilson      "
 		DB LF,CR,"Calculates simple         "
 		DB LF,CR,"mathematical expressions  "
 		DB LF,CR,"with pinpoint integer     "
 		DB LF,CR,"accuracy faster than      "
 		DB LF,CR,"Einstein's smart brother! "
 		DB LF,CR,"Supports [+,-,*,/]        "
 		DB LF,CR,EOT
;		
IFORM: 	DB LF,CR,"                          "
INSTR:  DB 0 DUP 20 
OPND1:  DB 7
OPND2:  DB 4
OPRTR:  DB "+"
RESLT: 	DB "     ",LF,CR,EOT ;5 bytes reserved for ascii result
START:
 	;print info panel
 	MOV AH, 09H
 	LEA DX,INFOP
 	INT 21H

 	;TODO prompt user input
 	;TODO get user input
 	;TODO parse user input

 	;call calculation subroutine
 	CALL CALC 	

 	;Print result
 	MOV AH, 09H
 	LEA DX,RESLT
 	INT 21H

 	;exit
 	CALL EXIT


;Subroutine CALC
;Performs integer calculations
CALC:
	MOV BL,B[OPND1] 	;load first operand into BL register
	MOV BH,B[OPND2] 	;load second operand into BH register
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
	MOV AL,BL 		;move 1st operand into AX
 	ADD AL,BH 		;AX should now contain binary result
 	LEA SI,RESLT 	;point SI at result buffer
 	CALL BA16
 	RET
SUBTN: 	;perform subtraction
MULTN: 	;perform multiplication
DIVSN: 	;perform division
NOOPR: 	;tell the user they're being stupid


;Subroutine B2A8
;
;A subroutine that converts an 8 bit binary value into three bytes of ASCII
;
;ENTRY: DI points to save buffer for ASCII
;    AL holds 8 bit value to convert
;EXIT: Bytes written to memory pointed to by DI
;
B2A8:
    MOV    CX, 0                ;clear counter
HUND:    SUB    AL, 100                ;subtract 100
    JC    TENS                ;if over subtracted, process tens
    INC   CX                ;ohterwise add to hundreds count
    JMP   HUND                ;check for another hundred
TENS:    MOV    [DI], CL            ;save hundreds count
    ADD   AL, 100                ;add back excessive subtraction
    MOV   CX, 0                ;clear counter
TENS1:    SUB    AL, 10                ;count how many tens
    JC    UNITS                ;subtracted too much
    INC   CX                ;increment tens count
    JMP   TENS1                ;count more
UNITS:    MOV    B[DI + 1], CL            ;save tens count
    ADD   AL, 10                ;restore count
    MOV   B[DI + 2], AL            ;save units
    ADD   BYTE[DI], 30H            ;convert numbers to ASCII
    ADD   BYTE[DI + 1], 30H
    ADD   BYTE[DI + 2], 30H
    RET
;**************************************************

;*******************************************************************

;	SUBROUTINE BA16
;
;	This subroutine converts a 16 bit binary value into 5 bytes
;	of printable decimal ASCII.
;
;	ENTRY:	The 16 bit value is in register AX
;		Regster SI points to the external 5 byte buffer
;	EXIT:	The external buffer contains the 5 characters
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
