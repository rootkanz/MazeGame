ORG 100h
JMP start

; ==========================================
; VERÝ BÖLÜMÜ (DATA SEGMENT)
; Programda kullanýlacak tüm deðiþkenler, mesajlar ve matrisler burada tanýmlanýr.
; ==========================================

map_ptr    DW ?      ; Seçilen haritanýn bellekteki baþlangýç adresini (iþaretçisini) tutar
map_width  DW ?      ; Seçilen haritanýn satýr geniþliðini tutar (Matematiksel hesap için)
map_size   DW ?      ; Seçilen haritanýn toplam karakter sayýsýný tutar (Çizim döngüsü için)
time_limit DW ?      ; Seçilen zorluða göre oyunun kaç saniye süreceðini tutar
start_time DW ?      ; Oyun baþladýðý andaki sistem saati deðerini (Tick) kaydeder

player_x   DW 1      ; Oyuncunun X (Sütun) koordinatý (16-bit)
player_y   DW 1      ; Oyuncunun Y (Satýr) koordinatý (16-bit)

; --- Kullanýcý Arayüzü Mesajlarý (13 = Satýr baþý(CR), 10 = Alt satýr(LF), $ = String sonu) ---
msg_menu DB 'ZORLASTIRILMIS LABIRENT SECIN:', 13, 10
         DB '1 - Kolay (20x20 - 60 Saniye)', 13, 10
         DB '2 - Orta  (22x22 - 90 Saniye)', 13, 10
         DB '3 - Zor   (24x24 - 120 Saniye)', 13, 10
         DB 'Seciminiz: $'

msg_win  DB 13, 10, 'TEBRIKLER! Labirenti cozdunuz!$'
msg_lose DB 13, 10, 'SURE DOLDU! Kaybettiniz.$'

; --- HARÝTA 1: KOLAY (20x20) ---
map1 DB '####################'
     DB '#@#    #           #'
     DB '# #  # # ######### #'
     DB '#    #   #         #'
     DB '### ###### ####### #'
     DB '#   #    # #       #'
     DB '# # # ## # # ##### #'
     DB '# #   #  #   #   # #'
     DB '# ###### ##### ### #'
     DB '#      #   #     # #'
     DB '###### # ### ##### #'
     DB '#    # # #   #   # #'
     DB '# #### # # ### # # #'
     DB '# #      # #   # # #'
     DB '# # ## ### # ### # #'
     DB '#   #      #   #   #'
     DB '##### ######## ### #'
     DB '#     #        #   #'
     DB '# ##### ######## #E#'
     DB '####################'

; --- HARÝTA 2: ORTA (22x22) ---
map2 DB '######################'
     DB '#@#        #     #   #'
     DB '# # ###### # ### # # #'
     DB '#   #    #   # #   # #'
     DB '##### ## ####### ### #'
     DB '#     ##     #     # #'
     DB '# ######### ### #### #'
     DB '# #   #     #   #    #'
     DB '# # # # ##### ###### #'
     DB '#   #   #   # #      #'
     DB '##### ### # # # ######'
     DB '#     #   #   # #    #'
     DB '# ####### ##### # ## #'
     DB '# #     # #       #  #'
     DB '# # ### # # # ###### #'
     DB '#   #   #   #   #    #'
     DB '##### ##### ### # ####'
     DB '#   # #   # #   #    #'
     DB '# # # # # # # ###### #'
     DB '# #     # #   # #    #'
     DB '# ####### ##### # #E #'
     DB '######################'

; --- HARÝTA 3: ZOR (24x24) ---
map3 DB '########################'
     DB '#@#    #     #     #   #'
     DB '# # ## # ### # ###   # #'
     DB '#   ##   # # # # # # # #'
     DB '### ###### # # # # # # #'
     DB '#   #      #   #   #   #'
     DB '# # # ###### ##### # ###'
     DB '# #   #    # #   # # # #'
     DB '# ###### # # # # # # # #'
     DB '#      # #     #   #   #'
     DB '###### # ####### ##### #'
     DB '#    # # #     #     # #'
     DB '# ## # # # ### ##### # #'
     DB '# #  # # # # # #   # # #'
     DB '# # ## # # # # # # # # #'
     DB '#      # # # #   # # # #'
     DB '# ###### # # ##### # # #'
     DB '#      # #         # # #'
     DB '###### # ### ##### # # #'
     DB '#    # # #       # # # #'
     DB '# ## # # # ##### # # # #'
     DB '# #        # #       # #'
     DB '# ###### ### #########E#'
     DB '########################'

