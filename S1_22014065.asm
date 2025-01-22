STAK    SEGMENT PARA STACK 'STACK' 
        DW 20 DUP(?)                      ; 20 word'lük stack alanı ayrılıyor
STAK    ENDS                            

DATA    SEGMENT PARA 'DATA'               
DIGITS  DB 0C0H, 0F9H, 0A4H, 0B0H, 99H,  ; 7-segment display için 0-9 arası sayıların kodları
        92H, 82H, 0F8H, 80H, 98H         
Deger1  DW 0                             ; Birinci display için başlangıç değeri 0
Deger2  DW 0                             ; İkinci display için başlangıç değeri 0
ActiveDisplay DW 2                       ; Aktif display'i tutan değişken (2=display1, 1=display2)
DATA    ENDS                             

CODE    SEGMENT PARA 'CODE'             
        ASSUME CS:CODE, DS:DATA, SS:STAK 

DELAY PROC NEAR                          ; Gecikme prosedürü 
        MOV CX, 0FFFH                    ; CX'e döngü sayısı yükleniyor
L1:                                      ; Gecikme döngüsü etiketi
        LOOP L1                          ; CX sıfır olana kadar döngü devam eder
        RET                              ; Prosedürden dönüş
DELAY ENDP                      

START:                                  
        MOV AX, DATA                    ; DATA segment adresini AX'e yükle
        MOV DS, AX                      ; DATA segment adresini DS'ye yükle
        MOV AL, 90H                     ; Kontrol byte'ını AL'ye yükle
        OUT 66H, AL                     ; Kontrol byte'ını 66H portuna gönder
        MOV AL, 0FFH                    ; Display'i temizlemek için FF değeri
        OUT 62H, AL                     ; Display data portuna FF değeri gönder
        MOV AL, 002H                    ; İlk display'i seç (Display 1)
        OUT 64H, AL                     ; Display seçim portuna değeri gönder

ENDLESS:   
        LEA SI, DIGITS                  ; DIGITS dizisinin adresini SI'ya yükle
        
        CMP ActiveDisplay, 2            ; Aktif display'in hangisi olduğunu kontrol et
        JE SHOW_DISPLAY1               ; Display 1 aktifse SHOW_DISPLAY1'e atla
        MOV BX, Deger2                 ; Display 2 aktifse Deger2'yi BX'e yükle
        JMP CONTINUE_DISPLAY           ; Display işlemine devam et
	
SHOW_DISPLAY1:                         ; Display 1 göster
        MOV BX, Deger1                 ; Deger1'i BX'e yükle
	
CONTINUE_DISPLAY:                  
        MOV AL, [SI + BX]              ; Gösterilecek rakamın kodunu AL'ye yükle
        OUT 62H, AL                    ; Rakam kodunu display'e gönder
        
        IN AL, 60H                     ; Buton durumunu 60H portundan oku
        
        CMP AL, 0FEH                   ; Buton 1'e basılıp basılmadığını kontrol et: 1111 1110
        JZ DUGME1_ACIK                ; Buton 1'e basıldıysa DUGME1_ACIK'a atla
        
        CMP AL, 0FDH                   ; Buton 2'ye basılıp basılmadığını kontrol et: 1111 1101
        JZ DUGME2_ACIK                ; Buton 2'ye basıldıysa DUGME2_ACIK'a atla
        
        CMP AL, 0FBH                   ; Buton 3'e basılıp basılmadığını kontrol et: 1111 1011
        JZ DUGME3_ACIK                ; Buton 3'e basıldıysa DUGME3_ACIK'a atla
        
        CMP AL, 0F7H                   ; Buton 4'e basılıp basılmadığını kontrol et: 1111 0111
        JZ DUGME4_ACIK                ; Buton 4'e basıldıysa DUGME4_ACIK'a atla
        
        JMP SON                        ; Hiçbir buton basılı değilse döngü sonuna atla

