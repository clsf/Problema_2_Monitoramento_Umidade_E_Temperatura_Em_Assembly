
@ Dá um pulso em nivel logico alto para a entrada E (eneble)
.macro enable
    nanoSleep time0, time1ms @ Address set-up time
    GPIOTurnOn E
    nanoSleep time0, time1ms @ Enable pulse width (high level)
    GPIOTurnOff E
    nanoSleep time0, time1ms @ Address hold time
.endm

@ Inicializa o display seguindo as recomendações do datasheet da fabricante
.macro initialization
    nanoSleep time0, time15ms

    GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOn D5
    GPIOTurnOn D4

    enable
    nanoSleep time0, time5ms

    @GPIOTurnOff RS
    @GPIOTurnOff D7
    @GPIOTurnOff D6
    @GPIOTurnOn D5
    @GPIOTurnOn D4

    enable
    nanoSleep time0, time150us

    @GPIOTurnOff RS
    @GPIOTurnOff D7
    @GPIOTurnOff D6
    @GPIOTurnOn D5
    @GPIOTurnOn D4

    enable

    @ Function set (Set interface to be 4 bits long.)
    GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOn D5
    GPIOTurnOff D4

    enable

    @Function set (Interface is 4 bits long. Specify the number of display lines and character font.)
    @GPIOTurnOff RS
    @GPIOTurnOff D7
    @GPIOTurnOff D6
    @GPIOTurnOn D5
    @GPIOTurnOff D4

    enable

    @GPIOTurnOff RS
    GPIOTurnOn D7
    @GPIOTurnOff D6
    GPIOTurnOff D5
    @GPIOTurnOff D4

    enable

    displayOff
    displayClear
    modeSet

.endm

@ Desliga a tela do display
.macro displayOff
    GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOff D5
    GPIOTurnOff D4

    enable

    @GPIOTurnOff RS
    GPIOTurnOn D7
    @GPIOTurnOff D6
    @GPIOTurnOff D5
    @GPIOTurnOff D4

    enable
.endm

@ Liga a tela do display
.macro displayOn
    GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOff D5
    GPIOTurnOff D4

    enable

    @GPIOTurnOff RS
    GPIOTurnOn D7
    GPIOTurnOn D6
    GPIOTurnOn D5
    @GPIOTurnOff D4

    enable
.endm

@ Limpa a tela do display
.macro displayClear
    GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOff D5
    GPIOTurnOff D4

    enable

    @GPIOTurnOff RS
    @GPIOTurnOff D7
    @GPIOTurnOff D6
    @GPIOTurnOff D5
    GPIOTurnOn D4

    enable
.endm

@ Entra no modo de escrita (os caracteres serão escrito um apos o outro)
.macro modeSet
    GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOff D5
    GPIOTurnOff D4

    enable

    @GPIOTurnOff RS
    @GPIOTurnOff D7
    GPIOTurnOn D6
    GPIOTurnOn D5
    @GPIOTurnOff D4

    enable
.endm

@ Retorna o curso para o primeiro endereço da tela
.macro returnHome
    GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOff D5
    GPIOTurnOff D4

    enable

    @GPIOTurnOff RS
    @GPIOTurnOff D7
    @GPIOTurnOff D6
    GPIOTurnOn D5
    @GPIOTurnOff D4

    enable
.endm

@ Escreve o caracter "?", utilizado para teste
.macro wtest
    GPIOTurnOn RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    GPIOTurnOn D5
    GPIOTurnOn D4

    enable

    @GPIOTurnOn RS
    GPIOTurnOn D7
    GPIOTurnOn D6
    @GPIOTurnOn D5
    @GPIOTurnOn D4

    enable
.endm



getBit:
    MOV R12, #1 
    LSL R12, R12, R11
    AND R12, R10, R12 
    LSR R12, R12, R11
    BX LR

@ Altera o estado da saida de dados (D7, D6, D5, D4) para o LCD referente o bit corresnponde no codigo ascii
selPin:
    PUSH {LR}

    CMP R11, #3
    BEQ Bit3
    CMP R11, #2
    BEQ Bit2
    CMP R11, #1
    BEQ Bit1
    CMP R11, #0
    BEQ Bit0

    POP {PC}

@ Altera o nivel logico da saida D7
Bit3:
    BL getBit
    CMP R12, #1
    BEQ TurnOnD7
    GPIOTurnOff D7

    POP {PC}
    
TurnOnD7:
    GPIOTurnOn D7
    POP {PC}

@ Altera o nivel logico da saida D6
Bit2:
    BL getBit
    CMP R12, #1
    BEQ TurnOnD6
    GPIOTurnOff D6
    POP {PC}
    
TurnOnD6:
    GPIOTurnOn D6
    POP {PC}

