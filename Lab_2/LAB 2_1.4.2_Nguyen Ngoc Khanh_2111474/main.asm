;
; LAB 2_1.4.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 1:46:17 PM
; 
;
; ket noi OC0B vao kenh R cua led RGB. Viet chuong trinh de tang duty cycle cua OC0B tu 0% len 100% roi lai giam xuong 0, sau 10ms duty cycle tang/giam 1%

        .DEF SIGN_H = R19
	.DEF SIGN_L = R20
	.ORG 0
	RJMP MAIN
	.ORG 0X40 ; dua chuong trinh ra khoi vung interrupts
MAIN:
	LDI R22, 2 ; So lan lap 
	LDI R23, 10 ; 10ms
	LDI R24, 0 ; Tang 1%
	CLR R25 ; Change rule

	LDI SIGN_H, 0
	LDI SIGN_L, 125

	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	LDI R16, HIGH(RAMEND)
	OUT SPL, R16 ; dua stack len vung dia chi cao

	SBI DDRB, 4 ; OC0B is output
	LDI R16, (1 << WGM01) ; Mode CTC dao bit OC0B khi dat ket qua so sanh
	OUT TCCR0A, R16
START:
	RCALL CHANGE 
	RJMP START


;----------------------------------------------------------------------------
CHANGE:
	MOV R16, SIGN_H ; Gia tri khoi dong
WAVE_B:
	OUT OCR0A, R16 ; Nap gia tri cho bo dem
	LDI R16, (1 << CS01)|(1 << CS00) ; Mode CTC va Prescaler = 64
	OUT TCCR0B, R16
WAIT_B_H:
	SBI PORTB, 4
	IN R17, TIFR0 ; Doc gia tri thanh ghi bao tran
	SBRS R17, OCF0A ; Kiem tra co bao tran
	RJMP WAIT_B_H ; Chua tran tiep tuc dem
	OUT TIFR0, R17 ; Xoa co tran
	MOV R16, SIGN_L
	OUT OCR0A, R16
WAIT_B_L:
	CBI PORTB, 4
	IN R17, TIFR0 ; Doc gia tri thanh ghi bao tran
	SBRS R17, OCF0A ; Kiem tra co bao tran
	RJMP WAIT_B_L ; Chua tran tiep tuc dem
	OUT TIFR0, R17 ; Xoa co tran
	DEC R23
	BRNE AGAIN
	LDI R23, 10
	INC R24
	CPI R24, 100 ; Khi duty dat 100%
	BREQ CHANGE_RULE ; Thay doi viec cong tru cac thanh ghi
                         ; Co bit0 cua R25 = 0 tang dutycycle tu 0 --> 100
CONTI:
	SBRC R25, 0 ; Neu bang 1 giam dutycycle
	RJMP CHANGE_VALUE
	INC SIGN_H
	DEC SIGN_L
	RJMP AGAIN
CHANGE_RULE:
	CLR R24
	LDI R26, 0X01
	EOR  R25, R26
	RJMP CONTI
CHANGE_VALUE:
	DEC SIGN_H
	INC SIGN_L
AGAIN:
	OUT OCR0A, SIGN_H
	RJMP WAIT_B_H
	RET
CAU_A:
	LDI ZH, HIGH(DATA_A << 1)
	LDI ZL, LOW(DATA_A << 1)
	LDI R16, 20 ; Gia tri khoi dong
WAVE_A:
	OUT OCR0A, R16 ; Nap gia tri cho bo dem
	LDI R16, (1 << CS01)|(1 << CS00) ; Mode CTC va Prescaler = 64
	OUT TCCR0B, R16
WAIT_A:
	IN R17, TIFR0 ; Doc gia tri thanh ghi bao tran
	SBRS R17, OCF0A ; Kiem tra co bao tran
	RJMP WAIT_A ; Chua tran tiep tuc dem
	OUT TIFR0, R17 ; Xoa co tran
	LPM R16, Z+
	OUT OCR0A, R16
	DEC R22
	BRNE WAIT_A
	LDI R22, 2
	LDI ZH, HIGH(DATA_A << 1)
	LDI ZL, LOW(DATA_A << 1)
	RJMP WAIT_A
	RET
DATA_A:
	.DB 92, 30

