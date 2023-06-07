;
; LAB 1_2.2.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 11:42:44 AM
; 
;
; Dung chuong trinh con Delay1s viet chuong trinh chop/tat 1 LED gan vao PA0.

.ORG 0
	        RJMP MAIN
	        .ORG 0X40
MAIN:
		LDI R16, HIGH(RAMEND)
		OUT SPH, R16
		LDI R16, LOW(RAMEND)
	        OUT SPL, R16 ; dua stack len vung dia chi cao

	        SBI DDRA, 0 ; khai bao PA0 OUTPUT
LOOP: 
		SBI PORTA, 0 ; TAO XUNG MUC CAO CUA XUNG VUONG
		RCALL Delay1s

	        CBI PORTA, 0 ; TAO XUNG MUC THAP CUA XUNG VUONG
	        RCALL Delay1s

	        RJMP LOOP



;-----------------------------------------------------
Delay500us: 
            LDI R20, 124
LPA:       
            NOP
            DEC R20
	    BRNE LPA
	    RET

;-----------------------------------------------------
Delay1ms: 
                RCALL Delay500us
                RCALL Delay500us
		RET

;-----------------------------------------------------
Delay10ms: 
                LDI R21, 10
LPB:       
                RCALL Delay1ms
		DEC R21
		BRNE LPB
		RET

;-----------------------------------------------------
Delay100ms: 
                LDI R21, 100
LPC:      
                RCALL Delay1ms
		DEC R21
		BRNE LPC
		RET

;-----------------------------------------------------
Delay1s: 
                LDI R22, 4
LP2:	 
                LDI R21, 250
LP1:     
                RCALL Delay1ms
		DEC R21
		BRNE LP1
		DEC R22
		BRNE LP2
		RET