@ Altera o nivel logico da saida D5
Bit1:
    BL getBit
    CMP R12, #1
    BEQ TurnOnD5
    GPIOTurnOff D5
    POP {PC}
    
TurnOnD5:
    GPIOTurnOn D5
    POP {PC}

@ Altera o nivel logico da saida D4
Bit0:
    @MOV R6, LR @ Salva o retorno para WriteDAta
    BL getBit
    CMP R12, #1
    BEQ TurnOnD4
    GPIOTurnOff D4
    POP {PC}
    
TurnOnD4:
    GPIOTurnOn D4
    POP {PC}

@ Escreve uma string no LCD
.macro writeString string len
    MOV R0, #0 @ Contador do caracter da string a ser escrito no LCD

    @ Carrega a string
    LDR R1, =\string 

    @ Carrega o tamanho da string
    LDR R2, =\len 
    LDR R2, [R2]

    BL funcWriteString
.endm

@ Verifica se é a primeira execução, caso for salva o link para o local de chamada na pilha
funcWriteString:
    CMP R0, #0
    BNE loopWriteString
    PUSH {LR}
    BL loopWriteString 

@ Fica em loop até escrever todos os caracteres da string
loopWriteString:
    PUSH {R0}
    PUSH {R1}
    PUSH {R2}

    LDR R1, [R1, R0] @ Pega o ascii do caracter corresponde a posição R0
    BL slice @ Divide o ascii caracter em 2 conjuntos de 4 bits
    MOV R10, R2 @ Coloca em R10 os 4 bits mais significativos
    MOV R9, R3 @ Coloca em R9 os 4 bits menos significativos
    BL funcWriteData @ Envia para o LCD a instrução com os 4 bits mais significativos do ascii
    MOV R10, R9
    BL funcWriteData @ Envia para o LCD a instrução com os 4 bits menos significativos do ascii

    POP {R2}
    POP {R1}
    POP {R0}
    ADD R0, R0, #1 @ Avança para o proximo caracter a ser exibido
    
    CMP R0, R2 @ Verifica se já não exibiu o ultimo caracter
    bne loopWriteString @ Se não, repete o processo
    POP {PC} @ Se já exibiu retorna para o local de chamada no link

@ Escreve um caracter no LCD passando o codigo ascii referente
.macro writeData code
    LDR R1, =\code 
    LDR R1, [R1]
    BL slice
    MOV R10, R2
    MOV R9, R3
    BL funcWriteData
    MOV R10, R9
    BL funcWriteData
.endm

@ Divide um conjunto de 8 bits passados em 2 conjuntos de 4 bits
slice:
    MOV R2, #0b11110000
    MOV R3, #0b00001111
    AND R2, R1, R2
    LSR R2, R2, #4
    AND R3, R1, R3
    BX LR

@ Envia para o LCD uma instrução de write data com 4 bits do codigo ascii
@ É necessario usa-la 2x para exbição de 1 caracter
@ A primeira para os 4 bits mais significativos do código ascii
@ e a segundo para os 4 bits menos significativos.
funcWriteData:
    PUSH {LR}
    GPIOTurnOn RS

    MOV R11, #3 @ Total de bits de dados
    BL selPin @ Altera o sinal da saida de dado D7 para o valor referente o bit 3 em R10 (metade do codigo ascii)
    SUB R11, R11, #1
    BL selPin @ Altera o sinal da saida de dado D6 para o valor referente o bit 2
    SUB R11, R11, #1
    BL selPin @ Altera o sinal da saida de dado D5 para o valor referente o bit 1
    SUB R11, R11, #1
    BL selPin @ Altera o sinal da saida de dado D4 para o valor referente o bit 0

    enable @ Envia a instrução

    POP {PC}

@ Desloca o curso para a primeira posição da segunda linha do LCD
.macro setDDRAM
    GPIOTurnOff RS
    GPIOTurnOn D7
    GPIOTurnOn D6
    GPIOTurnOff D5
    GPIOTurnOff D4

    enable

    @GPIOTurnOff RS
    GPIOTurnOff D7
    GPIOTurnOff D6
    @GPIOTurnOff D5
    @GPIOTurnOff D4

    enable
.endm

@ Separa um decimal em dois digitos (dezenas, unidades) em ascii
.macro getDigits num digit1 digit2
    LDR R0, =\num
    LDR R0, [R0]
    MOV R3, #10
    SDIV R1, R0, R3
    MUL R2, R1, R3
    SUB R2, R0, R2

    ADD R1, R1, #48 @ converte para ascii
    ADD R2, R2, #48

    LDR R0, =\digit1
    STR R1, [R0]

    LDR R0, =\digit2
    STR R2, [R0]
.endm
