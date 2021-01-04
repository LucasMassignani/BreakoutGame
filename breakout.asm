.model small     
      
.stack 100H

.data  

    tela_menu   db '  __   __   ___            __       ___ '
                db ' |__) |__) |__   /\  |__/ /  \ |  |  |  '
                db ' |__) |  \ |___ /~~\ |  \ \__/ \__/  |  '
    nome        db '                 Lucas                  '
    opcoes_menu db '                 Jogar                  '
                db '                 Sair                   '
                
    tela_fim_jogo   db '         ______  _____ ___  ___         '
                    db '         |  ___||_   _||  \/  |         '
                    db '         | |_     | |  | .  . |         '
                    db '         |  _|    | |  | |\/| |         '
                    db '         | |     _| |_ | |  | |         '
                    db '         \_|     \___/ \_|  |_/         '
                    db '                                        '
                    db '         ______  _____                  '
                    db '         |  _  \|  ___|                 '
                    db '         | | | || |__                   '
                    db '         | | | ||  __|                  '
                    db '         | |/ / | |___                  '
                    db '         |___/  \____/                  '
                    db '                                        '
                    db '            ___  _____  _____  _____    '
                    db '           |_  ||  _  ||  __ \|  _  |   '
                    db '             | || | | || |  \/| | | |   '
                    db '             | || | | || | __ | | | |   '
                    db '         /\__/ /\ \_/ /| |_\ \\ \_/ /   '
                    db '         \____/  \___/  \____/ \___/    '
            
                
    menu_jogo_score db 'Score: '
    menu_jogo_vidas db 'Vidas: '
    
    vidas  dw 0 ;Inicia o jogo com 3        
    pontos dw 0
    blocos_destruidos_dec_vel db 4 ; Quando chega em zero decrementa velocidade e volta pra 4
    ganhou_jogo db 24 ; Quantidade de blocos destruidos para ganhar      
    
    contador_bola db 0      ;Quando contador_bola for == contador_bola_fim, bola move
    contador_bola_fim db 0 
    
    bola_x db 0
    bola_y db 0
    velocidade_x db 1
    velocidade_y db 1
    
    raquete_x db 0
    
    blocos_vermelhos_x db 1, 7, 13, 19, 25, 31
    blocos_vermelhos_claro_x db 1, 7, 13, 19, 25, 31
    blocos_verde_x db 1, 7, 13, 19, 25, 31
    blocos_amarelo_x db 1, 7, 13, 19, 25, 31
   
 
