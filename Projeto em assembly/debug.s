.macro printDebug
    getDigits byte1 digit1 digit2

    mov r0, #1
    ldr r1, =digit1
    mov r2, #2
    mov r7, #sys_write
    svc 0

    mov r0, #1
    ldr r1, =digit2
    mov r2, #2
    mov r7, #sys_write
    svc 0

    mov r0, #1
    ldr r1, =saltarLinha
    mov r2, #1
    mov r7, #sys_write
    svc 0

    getDigits byte2 digit1 digit2
    mov r0, #1
    ldr r1, =digit1
    mov r2, #2
    mov r7, #sys_write
    svc 0

    mov r0, #1
    ldr r1, =digit2
    mov r2, #2
    mov r7, #sys_write
    svc 0

    mov r0, #1
    ldr r1, =saltar2Linhas
    mov r2, #2
    mov r7, #sys_write
    svc 0
.endm
