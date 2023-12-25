initUART:
    push {lr}

    @ Desabilita o reset da UART
    mov r0, r8
    sub r0, r0, #0x800
    ldr r2, [r0, #0x02D8] @ Carrega o reg BUS_SOFT_RST_REG4
    mov r1, #1
    lsl r1, #19
    bic r2, r2, r1
    str r2, [r0, #0x02D8]

    @ Desabilita o reset da UART(Se não for feito isso novamente, a comunição uart não funciona corretamente)
    mov r0, r8
    sub r0, r0, #0x800
    ldr r2, [r0, #0x02D8] @ Carrega o reg BUS_SOFT_RST_REG4
    mov r1, #1
    lsl r1, #19
    orr r2, r2, r1
    str r2, [r0, #0x02D8]

    @ Habilita o PLL como fonte do clock 
    mov r0, r8
    sub r0, r0, #0x800
    ldr r2, [r0, #0x0028] @ Carrega o reg PLL_PERIPH0_CTRL_REG
    mov r1, #1
    lsl r1, #31
    orr r2, r2, r1
    str r2, [r0, #0x0028]

    @ Seleciona o PLL como a fonte do clock para uart
    mov r0, r8
    sub r0, r0, #0x800
    ldr r2, [r0, #0x0058] @ Carrega o reg APB2_CFG_REG
    mov r1, #0b10
    lsl r1, #24
    orr r2, r2, r1
    str r2, [r0, #0x0058]

    @ Habilita o UART3_GATING que serve para ativar o clock no barramento  
    mov r0, r8
    sub r0, r0, #0x800
    ldr r2, [r0, #0x006C] @ Carrega o reg BUS_CLK_GATING_REG3
    mov r1, #1
    lsl r1, #19
    orr r2, r2, r1
    str r2, [r0, #0x006C]

    @ ======================================
    @ Configuração dos Registradores da UART
    @ ======================================

    @ Habilita o FIFO 
    mov r0, r6
    mov r1, #1
    ldr r2, [r0, #0x0008] @ Carrega o reg UART_FCR
    orr r2, r2, r1
    str r2, [r0, #0x0008]

    @ Habilita o DLAB para configurar o Baud Rate
    mov r0, r6
    mov r1, #1
    lsl r1, #7
    ldr r2, [r0, #0x000C] @ Carrega o reg UART_LCR
    orr r2, r2, r1
    str r2, [r0, #0x000C]

    @ Muda o DLS para 8 bits o tamanho da palavra que vai ser enviada e recebida, e desativa bit de paridade
    mov r0, r6
    mov r1, #0b11
    ldr r2, [r0, #0x000C] @ Carrega o reg UART_LCR
    orr r2, r2, r1
    str r2, [r0, #0x000C]

    @ Calculo do divisor do Baud Rate
    @ (600MHz / ( 9600 ∗ 16 )) = 3906.25
    @ = 111101000010.01 in binary

    @ Adiciona os 8 lsb do divisor ao DLL
    mov r0, r6
    mov r1, #0b11111111
    ldr r2, [r0] @ Carrega o reg UART_DLL
    bic r2, r2, r1
    mov r1, #0b01000010
    orr r2, r2, r1
    str r2, [r0]

    @ Adiciona os 8 msb do divisor ao DLH
    mov r0, r6
    mov r1, #0b11111111
    ldr r2, [r0, #0x0004] @ Carrega o reg UART_DLH
    bic r2, r2, r1
    mov r1, #0b1111
    orr r2, r2, r1
    str r2, [r0, #0x0004]

    @ Desabilita o DLAB para usar os buffers RBR e THR
    mov r0, r6
    mov r1, #1
    lsl r1, #7
    ldr r2, [r0, #0x000C] @ Carrega o reg UART_LCR
    bic r2, r2, r1
    str r2, [r0, #0x000C]

    pop {pc}

@ =======
@ Leitura
@ =======

@Função responsável ler o buffer do receiver da uart 
dataReceiver:
    push {lr}

loopDataReceiver:
    mov r1, #1
    ldr r0, [r6, #0x0014] @ Carrega o DR
    and r0, r0, r1
    cmp r0, #0
    beq loopDataReceiver @Verifica se tem um dado pronto para ser lido no buffer do receiver do fifo da uart
    ldr r0, [r6]
    pop {pc}



