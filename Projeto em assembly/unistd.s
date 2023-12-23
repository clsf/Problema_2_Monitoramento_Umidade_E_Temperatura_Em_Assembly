@
@ Chamadas do sistema Linux.
@

.equ sys_restart_syscall, 0 @ reinicia uma chamada do sistema
.equ sys_exit, 1 @ causa uma termincação normal do processo
.equ sys_fork, 2 @ cria um proceso filho
.equ sys_read, 3 @ Lê a partir de um descritor de arquivo
.equ sys_write, 4 @ escreve para um descritor de arquivo
.equ sys_open, 5 @ abre e possibilita criar um arquivo
.equ sys_close, 6 @ fecha um descritor de arquivo
.equ sys_creat, 8 @ cria um novo arquivo
.equ sys_link, 9 @ faz um novo nome para o arquivo
.equ sys_unlink, 10 @ deleta um nome e o arquivo no qual o nome se refere
.equ sys_execve, 11 @ executa um programa
.equ sys_nanosleep, 162 @ sleep do programa
.equ sys_mmap2, 192 @ mapeia arquivos ou dispositivos na memória
