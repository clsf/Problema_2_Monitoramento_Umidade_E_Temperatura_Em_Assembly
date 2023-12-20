# Problema_2_Monitoramento_Umidade_E_Temperatura_Em_Assembly
Problema 2 da disciplina de Sistemas Digitais - Monitoramento de Temperatura e Humidade em Assembly

## Sumário
- [Introdução](#introdução)
  - [Como Executar](#como-executar)
  - [Subtópicos](#subtópicos)
- [Desenvolvimento](#desenvolvimento)
  - [Subtópicos](#subtópicos)
- [Conclusão](#conclusão)

## Introdução
Nesta seção, abordaremos informações essenciais sobre o projeto, incluindo uma visão geral do desenvolvimento na plataforma Orange, módulos responsáveis e referências ao projeto de Paulo.

- **Projeto na Orange:** Descreva brevemente o projeto na plataforma Orange, destacando os principais módulos e suas responsabilidades.

- **Projeto de Paulo:** Forneça um link para o projeto de Paulo, permitindo que os usuários acessem mais informações relevantes.

## Equipe de Desenvolvimento
- **Tutor:** [Nome do Tutor]

## Recursos Utilizados
Liste os recursos, ferramentas e tecnologias que foram utilizados durante o desenvolvimento do projeto.

## Como Executar
Forneça instruções claras sobre como executar o projeto. Isso pode incluir requisitos de sistema, instalação de dependências e passos específicos para a execução do código.

## Desenvolvimento - Módulos em Assembly da Orange
Nesta seção, detalharemos os módulos desenvolvidos em Assembly para a plataforma Orange.

### Módulo GPIOMEM
Explique a funcionalidade do módulo GPIOMEM, detalhando seu papel no projeto.

### Módulo LCD
Descreva as características e a função do módulo LCD, destacando sua contribuição para o projeto.

### Módulo UART
Este módulo foi projetado para realizar a configuração e uso da UART em uma Orange Pi PC Plus. A UART (Universal asynchronous Receiver/Transmitter) é um protocolo essencial para a comunicação serial entre dispositivos e foi dita para transmissões de palavras de 8 bits, com 1 bit de start, sem bit de paridade e com a velociadade de transmissão de aproxiamdamente 9600 bps. 

#### Modo de operação
O modo de operação UART utilizado é o 16550.Este modo contém buffers no formato FIFO tanto para o transmitter como para o receiver, que servem para armazenar os dados que são recebidos dando a possibilidade do programador que estiver utilizando este modo escolha em que momento os dados serão lidos.

#### Escolha de pinos
A orange Pi pc plus, possui diversos pinos que podem servir para UART, os pinos escolhidos foram o PA13 e PA14, que são podem ser utilizados como UART3.Sendo assim as escolhas de endereços e configurações tiveram como base UART3.(imagem Gpioo?)

##### Funções implementadas 
  1. initUART: 
    - Inicializando a UART 
      - È desabilitado duas vezes em sequência o reset da UART3 através do registrador BUS_SOFT_RST_REG4 
      - Habilita o PLL_PERIPH0 como fonte de clock de 600MHz através do registrador PLL_PERIPH0_CTRL_REG 
      - Seleciona o PLL_PERIPH0 como fonte de clock através do registrador APB2_CFG_REG 
      - Habilita o UART3_GATING que para ativar o clock no barramento através do registrador BUS_CLK_GATING_REG3  
    - Configurando a UART3 
      - È habilitado o FIFO através do registrador UART_FCR
      - Devido ao fato dos registradores que representam a parte alta e parte baixa do divisor do baud rate possuirem o mesmo endereço de memória que outros registradores que tem funções diferentes, é necessário que seja ativado o DLAB, que está no registrador UART_LCR, para que os endereços de memoria que serão utilizados tenham a função esperada de divisor  
        - Para saber qual valor irá ser colocado no divicor é necessário realizar esta operação:(colocar imagem formula)
        - Este número em binário é 111101000010.01, desta maneira é possivel saber o valor da parte baixa do divisor(01000010) e a parte alta(1111)
      - È registrado o valor 01000010 no DLL(divisor latch low) através do registrador UART_DLL 
      - É registrado o valor 1111 no DLH(divisor latch hig) através do registrador UART_DLH 
      - È desativado o DLAB no registrador UART_LCR para que os endereços de memória voltem a ter suas funções anteriores 
      - Configura-se o tamanho da palavra como 8 bits e desativa o bit de paridade através do registrado UART_LCR 
  2. dataReceiver:
    - Após ser chamada, a função verifica se existe algum dado pronto para ser lido no buffer do receiver através do registrador UART_LSR verificando o bit DR(data ready)
    - Caso tenha algum dado para ser lido é lido o endereço de memória correspondente ao receiver e o dado é obtido  

  Para realizar o envio de dados a única operação necessária é armazenar um valor no endereço de memória correspondente ao transmitter da uart, por este motivo não foi necessária a criação de uma função especifica para isso 
    

### Mains
Discuta os diversos módulos mains desenvolvidos, abordando suas funcionalidades específicas e importância no projeto.

## Conclusão
Nesta seção, resuma o que foi alcançado durante o desenvolvimento. Utilize vídeos e imagens para destacar visualmente o progresso e os resultados do projeto.





