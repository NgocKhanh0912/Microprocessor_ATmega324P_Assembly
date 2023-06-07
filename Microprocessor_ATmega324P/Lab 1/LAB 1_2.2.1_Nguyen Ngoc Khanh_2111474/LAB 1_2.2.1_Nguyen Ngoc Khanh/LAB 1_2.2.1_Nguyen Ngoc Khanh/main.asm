;
; LAB 1_2.2.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 11:41:31 AM
; 
;
; Viet chuong trinh con Delay1ms va dung no de viet chuong trinh tao xung vuong tan so 1Khz tren PA0.
; Dung chuong trinh con nay viet cac chuong trinh con Delay10ms, Delay100ms, Delay1s.


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
		RCALL Delay500us

	        CBI PORTA, 0 ; TAO XUNG MUC THAP CUA XUNG VUONG
	        RCALL Delay500us

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
