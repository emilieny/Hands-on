# Relatório de Atividades - Semana 01

**Projeto:** Acelerador AES com interface SPI e baixo consumo  
**Autor:** Emilieny De Souza Silva 
**Tag:** `w01-setup-v1.0`

---

## 1. Resumo da Semana

Nesta primeira semana, foi realizado o setup inicial do ambiente de desenvolvimento, a estruturação da árvore do repositório Git e a automação do fluxo de compilação, simulação e síntese via `Makefile`. Além disso, foram cadastradas as issues do projeto no GitHub e elaborado o estudo teórico sobre o algoritmo AES-128 (FIPS-197) e a interface de comunicação SPI.

---

## 2. Estrutura do Repositório e Ambiente

O repositório foi organizado seguindo a estrutura padrão de projetos de microeletrônica/ASIC:

.
├── docs/               # Documentação, especificações e relatórios
│   ├── architecture/
│   ├── reports/        # Relatórios semanais (semana_01.md)
│   └── spec/
├── rtl/                # Código SystemVerilog (AES, SPI, Sync, RegFile, PowerCtrl)
├── tb/                 # Testbenches
├── syn/                # Scripts Tcl (synth.tcl), constraints (constraints.sdc) e relatórios
├── upf/                # Especificação de potência em UPF
└── scripts/            # Automação e utilitários

---

## 3. Automação e Fluxo (Makefile & Scripts EDA)

Foi configurado o `Makefile` com suporte às ferramentas da Synopsys:
- **`vlogan` / `vcs`:** Compilação e simulação em SystemVerilog (`+lint=all`).
- **`verdi`:** Visualização de formas de onda (arquivos `.fsdb`).
- **`dc_shell`:** Síntese lógica via Synopsys Design Compiler.

### Configuração de Síntese (`syn/synth.tcl` & PDK):
- **Biblioteca Alvo:** SAED32 32nm Digital EDA Kit (`saed32rvt_tt1p05v25c.db`).
- **Constraints Iniciais (`syn/constraints.sdc`):**
  - Domínio `clk_sys`: 50 MHz (Período: 20 ns).
  - Domínio `sclk`: 10 MHz (Período: 100 ns).
  - Declaração de domínios assíncronos via `set_clock_groups -asynchronous`.

---

## 4. Estudo Teórico

### 4.1. Algoritmo AES-128 (FIPS-197)
O **Advanced Encryption Standard (AES)** é um algoritmo de criptografia simétrica baseado em blocos, padronizado pelo NIST em 2001, e sua variante de 128 bits é amplamente utilizada em sistemas embarcados, redes e hardware dedicado por oferecer um equilíbrio entre segurança, simplicidade de implementação e desempenho. O algoritmo processa blocos de 128 bits e utiliza uma chave secreta também de 128 bits, resultando em um fluxo de 10 rodadas de transformação.

A estrutura interna do AES organiza os 16 bytes do bloco em uma matriz $4 \times 4$ denominada **State**, em que cada byte representa um elemento do campo finito $GF(2^8)$. A cifra é composta por uma etapa inicial de **AddRoundKey** e por 9 rodadas completas, seguidas por uma rodada final sem a operação de **MixColumns**.

- **Tamanho do bloco:** 128 bits = 16 bytes.
- **Tamanho da chave:** 128 bits.
- **Número de rodadas:** 10 para AES-128.
- **Subchaves:** a chave inicial é expandida em 11 round keys de 128 bits, sendo uma subchave para a etapa inicial e uma para cada uma das 10 rodadas.

#### Etapas da rodada AES
Cada rodada do algoritmo é definida por quatro transformações principais:

1. **SubBytes**  
   Realiza uma substituição não linear de cada byte do State por meio da **S-box** AES. A S-box é construída a partir da inversão de elementos em $GF(2^8)$ e de uma transformação afim, que garante resistência contra ataques diferenciais e lineares.

2. **ShiftRows**  
   Desloca circularmente as linhas do State. A linha 0 não sofre deslocamento; a linha 1 desloca 1 byte para a esquerda; a linha 2 desloca 2 bytes; e a linha 3 desloca 3 bytes. Essa etapa promove difusão entre bytes de diferentes colunas.

3. **MixColumns**  
   Combina os 4 bytes de cada coluna de forma linear, utilizando uma multiplicação em $GF(2^8)$ por uma matriz fixa. Essa operação aumenta a propagação dos bits e é essencial para a segurança da cifra.

4. **AddRoundKey**  
   Aplica XOR bit a bit entre o State atual e a subchave correspondente da rodada. Como a subchave varia por rodada, o estado fica dependente da chave em cada etapa.

A operação final, após a 9ª rodada completa, executa uma rodada final sem **MixColumns**, consistindo em **SubBytes + ShiftRows + AddRoundKey**. Essa escolha é importante para manter a consistência da estrutura e a compatibilidade com o padrão FIPS-197.

#### Key Expansion
O processo de expansão da chave é responsável por gerar as subchaves utilizadas em cada rodada. O AES-128 inicia com uma chave primária de 128 bits e produz, por meio de **RotWord**, **SubWord** e **Rcon**, 11 subchaves. Esse mecanismo é crítico, pois garante que cada rodada tenha um valor específico para mascarar o State e reforçar a segurança do algoritmo. Em implementações em hardware, a geração da chave pode ser feita por um módulo de expansão dedicado ou pela reutilização da mesma lógica em um datapath iterativo.