.code    
    ; proc que retorna em dl um numero aletorio entre 0 e 9
    rand_num_0_9 proc
        push ax
        push cx
        
        mov ah, 00h  ; interrupts to get system time        
        int 1ah      ; CX:DX now hold number of clock ticks since midnight      

        mov  ax, dx
        xor  dx, dx
        mov  cx, 10    
        div  cx       ; here dx contains the remainder of the division - from 0 to 9
        
        pop cx
        pop ax
        ret
    endp
    
    ;Fazer proc que valida se ? par 
    
    delay proc  
        push cx
        push dx
        push ax
        
        xor cx, cx
        mov dx, 0C350h ; parte alta dos  50000 microsegundos 
        mov ah, 86h
        int 15h
        
        pop ax
        pop dx
        pop cx
        ret
    delay endp 

    ;Proc que escreve string 
    ;Var armazenada em SI
    ;Na posicao da memoria DI
    ;Cor de fundo-letra em AH - cor de fundo - cor da letra
    ;Quantidade de caracteres em CX
    ;Nao mantem o valor de DI
    esc_string_mem proc
       push bx
       push es
        
       mov bx,0B800h
       mov es,bx      
       loop_string:       
            lodsb               ; Load byte at address DS:(E)SI into AL 
            mov es:[di],al      ; escreve caracter
            inc di              ; move proxima coluna
            mov es:[di],ah      ; escreve atributo
            inc di
            
            loop loop_string  
        
        pop es
        pop bx
        
        ret
    endp 
    
    ;Proc que escreve Char 
    ;Na posicao da memoria DI  
    ;Caractere armazenada em BL
    ;Cor de fundo-letra em BH - cor de fundo - cor da letra
    esc_char_mem proc
       push es
        
       mov ax, 0B800h
       mov es, ax                      
         
       mov es:[di],bl      
       inc di           
       mov es:[di],bh    
       inc di
        
       pop es
       ret
    endp
    
    ; Escreve Char
    ; Posicao X = DL
    ; Posicao Y = DH  
    ; Caractere = AL
    ; Cor do caractere = BL
    esc_char proc
        push bx
        push ax
        push cx
        push di
        push dx
        
        mov bh, bl ; MOVE COR CARACTERE PARA BH
        mov bl, al ; MOVE CARACTERE PARA BL
        
        
        xor cx, cx
        mov cl, dl ; CX = X 
        
        xor ax, ax 
        mov al, dh ; AX = Y
        
        mov dx, 40 ; WIDTH
        mul dx
        
        add ax, cx ; SOMA RESPOSTA COM X
        
        mov dx, 2
        mul dx
        
        mov di, ax
        call esc_char_mem

        pop dx
        pop di
        pop cx
        pop ax
        pop bx
       ret
    endp
    
    ; Escreve numero armazenado em AX
    ; Na posicao da memoria DI 
    esc_numero_verde proc
        push AX
        push BX
        push CX
        push DX 
        
        mov BX, 10
        xor CX, CX
        
    LACO_DIGITO:
        xor DX, DX ; Zera o DX
        ;1) Obter o resto e quociente da divisao inteira por 10
        div BX
        
        ;2) Empilha o resto
        push DX
             
        ;3) Incrementar contador de digitos
        inc CX
        
        ;4) Se queociente > 0, entao ir para 1
        cmp AX, 0
        jnz LACO_DIGITO
        
    LACO_ESCRITA:
        ;Proc que escreve Char 
        
        ;5) Recupera o resto da memoria temporaria
        pop DX
        
        ;6) Converter o resto (digito) para caractere
        add DL, '0'
        mov BL, DL
        mov BH, 02h 
        
        ;7) Escrever caracter na tela
        call esc_char_mem
        
    
        ;8) Decrementar e se for 0 vai para passo 5
        loop LACO_ESCRITA ; dec CX - jnz <rotulo>
                 
        pop DX
        pop CX
        pop BX
        pop AX 
        
        ret
    endp
    
    zera_tela proc
        push ax
        push es
        push cx
        
        mov ax,0B800H
        mov es,ax
        xor di,di
        mov ah,000H     ; cor de fundo - cor do caractere
        mov al," "      ; caracter
        mov cx,1000     ; quantidade de vezes que deve escrever
        cld             
        rep stosw       ; escreve caracter em ES:[DI]
        
        pop ax
        pop es
        pop cx
        
        ret
    endp     
    
    fim_jogo proc
        push di
        push ax
        push si
        push cx
        
        call zera_tela
        
        xor di, di                                                  
        
        mov ah, 0FH                  ; cor de fundo - cor do caractere
        mov si, OFFSET tela_fim_jogo ; DX:SI aponta para a string
        mov di, 160 ; Pula 2 Linhas
        mov cx, 800  
        call esc_string_mem 
        
        mov ah,1
        int 21h
        
        pop cx
        pop si
        pop ax
        pop di
        ret
    endp
    
    desenhar_menu_jogo proc
        mov ah, 0FH ; cor de fundo - cor do caractere
        mov si, OFFSET menu_jogo_score ; DX:SI aponta para a string
        mov di, 2
        mov cx, 7  
        call esc_string_mem
        
        mov ax, pontos
        call esc_numero_verde

        mov ah, 0FH ; cor de fundo - cor do caractere
        mov si, OFFSET menu_jogo_vidas ; DX:SI aponta para a string
        mov di, 60
        mov cx, 7
        call esc_string_mem
        
        mov ax, vidas
        call esc_numero_verde
        
        ret
    endp
    
    ;Desenha a bola
    ;Posicao x = bola_x
    ;Posicao y = bola_y
    desenha_bola proc
        push dx
        push ax
        push bx
        
        mov dl, bola_x ; x
        mov dh, bola_y ; y
        mov al, 254    ; caractere (BOLA)
        mov bl, 0fh    ; cor do caractere
        call esc_char
        
        pop bx
        pop ax
        pop dx
        ret
    endp
    
    reset_bola proc
        push dx
        push ax
        
        mov al, 10
        call rand_num_0_9
        add al, dl
        call rand_num_0_9
        add al, dl
  
        mov raquete_x, al
        add al, 2
        mov bola_x, al
        mov bola_y, 21   
        mov velocidade_x, 1
        mov velocidade_y, 1
        
        pop ax
        pop dx
        ret
    endp
    
    ;Recebe em di a variavel para reset
    loop_reset_bloco_proc proc
        push cx 
        push di   
        push ax
        
        mov ch, 6
        mov al, 1
        loop_reset_blocos:
            stosb
            add al, 6
            dec ch
            jnz loop_reset_blocos
       
        pop ax
        pop di
        pop cx
        ret
    endp
    
    reset_bloco proc
        push di
        mov di, OFFSET blocos_vermelhos_x ; ES:DI aponta para os numeros
        call loop_reset_bloco_proc
        mov di, OFFSET blocos_vermelhos_claro_x ; ES:DI aponta para os numeros
        call loop_reset_bloco_proc
        mov di, OFFSET blocos_verde_x ; ES:DI aponta para os numeros
        call loop_reset_bloco_proc
        mov di, OFFSET blocos_amarelo_x ; ES:DI aponta para os numeros
        call loop_reset_bloco_proc
        
        pop di    
        ret
    endp
    
    decrementar_vida proc
        dec vidas
        cmp vidas, 0
        jne fim_drementar_vida
        call fim_jogo
        call menu
        fim_drementar_vida: 
            call reset_bola
       
        ret
    endp
    
    mover_raquete proc
        push ax
        mov ah, 01h
        int 16h
         
        jz fim_mover_raquete
        
        mov ah, 00h
        int 16h
        
        cmp ah, 4BH     ;Arrow Left
        je  arrow_left_raquete
        
        cmp ah, 4DH     ;Arrow Right
        je arrow_right_raquete
        
        jmp fim_mover_raquete;
        
        arrow_left_raquete:
            mov ah, raquete_x;
            sub ah, 1
            cmp ah, 0
            jl set_raquete_x_zero
            mov raquete_x, ah
            jmp fim_mover_raquete
            
        set_raquete_x_zero:
            mov raquete_x, 0
            jmp fim_mover_raquete

        arrow_right_raquete:
            mov ah, raquete_x;
            add ah, 2
            cmp ah, 35
            jg set_raquete_x_35
            mov raquete_x, ah
            jmp fim_mover_raquete
            
        set_raquete_x_35:
            mov raquete_x, 35
            jmp fim_mover_raquete
        
        fim_mover_raquete:
        
        ;Limpa o keyboard buffer
        mov ah,0ch
        mov al,0
        int 21h
        
        pop ax
        ret
    endp
    
    mover_bola proc
        push ax
        
        cmp bola_y, 24
        jge perdeu_vida
        cmp bola_y, 1
        jle colidiu_y
        jmp verificar_x
        
        colidiu_y:
            neg velocidade_y
     
        verificar_x: 
            cmp bola_x, 0
            jle colidiu_x
            cmp bola_x, 39
            jge colidiu_x
            jmp fim_mover_bola
            
        perdeu_vida:
            call decrementar_vida
        
        colidiu_x:
            neg velocidade_x
            
        fim_mover_bola:
            mov ah, velocidade_x
            add bola_x, ah
            mov ah, velocidade_y
            add bola_y, ah
        
        pop ax
        ret
    endp
    
    desenha_raquete proc
        push dx
        push ax
        push bx
        
        mov dh, 23      ; y
        mov al, 178     ; caractere (Raquete)
        
        mov dl, raquete_x ; x
        mov bl, 0dh       ; cor do caractere
        call esc_char
        
        inc dl            ; x
        mov bl, 07h    ; cor do caractere
        call esc_char
        
        inc dl            ; x
        call esc_char
        
        inc dl            ; x
        call esc_char
        
        inc dl            ; x
        mov bl, 0dh    ; cor do caractere
        call esc_char
        
        pop bx
        pop ax
        pop dx
        ret
    endp
    
    ; cor do bloco = BL
    ; y = DH
    ; OFFSET BLOCOS = SI
    desenha_bloco proc
        push dx
        push ax
        push bx
        push cx
        push si
        
        mov cl, 7
        
        loop_bloco_x: 
            dec cl
            jz fim_desenha_bloco     
            
            lodsb     ; Load byte at address DS:(E)SI into AL
            cmp al, 99
            je loop_bloco_x
            
            xor ch, ch
            mov dl, al  ; Move o X para dl
            
            loop_escrever_bloco:   
                inc dl
                mov al, 178     ; caractere (Bloco)
                call esc_char
                
                inc ch
                cmp ch, 5
                jne loop_escrever_bloco
                
            jmp loop_bloco_x
            
        
        fim_desenha_bloco:
        pop si
        pop cx
        pop bx
        pop ax
        pop dx
        ret
    endp
    
    verificar_colisao_raquete proc
        push ax
        push bx
        
        cmp bola_y, 22
        jne fim_verificar_colisao_raquete
        
        mov ah, bola_x
        mov bh, raquete_x
        
        cmp ah, bh
        jl fim_verificar_colisao_raquete
        
        mov bl, bh
        add bl, 4
        
        cmp ah, bl
        jg fim_verificar_colisao_raquete
        
        neg velocidade_y
        
        cmp ah, bh
        je colidiu_ponta
        
        cmp ah, bl
        je colidiu_ponta
        
        jmp fim_verificar_colisao_raquete
        
        colidiu_ponta:
            neg velocidade_x
        
        fim_verificar_colisao_raquete:
        
        pop bx
        pop ax
        ret
    endp

    ; y = DH
    ; Pontos ganhos pelo bloco = bx
    ; OFFSET BLOCOS = SI
    verificar_colisao_bloco proc
        push ax
        push bx
        push cx
        push dx
        push di 
     
        inc dh
        cmp bola_y, dh
        jne fim_verificar_colisao_bloco

        mov cl, 0
        
        loop_bloco_colisao_x: 
            inc cl
            cmp cl, 7
            
            je fim_verificar_colisao_bloco
            
            mov ch, bola_x
            mov di, si  ; ES:DI aponta para os numeros
            lodsb       ; Load byte at address DS:(E)SI into AL
            
            
            cmp ch, al
            jl loop_bloco_colisao_x
            
            mov ah, al
            add ah, 5
            
            cmp ch, ah
            
            jg loop_bloco_colisao_x
            neg velocidade_y
            
            add pontos, bx
            dec ganhou_jogo
            jz reiniciar_jogo
            
            cmp contador_bola_fim, 2
            je nao_decrementar_bola_fim
            
            cmp bx, 5
            jge decrementar_sem_validar
            
            dec blocos_destruidos_dec_vel
            jnz nao_decrementar_bola_fim
            decrementar_sem_validar:
                dec contador_bola_fim
                mov blocos_destruidos_dec_vel, 4
            
            nao_decrementar_bola_fim:
            mov al, 99
            stosb ; Store AL at address ES:(E)DI
            
            jmp loop_bloco_colisao_x
            
        reiniciar_jogo:
            call iniciar_jogo
            
        fim_verificar_colisao_bloco:
        
     
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    iniciar_jogo proc
        push ax    
        push bx 
        push si 
        push dx
         
        call reset_bloco
        call reset_bola
        
        mov contador_bola_fim, 8
        mov contador_bola, 0
        mov blocos_destruidos_dec_vel, 4
        mov ganhou_jogo, 24
     
     
        loop_jogo: 
            call delay
            inc contador_bola
           
            call mover_raquete
            
           
            mov ah, contador_bola
            cmp ah, contador_bola_fim
            jne nao_mover_bola
            mov contador_bola, 0
            call verificar_colisao_raquete
            call mover_bola
            
            mov si, OFFSET blocos_vermelhos_x ; DX:SI aponta para os numeros
            mov dh, 1                         ; y
            mov bx, 8                         ; Pontos
            call verificar_colisao_bloco
            
            mov si, OFFSET blocos_vermelhos_claro_x ; DX:SI aponta para os numeros
            mov dh, 3                               ; y
            mov bx, 5                               ; Pontos
            call verificar_colisao_bloco
            
            mov si, OFFSET blocos_verde_x     ; DX:SI aponta para os numeros
            mov dh, 5                         ; y
            mov bx, 3                         ; Pontos
            call verificar_colisao_bloco
            
            mov si, OFFSET blocos_amarelo_x  ; DX:SI aponta para os numeros
            mov dh, 7                        ; y
            mov bx, 1                        ; Pontos
            call verificar_colisao_bloco
            
            nao_mover_bola:
           
            call zera_tela
            call desenhar_menu_jogo
            call desenha_bola
            call desenha_raquete
            
            mov bl, 04h                       ; cor do caractere
            mov dh, 1                         ; y
            mov si, OFFSET blocos_vermelhos_x ; DX:SI aponta para os numeros
            call desenha_bloco
            
            mov bl, 0ch                             ; cor do caractere
            mov dh, 3                               ; y
            mov si, OFFSET blocos_vermelhos_claro_x ; DX:SI aponta para os numeros
            call desenha_bloco
            
            mov bl, 02h                       ; cor do caractere
            mov dh, 5                         ; y
            mov si, OFFSET blocos_verde_x     ; DX:SI aponta para os numeros
            call desenha_bloco
            
            mov bl, 0eh                       ; cor do caractere
            mov dh, 7                         ; y
            mov si, OFFSET blocos_amarelo_x  ; DX:SI aponta para os numeros
            call desenha_bloco
            

            jmp loop_jogo
            
        pop dx
        pop si 
        pop bx
        pop ax
        ret
    endp
        
    menu proc
        push ax
        push si
        push di
        push cx
        
        mov vidas,  3
        mov pontos, 0
        
        call zera_tela
        xor di, di                                                  
        
        mov ah, 0AH ; cor de fundo - cor do caractere
        mov si, OFFSET tela_menu ; DX:SI aponta para a string
        mov di, 320 ; Pula 4 Linhas
        mov cx, 120  
        call esc_string_mem 

        mov ah, 0CH                  
        mov si, OFFSET nome
        mov cx, 40
        call esc_string_mem
        
        mov ah, 0FH                  
        mov si, OFFSET opcoes_menu
        add di, 320 ; Pula 4 Linhas
        mov cx, 80
        call esc_string_mem  
        
        jmp arrow_up
    
        key_check:
            mov     ah, 01h     
            int     16h         
            jz      sem_tecla
            mov     ah, 00h     
            int     16h   
               
            cmp     al, 0DH     ;Enter
            je      click_enter
            
            cmp     ah, 48H     ;Arrow Up
            je      arrow_up
            
            cmp     ah, 50H     ;Arrow Down
            je      arrow_down
            
        sem_tecla:
            jmp key_check  
        
                
        arrow_up:
            xor dl, dl ;Opcao Jogar
            mov bh, 0FH
            mov di, 992
            mov bl, '['
            call esc_char_mem
            mov di, 1004
            mov bl, ']'
            call esc_char_mem
            
            mov di, 1072
            mov bl, ' '
            call esc_char_mem
            mov di, 1082
            mov bl, ' '
            call esc_char_mem
            jmp key_check
            
        arrow_down:
            mov dl, 1 ;Opcao Sair
            mov bh, 0FH
            mov di, 992
            mov bl, ' '
            call esc_char_mem
            mov di, 1004
            mov bl, ' '
            call esc_char_mem
            
            mov di, 1072
            mov bl, '['
            call esc_char_mem
            mov di, 1082
            mov bl, ']'
            call esc_char_mem
            jmp key_check
            
        click_enter:
            cmp dl, 0
            je jogar
            jmp sair
            
        jogar:
            call iniciar_jogo
        sair:
            mov AH, 4CH ; Os dois movs sao para termianar o codigo
            mov AL, 0   ; ou usar mov AX, 4c00H
            int 21H     ; 21H para chamar uma interrupcao
  
        pop cx
        pop di
        pop si
        pop ax
        
        ret
    endp    
      
    inicio:       
        mov AX, @DATA 
        mov DS, AX  
        mov AX,@DATA 
        mov ES, AX  
         
        
        ; Set VideoMode
        xor ax, ax
        int 10h
       
        ; Esconde o cursor
        mov cx, 2507h
        mov ah, 01
        int 10h

        call menu    
            
        mov AH, 4CH ; Os dois movs sao para termianar o codigo
        mov AL, 0   ; ou usar mov AX, 4c00H
        int 21H     ; 21H para chamar uma interrupcao
         
end inicio