; ==========================================
; KOD BÖLÜMÜ (CODE SEGMENT)
; ==========================================
start:
    CALL clear_screen       ; Önceki yazýlarý temizle
    MOV DX, OFFSET msg_menu ; Ekrana basýlacak menü mesajýnýn bellek adresini al
    MOV AH, 09h             ; DOS INT 21h, AH=09h -> String yazdýrma servisi
    INT 21h                 ; Mesajý ekrana bas
    
wait_menu:
    MOV AH, 00h             ; BIOS INT 16h, AH=00h -> Tuþ basýlmasýný bekle ve oku
    INT 16h
    
    ; Basýlan tuþun (AL yazmacý) ASCII karþýlýðýný kontrol et
    CMP AL, '1'
    JE set_easy             ; 1'e basýldýysa Kolay ayarlara atla
    CMP AL, '2'
    JE set_medium           ; 2'ye basýldýysa Orta ayarlara atla
    CMP AL, '3'
    JE set_hard             ; 3'e basýldýysa Zor ayarlara atla
    CMP AL, 27              ; 27 = ESC tuþunun ASCII kodu
    JE exit_direct          ; ESC'ye basýldýysa oyundan çýk
    JMP wait_menu           ; Geçersiz bir tuþsa tekrar bekle

; --- SEVÝYE AYARLARI ---
set_easy:
    MOV map_ptr, OFFSET map1 ; Harita dizisinin baþlangýç adresini kaydet
    MOV map_width, 20        ; Geniþlik 20 karakter
    MOV map_size, 400        ; Toplam alan 20x20 = 400 karakter
    MOV time_limit, 60       ; Süre 60 saniye
    JMP init_game

set_medium:
    MOV map_ptr, OFFSET map2
    MOV map_width, 22
    MOV map_size, 484
    MOV time_limit, 90
    JMP init_game

set_hard:
    MOV map_ptr, OFFSET map3
    MOV map_width, 24
    MOV map_size, 576
    MOV time_limit, 120
    JMP init_game