#### Observações para implementação em ASIC
No contexto de arquitetura de circuitos integrados, o AES é frequentemente implementado em duas formas principais:

- **Implementação iterativa:** usa um mesmo conjunto de blocos para executar uma rodada por ciclo, economizando área e potência, sendo adequada para módulos com baixo consumo.
- **Implementação pipeline/loop unrolled:** executa múltiplas rodadas em paralelo para alcançar maior throughput, porém com aumento de área, complexidade e dissipação.

Dado o foco do projeto em arquitetura low-power, a implementação iterativa é a opção mais apropriada, pois reduz o número de operadores ativos simultaneamente e favorece a economia energética.

### 4.2. Protocolo SPI (Serial Peripheral Interface)
O **SPI (Serial Peripheral Interface)** é um protocolo síncrono de comunicação serial full-duplex desenvolvido pela Motorola, amplamente utilizado para interconectar microcontroladores, sensores, memorias e módulos de processamento. Sua simplicidade, baixa latência e suporte a comunicação em alta velocidade tornam-no uma opção frequente em sistemas embarcados e em interfaces de periféricos em ASIC/SoC.

#### Topologia e sinais
A comunicação SPI segue o modelo mestre-escravo, em que um único mestre controla um ou mais escravos. Os sinais fundamentais são:

- **SCLK:** clock serial gerado pelo mestre.
- **CS_N / SS:** linha de seleção do escravo, normalmente ativa em nível baixo.
- **MOSI:** linha de dados do mestre para o escravo.
- **MISO:** linha de dados do escravo para o mestre.

A operação ocorre em modo síncrono, com base no clock gerado pelo mestre. Em cada ciclo de clock, o valor presente em uma linha de dados é amostrado e, em seguida, shiftado em um registrador, permitindo a transferência serial de bits.

#### Modos de operação
O SPI possui quatro modos de operação, definidos por duas variáveis:

- **CPOL:** polaridade do clock em repouso.
- **CPHA:** fase do clock, isto é, em qual borda os dados são amostrados.

Os modos mais comuns são:

- **Modo 0:** `CPOL = 0`, `CPHA = 0` — o clock permanece baixo em repouso e os dados são amostrados na borda de subida.
- **Modo 3:** `CPOL = 1`, `CPHA = 1` — o clock permanece alto em repouso e os dados são amostrados na borda de descida.

No projeto, o uso do **Modo 0** é adequado para uma interface de leitura e escrita em registradores, pois facilita a sincronização do sistema e a leitura em bordas simples do clock.

#### Transferência e organização dos dados
A troca de dados SPI é normalmente organizada em quadros de tamanho fixo, sendo comuns 8, 16 ou 32 bits por palavra. A lógica de hardware geralmente implementa um registrador de deslocamento em ambos os lados, permitindo que os bits sejam enviados e recebidos simultaneamente. Em uma transmissão de 8 bits, o mestre desloca o dado de saída em `MOSI` enquanto o escravo desloca o dado de saída em `MISO`, resultando em comunicação full-duplex.

Em uma arquitetura de bloco criptográfico, a interface SPI é frequentemente usada para:

- carregar a chave do AES;
- enviar o bloco de entrada (`data_in`);
- iniciar uma operação de cifragem/decifragem;
- ler o bloco de saída (`data_out`);
- configurar registradores de controle e status.

#### Desafios de sincronização em hardware
Como o `SCLK` pode ser gerado por uma fonte externa e assíncrona em relação ao domínio `clk_sys`, o projeto precisa tratar o problema de **CDC (Clock Domain Crossing)**. O sinal `CS_N` e a linha de dados `MOSI` devem ser registradas e sincronizadas antes de acessarem o banco de registradores do sistema, para evitar metastabilidade e garantir operações confiáveis. Uma abordagem comum em RTL é: 

- amostrar `CS_N` e `MOSI` no domínio do sistema mediante sincronizadores de 2 estágios;
- gerar sinais de controle locais (por exemplo, `start`, `tx_valid`, `rx_valid`);
- usar FSM para tratar a transação serial; 
- sincronizar a resposta `MISO` de volta ao domínio do mestre, quando necessário.

Esse ponto é especialmente importante em ambientes ASIC/FPGA, em que o domínio do módulo SPI pode ser desacoplado do clock principal do bloco de processamento.

### 4.3. Relevância da Integração AES + SPI no Projeto
A combinação entre o algoritmo AES e a interface SPI é estratégica para um módulo criptográfico dedicado. O AES fornece a funcionalidade criptográfica de segurança, enquanto o SPI atua como uma interface de acesso externa simples, padronizada e eficiente. Essa integração permite que um sistema externo, como um microcontrolador ou um controlador de rede, envie chaves e dados para o módulo, receba resultados cifrados e controle o processamento de forma segura e compacta.

Além disso, em um ambiente de arquitetura low-power, a interface serial reduz a quantidade de pinos e linhas de condução em comparação com interfaces paralelas, diminuindo o consumo de energia e simplificando o layout do circuito. Para o projeto em questão, essa combinação atende tanto aos requisitos de segurança do algoritmo quanto aos critérios de baixo consumo e integração em um bloco IP.

---

---

## 5. Próximos Passos (Semana 02)

- Elaborar a especificação completa da microarquitetura do núcleo AES (modelo iterativo).
- Definir o mapa de registradores (Controle, Status, Key, DataIn, DataOut).
- Detalhar a estratégia de sincronização de domínios de clock (CDC).
- Apresentar o documento de arquitetura $v1.0$ na defesa curta.