;
; LAB 3_1.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 3:51:52 PM
; 
;
; Ket noi chan TxD va RxD cua UART0 vao tin hieu UART_TxD0 va UART_RxD0 tren header J85 o khoi UART
; ket noi day USB - Serial vao kit thi nghiem
; Setup chuong trinh Hercules voi baudrate 9600, 8 bit data, no parity, 1 stop, no handshake
; Viet chuong trinh khoi dong UART0 voi cac thong so nhu tren, cho nhan 1 byte tu UART0 va phat nguoc lai UART0
; Dung Hercules truyen 1 ki tu xuong kit va quan sat cac du lieu nhan duoc

; PORTA KET NOI VOI BARLED DE KIEM TRA MA HEX CUA KI TU NHAN DUOC TU HERCULES

                .DEF DATA_REC = R20
		.DEF DATA_TRANS = R21
		.ORG 0
		RJMP MAIN
		.ORG 0X40 ; THOAT KHOI VUNG INTERRUPTS
MAIN:	
	
		LDI R16, HIGH(RAMEND)
		OUT SPH, R16
		LDI R16, LOW(RAMEND) ; DUA STACK LEN VUNG DIA CHI CAO
		OUT SPL, R16

		LDI R16, 0XFF
		OUT DDRA, R16

		RCALL USART_INIT
START:	
		RCALL USART_REC
		MOV DATA_TRANS, DATA_REC
		MOV R19, DATA_REC
		OUT PORTA, R19 ; XUAT KI TU NHAN DUOC TU HERCULES RA PORTA
		RCALL USART_TRANS
		RJMP START

;------------------------------------------------------------------------
USART_INIT:
		LDI R16, (1 << TXEN0)|(1 << RXEN0) ; CHO PHEP BO PHAT/THU
		STS UCSR0B,R16

		LDI R16, (1 << UCSZ01)|(1 << UCSZ00) ; 8 BIT DATA/KHONG KT CHAN LE/1 STOP BIT
		STS UCSR0C,R16

		LDI R16, 0
		STS UBRR0H, R16
		LDI R16, 51 ; BAUD RATE = 9600 UNG VOI FOSC = 8MHZ
		STS UBRR0L, R16
		
		RET

USART_TRANS:
		LDS R17, UCSR0A
		SBRS R17, UDRE0 ; KIEM TRA UDR0 CO TRONG KHONG (UDRE0 = 1?)
		RJMP USART_TRANS
		STS UDR0, DATA_TRANS ; KHI UDR0 TRONG THI CHEP DU LIEU TU THANH GHI DATA_TRANS CHAN GUI LEN HERCULES VAO UDR0
		RET

USART_REC:
		LDS R17, UCSR0A
		SBRS R17, RXC0
		RJMP USART_REC
		LDS DATA_REC, UDR0 ; NAP DU LIEU TU UDR0 VAO DATA_REC
		RET