init_game:
    ; Yeni oyuna baþlarken oyuncunun baþlangýç noktasýný sýfýrla
    MOV player_x, 1
    MOV player_y, 1

    CALL clear_screen       ; Ekraný temizle
    CALL draw_map           ; Seçilen haritayý ekrana çizdir
    
    ; Sistemin anlýk saat bilgisini "Tick" (saniyenin 1/18'i) cinsinden al
    MOV AH, 00h             ; BIOS INT 1Ah, AH=00h -> Sistem saatini oku
    INT 1Ah                 ; DX yazmacýna anlýk Tick deðeri gelir
    MOV start_time, DX      ; Oyunun baþladýðý Tick deðerini kaydet

; ==========================================
; OYUNUN ANA DÖNGÜSÜ (GAME LOOP)
; ==========================================
game_loop:
    ; --- 1. SÜRE KONTROLÜ ---
    MOV AH, 00h
    INT 1Ah                 ; Tekrar anlýk saati al (DX'e)
    MOV AX, DX              ; AX = Anlýk saat
    SUB AX, start_time      ; AX = Geçen süre (Anlýk saat - Baþlangýç saati) (Tick cinsinden)
    
    MOV CX, 18              ; 1 Saniye yaklaþýk 18 Tick'tir
    XOR DX, DX              ; Bölme iþleminden önce DX sýfýrlanmalýdýr (DX:AX / CX)
    DIV CX                  ; AX = Geçen Süre / 18 -> AX artýk 'Saniye' cinsinden geçen süredir
    
    CMP AX, time_limit      ; Geçen saniye (AX), belirlenen sýnýra (time_limit) ulaþtý mý?
    JGE time_out            ; Süre eþit veya büyükse (JGE), time_out (Kaybetme) etiketine atla
    
    ; --- 2. KLAVYE KONTROLÜ (ASENKRON / NON-BLOCKING) ---
    MOV AH, 01h             ; BIOS INT 16h, AH=01h -> Tuþa basýldý mý diye klavye tamponunu kontrol et
    INT 16h                 ; Bu iþlem programý durdurmaz! (Sürenin akmasý için önemli)
    JZ game_loop            ; Eðer tuþa basýlmadýysa (Zero Flag=1), oyun döngüsünün baþýna dön
    
    MOV AH, 00h             ; Tuþa basýldýðýný anladýk, þimdi o tuþu okuyup tampondan sil
    INT 16h                 ; Basýlan tuþun ASCII kodu AL yazmacýna gelir
    
    ; Geçici yazmaçlara oyuncunun mevcut konumunu al (Çarpýþma hesabý için)
    MOV SI, player_x        ; SI = Hedef X
    MOV DI, player_y        ; DI = Hedef Y

    ; Basýlan tuþa göre hedef X(SI) veya Y(DI) deðerini deðiþtir
    CMP AL, 'w'
    JE move_up
    CMP AL, 'W'
    JE move_up
    CMP AL, 's'
    JE move_down
    CMP AL, 'S'
    JE move_down
    CMP AL, 'a'
    JE move_left
    CMP AL, 'A'
    JE move_left
    CMP AL, 'd'
    JE move_right
    CMP AL, 'D'
    JE move_right
    CMP AL, 27              ; ESC tuþuna basýldýysa
    JE start                ; Menüye (start) geri dön
    JMP game_loop           ; Geçersiz tuþsa döngüye dön

; Yön tuþlarýna göre hedef koordinatlarýn ayarlanmasý
move_up:
    DEC DI                  ; Yukarý gitmek Y(DI) deðerini 1 azaltmaktýr
    JMP check_col
move_down:
    INC DI                  ; Aþaðý gitmek Y(DI) deðerini 1 artýrmaktýr
    JMP check_col
move_left:
    DEC SI                  ; Sola gitmek X(SI) deðerini 1 azaltmaktýr
    JMP check_col
move_right:
    INC SI                  ; Saða gitmek X(SI) deðerini 1 artýrmaktýr
    JMP check_col

; --- 3. ÇARPIÞMA KONTROLÜ VE HAREKET ---
check_col:
    ; Bellekteki tek boyutlu dizide X ve Y'nin konumunu bulma formülü: Ofset = (Y * Geniþlik) + X
    MOV AX, DI              ; AX'e hedef Y'yi koy
    MUL map_width           ; AX = Y * Geniþlik
    ADD AX, SI              ; AX = (Y * Geniþlik) + Hedef X (Dizideki sýrasý)
    
    MOV BX, map_ptr         ; BX = Haritanýn bellekteki baþlangýç adresi
    ADD BX, AX              ; BX = Baþlangýç adresi + Ofset -> Tam olarak bakacaðýmýz karakterin adresi
    MOV AL, [BX]            ; AL = O adresteki karakteri al ('#', ' ', veya 'E')
    
    CMP AL, '#'             ; Hedefte duvar ('#') var mý?
    JE game_loop            ; Duvar varsa, hiçbir þey yapmadan döngüye dön (Hareketi iptal et)
    
    CMP AL, 'E'             ; Hedefte Çýkýþ ('E') var mý?
    JE win_game             ; Çýkýþsa kazanma ekranýna atla
    
    ; Eðer duvar deðilse, hareket geçerlidir. Karakteri yeni yerine çiz:
    CALL erase_player       ; Ekrandaki eski konumuna boþluk (' ') bas
    MOV player_x, SI        ; Karakterin X konumunu kalýcý olarak yeni X(SI) ile deðiþtir
    MOV player_y, DI        ; Karakterin Y konumunu kalýcý olarak yeni Y(DI) ile deðiþtir
    CALL draw_player        ; Ekrandaki yeni konumuna '@' bas
    JMP game_loop           ; Bir sonraki tuþ/süre için döngüye dön

; ==========================================
; OYUN SONU DURUMLARI (KAZANMA/KAYBETME)
; ==========================================
win_game:
    ; Kazanýldýðýnda karakteri son E harfinin üzerine çizmek için:
    CALL erase_player
    MOV player_x, SI
    MOV player_y, DI
    CALL draw_player
    
    MOV DX, OFFSET msg_win  ; Kazanma mesajýný al
    MOV AH, 09h             ; String yazdýrma servisi
    INT 21h                 ; Ekrana bas
    JMP game_over_wait      ; Bekleme ekranýna geç

time_out:
    CALL clear_screen       ; Ekraný temizle
    MOV DX, OFFSET msg_lose ; Kaybetme (Süre doldu) mesajýný al
    MOV AH, 09h
    INT 21h                 ; Ekrana bas

game_over_wait:
    MOV AH, 00h             ; Kullanýcýnýn bir tuþa basmasýný bekle (Sonuçlarý okuyabilsin diye)
    INT 16h
    JMP start               ; Tuþa basýlýnca ana menüye (start) geri dön

exit_direct:
    MOV AH, 4Ch             ; DOS INT 21h, AH=4Ch -> Programý donaným belleðinden sil ve sonlandýr
    INT 21h

; ==========================================
; GRAFÝK VE EKRAN PROSEDÜRLERÝ (ALT PROGRAMLAR)
; ==========================================

erase_player:
    ; Oyuncunun bulunduðu X(DL) ve Y(DH) koordinatýna boþluk (' ') yazar
    MOV DX, player_x        ; DL = X koordinatý
    MOV AX, player_y
    MOV DH, AL              ; DH = Y koordinatý
    CALL set_cursor         ; Ýmleci o noktaya taþý
    MOV AL, ' '             ; Yazýlacak karakter boþluk
    MOV AH, 0Eh             ; BIOS INT 10h, AH=0Eh -> Ekrana tek karakter basma servisi
    INT 10h
    RET                     ; Alt programdan çýk (Çaðrýldýðý yere dön)

draw_player:
    ; Oyuncunun bulunduðu X ve Y koordinatýna '@' yazar
    MOV DX, player_x        
    MOV AX, player_y
    MOV DH, AL              
    CALL set_cursor         
    MOV AL, '@'             ; Yazýlacak karakter @
    MOV AH, 0Eh
    INT 10h
    RET

set_cursor:
    ; BIOS video servisi ile imleci (cursor) DH(Satýr) ve DL(Sütun) konumuna götürür
    MOV AH, 02h             ; BIOS INT 10h, AH=02h -> Ýmleç pozisyonu ayarlama
    MOV BH, 00h             ; Video sayfa numarasý (Genelde 0'dýr)
    INT 10h
    RET

clear_screen:
    ; Ekraný tamamen temizler ve siyah arkaplan/beyaz yazý ayarlar
    MOV AX, 0600h           ; AH=06h (Ekraný yukarý kaydýr/temizle), AL=00h (Tüm ekran)
    MOV BH, 07h             ; 07h = Siyah arkaplan, Açýk gri (standart) metin rengi
    MOV CX, 0000h           ; Ekranýn sol üst köþesi (X=0, Y=0)
    MOV DX, 184Fh           ; Ekranýn sað alt köþesi (Satýr 24=18h, Sütun 79=4Fh)
    INT 10h
    
    ; Temizledikten sonra imleci 0,0 noktasýna geri al
    MOV DL, 0
    MOV DH, 0
    CALL set_cursor
    RET

draw_map:
    ; Seçili haritayý hücre hücre ekrana çizer
    MOV CX, 0               ; CX döngü sayacýdýr, 0'dan baþlar
draw_loop_start:
    ; Tek boyutlu sýradan X ve Y koordinatýný çýkarma iþlemi
    MOV AX, CX              ; AX = Geçerli karakterin sýrasý
    XOR DX, DX              ; Bölme için DX sýfýrlanýr
    MOV BX, map_width       
    DIV BX                  ; AX / Geniþlik -> Bölüm(AX) = Y(Satýr), Kalan(DX) = X(Sütun)
    
    MOV DH, AL              ; Ýmleç Y pozisyonu (Bölüm)
    ; DL zaten X pozisyonunu (Kalan) içeriyor
    CALL set_cursor         ; Ýmleci bu koordinata taþý
    
    ; Haritadan o sýradaki karakteri oku
    MOV BX, map_ptr         ; Haritanýn bellek adresi
    ADD BX, CX              ; Bellek adresi + Þu anki adým(CX)
    MOV AL, [BX]            ; Karakteri AL'ye al
    
    PUSH CX                 ; CX deðerini yýðýna(stack) at koru (Çünkü INT 10h CX'i bozabilir)
    MOV AH, 0Eh             ; Karakteri ekrana bas
    INT 10h
    POP CX                  ; CX'i yýðýndan geri al
    
    INC CX                  ; Bir sonraki karaktere geç (CX'i 1 artýr)
    CMP CX, map_size        ; Toplam karakter sayýsýna ulaþtýk mý?
    JL draw_loop_start      ; Küçüksen (JL) çizmeye devam et, döngü baþýna dön
    RET                     ; Çizim bitti, geri dön

END