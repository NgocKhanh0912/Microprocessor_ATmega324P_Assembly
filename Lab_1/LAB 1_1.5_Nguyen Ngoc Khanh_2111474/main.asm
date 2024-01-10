;
; LAB 1_1.5_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 12:38:30 AM
; 
;
; Ket noi PA0 vao 1 Switch don va PA1 vao 1 LED don tren khoi LED (luu y la cung 1 Port)
; Viet chuong trinh bat LED neu SW nhan, tat LED neu SW nha.

; PA0 NOI VOI SWITCH DON
; PA1 NOI VOI LED DON

	  .ORG 0
	  RJMP MAIN
	  .ORG 0X40 ; dua chuong trinh ra khoi vung interrupts
MAIN: 
	  LDI R16, HIGH(RAMEND)
	  OUT SPH, R16
	  LDI R16, LOW(RAMEND)
	  OUT SPL, R16 ; dua stack len vung dia chi cao

	  SBI DDRA, 1 ; PA1 LA CHAN XUAT RA LED
	  CBI DDRA, 0 ; PA0 LA CHAN DOC SWITCH
	  SBI PORTA, 0 ; PULLUP R PA0
	  CBI PORTA, 1 ; PA1 BAN DAU = 0 (LED KHONG SANG)

LED_ON:
	  SBIC PINA, 0 ; BO QUA LENH TIEP THEO NEU SW DUOC NHAN
	  RJMP LED_OFF
	  SBI PORTA, 1 ; SW DUOC NHAN, LED SANG
	  RCALL DL10ms
	  RJMP LED_ON
LED_OFF:
	  SBIS PINA, 0 ; BO QUA LENH TIEP THEO NEU SW DUOC NHA
	  RJMP LED_ON
	  CBI PORTA, 1 ; SW NHA, LED TAT
	  RCALL DL10ms
	  RJMP LED_OFF
	 

;----------------------------------------------------------------
DL10ms: 
                LDI R21, 10 ; m = 10
LP2:    
                LDI R20, 250 ; n = 250
LP1:    
                NOP
                DEC R20   ; tdl = 4mn
		BRNE LP1  ; CKDIV = 0 , F = 1MHz
		DEC R21
		BRNE LP2
		RET