DUGME1_ACIK:                          ; Display 1 seç
        MOV AL, 002H                   ; Display 1'i seçmek için değer: 0000 0010
        OUT 64H, AL                    ; Display seçim portuna değeri gönder
        MOV ActiveDisplay, 2           ; Aktif display'i Display 1 olarak işaretle
        JMP SON                        ; Döngü sonuna atla

DUGME2_ACIK:                          ; Display 2 seç
        MOV AL, 001H                   ; Display 2'yi seçmek için değer: 0000 0001
        OUT 64H, AL                    ; Display seçim portuna değeri gönder
        MOV ActiveDisplay, 1           ; Aktif display'i Display 2 olarak işaretle
        JMP SON                        ; Döngü sonuna atla

DUGME3_ACIK:                          ; Arttır butonu
        CMP ActiveDisplay, 2           ; Hangi display'in aktif olduğunu kontrol et
        JE INC_DISPLAY1               ; Display 1 aktifse INC_DISPLAY1'e atla
        MOV BX, Deger2                ; Display 2 değerini BX'e yükle
        CMP BX, 9                     ; Değer 9'a eşit mi kontrol et
        JE SET_ZERO2                  ; 9 ise sıfıra ayarla
        INC Deger2                    ; Değilse arttır
        JMP DELAY_INC                
	
SET_ZERO2:
        MOV Deger2, 0                 ; Değeri sıfırla
        JMP DELAY_INC                ; Gecikmeye git
	
INC_DISPLAY1:                         ; Display 1 arttır
        MOV BX, Deger1                ; Display 1 değerini BX'e yükle
        CMP BX, 9                     ; Değer 9'a eşit mi kontrol et
        JE SET_ZERO1                  ; 9 ise sıfıra ayarla
        INC Deger1                    ; Değilse arttır
        JMP DELAY_INC                ; Gecikmeye git
	
SET_ZERO1:
        MOV Deger1, 0                 ; Değeri sıfırla
	
DELAY_INC:                           ; Arttırma sonrası gecikme
        CALL DELAY                    ; Gecikme prosedürünü çağır 6 kez
        CALL DELAY
        CALL DELAY
        CALL DELAY
        CALL DELAY
        CALL DELAY
        JMP SON                       ; Döngü sonuna atla

DUGME4_ACIK:                         ; Azaltma tuşu
        CMP ActiveDisplay, 2          ; Hangi display'in aktif olduğunu kontrol et
        JE DEC_DISPLAY1              ; Display 1 aktifse DEC_DISPLAY1'e atla
        MOV BX, Deger2               ; Display 2 değerini BX'e yükle
        CMP BX, 0                    ; Değer 0 mı kontrol et
        JE SET_NINE2                 ; 0 ise 9'a ayarla
        DEC Deger2                   ; Değilse azalt
        JMP DELAY_DEC               ; Gecikmeye git
	
SET_NINE2:
        MOV Deger2, 9                ; Değeri 9 yap
        JMP DELAY_DEC               ; Gecikmeye git
	
DEC_DISPLAY1:                        ; Display 1 azalt
        MOV BX, Deger1               ; Display 1 değerini BX'e yükle
        CMP BX, 0                    ; Değer 0 mı kontrol et
        JE SET_NINE1                 ; 0 ise 9'a ayarla
        DEC Deger1                   ; Değilse azalt
        JMP DELAY_DEC               ; Gecikmeye git
	
SET_NINE1:
        MOV Deger1, 9                ; Değeri 9 yap
	
DELAY_DEC:                          ; Azaltma sonrası gecikme
        CALL DELAY                   ; Gecikme prosedürünü çağır (6 kez)
        CALL DELAY
        CALL DELAY
        CALL DELAY
        CALL DELAY
        CALL DELAY
        JMP SON                      ; Döngü sonuna atla

SON:                                ; Döngü sonu
        CALL DELAY                   ; Son bir gecikme çağrısı
        JMP ENDLESS                  ; Sonsuz döngüye geri dön

CODE    ENDS             
        END START                 