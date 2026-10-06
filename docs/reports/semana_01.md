# Relatório de Atividades - Semana 01

| Campo | Informação |
| --- | --- |
| Projeto | Acelerador AES com interface SPI e baixo consumo |
| Autor | Emilieny De Souza Silva |
| Tag | `w01-setup-v1.0` |

---

## 1. Resumo da Semana

Nesta primeira semana, foi realizado o setup inicial do ambiente de desenvolvimento, a estruturação da árvore do repositório Git e a automação do fluxo de compilação, simulação e síntese via `Makefile`. Além disso, foram cadastradas as issues do projeto no GitHub e elaborado o estudo teórico sobre o algoritmo AES-128 (FIPS-197) e a interface de comunicação SPI.

---

## 2. Estrutura do Repositório e Ambiente

O repositório foi organizado seguindo a estrutura padrão de projetos de microeletrônica/ASIC:

```text
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
```

---

## 3. Automação e Fluxo (Makefile & Scripts EDA)

Foi configurado o `Makefile` com suporte às ferramentas da Synopsys:

- **`vlogan` / `vcs`:** Compilação e simulação em SystemVerilog (`+lint=all`).
- **`verdi`:** Visualização de formas de onda (arquivos `.fsdb`).
- **`dc_shell`:** Síntese lógica via Synopsys Design Compiler.

### Configuração de síntese (`syn/synth.tcl` e PDK)

- **Biblioteca Alvo:** SAED32 32nm Digital EDA Kit (`saed32rvt_tt1p05v25c.db`).
- **Constraints Iniciais (`syn/constraints.sdc`):**
  - Domínio `clk_sys`: 50 MHz (Período: 20 ns).
  - Domínio `sclk`: 10 MHz (Período: 100 ns).
  - Declaração de domínios assíncronos via `set_clock_groups -asynchronous`.

---

## 4. Estudo Teórico

### 4.1. Algoritmo AES-128 (FIPS-197)

O **Advanced Encryption Standard (AES)** é uma cifra simétrica de bloco padronizada pelo NIST. No AES-128, cada bloco contém 128 bits e a chave também contém 128 bits. O algoritmo processa cada bloco em 10 rodadas.

Os 16 bytes do bloco são organizados em uma matriz de 4 × 4 bytes chamada **State**. Cada byte é tratado como um elemento do campo finito GF(2⁸). O processamento começa com uma etapa **AddRoundKey**, segue com 9 rodadas completas e termina com uma rodada sem **MixColumns**.

| Parâmetro | AES-128 |
| --- | --- |
| Tamanho do bloco | 128 bits (16 bytes) |
| Tamanho da chave | 128 bits |
| Número de rodadas | 10 |
| Subchaves | 11 round keys de 128 bits |

#### Etapas da rodada AES

As rodadas completas aplicam as quatro transformações abaixo, nesta ordem:

1. **SubBytes:** substitui cada byte do State por meio da S-box AES. A S-box usa a inversão em GF(2⁸), seguida de uma transformação afim, e introduz não linearidade.
2. **ShiftRows:** desloca circularmente as linhas do State para a esquerda. A linha 0 não é deslocada; as linhas 1, 2 e 3 são deslocadas, respectivamente, por 1, 2 e 3 bytes. Isso redistribui os bytes entre colunas.
3. **MixColumns:** transforma cada coluna por multiplicação por uma matriz fixa em GF(2⁸), contribuindo para a difusão.
4. **AddRoundKey:** combina o State com a subchave da rodada por meio de XOR.

A rodada final, depois das 9 rodadas completas, aplica **SubBytes**, **ShiftRows** e **AddRoundKey**, sem **MixColumns**.

#### Key Expansion

A expansão da chave gera as 11 subchaves usadas pela etapa inicial e pelas 10 rodadas. No AES-128, ela utiliza as operações **RotWord**, **SubWord** e constantes **Rcon**. Em hardware, a expansão pode ser implementada em um módulo dedicado ou compartilhada ao longo de um datapath iterativo.

#### Observações para implementação em ASIC

| Arquitetura | Características |
| --- | --- |
| Iterativa | Reutiliza os recursos para processar rodadas em ciclos sucessivos. Tende a reduzir a área, mas aumenta a latência por bloco. |
| Unrolled/pipeline | Implementa várias rodadas em paralelo. Pode aumentar o throughput, com maior custo de área e potência. |

Como o projeto prioriza baixo consumo, a arquitetura iterativa é uma candidata adequada. A escolha final deve considerar também a frequência, a latência e a área disponíveis.

### 4.2. Protocolo SPI (Serial Peripheral Interface)

O **Serial Peripheral Interface (SPI)** é uma interface serial síncrona, normalmente full-duplex, usada para conectar um controlador a periféricos. O mestre gera o clock e seleciona o escravo com o qual deseja se comunicar.

#### Sinais do barramento

| Sinal | Função |
| --- | --- |
| `SCLK` | Clock serial gerado pelo mestre. |
| `CS_N` / `SS` | Seleciona o escravo; geralmente é ativo em nível baixo. |
| `MOSI` | Dados do mestre para o escravo. |
| `MISO` | Dados do escravo para o mestre. |

Enquanto os dados são transmitidos em uma direção, outros dados podem ser recebidos na direção oposta. O SPI não define, por si só, um formato universal de comando, tamanho de palavra ou enquadramento; esses detalhes são definidos pelo dispositivo ou pela implementação.

#### Modos de operação

Os quatro modos SPI são definidos pela polaridade (`CPOL`) e pela fase (`CPHA`) do clock:

| Modo | CPOL | CPHA | Repouso de SCLK | Borda de amostragem |
| --- | --- | --- | --- | --- |
| 0 | 0 | 0 | Baixo | Subida |
| 1 | 0 | 1 | Baixo | Descida |
| 2 | 1 | 0 | Alto | Descida |
| 3 | 1 | 1 | Alto | Subida |

No **modo 0**, selecionado para o projeto, `SCLK` fica baixo em repouso; os dados são amostrados na borda de subida e normalmente mudam na borda de descida. O modo precisa ser o mesmo no mestre e no escravo.

#### Transações e integração com o AES

O tamanho das palavras e o formato dos quadros não são fixados pelo SPI. Uma implementação pode usar registradores de deslocamento para transmitir e receber bits simultaneamente. Neste bloco, a interface pode ser usada para:

- carregar a chave do AES;
- enviar o bloco de entrada (`data_in`);
- iniciar uma operação de cifragem/decifragem;
- ler o bloco de saída (`data_out`);
- configurar registradores de controle e status.

#### Sincronização entre domínios de clock (CDC)

Se `SCLK` for assíncrono a `clk_sys`, os dados recebidos não devem ser transferidos diretamente entre domínios sem uma estratégia de CDC. Uma arquitetura comum é receber e montar a palavra no domínio `SCLK` e transferir palavras completas ao domínio `clk_sys` por meio de um handshake ou FIFO assíncrona. Sincronizadores de dois estágios são apropriados para sinais de controle de um bit, mas não substituem um mecanismo seguro para barramentos de dados.

O sinal `MISO` também precisa respeitar o modo SPI e os tempos de setup/hold do mestre. A lógica deve definir quando habilitar a saída, normalmente enquanto `CS_N` está ativo, e qual valor apresentar quando o dispositivo não está selecionado.

### 4.3. Relevância da Integração AES + SPI no Projeto

O AES fornece a função de cifragem, enquanto o SPI permite que um controlador externo configure e acesse o bloco usando poucas linhas de sinal. A interface pode transportar a chave, o bloco de entrada, comandos de início e o resultado, conforme o mapa de registradores definido para o projeto.

Uma interface serial também reduz a quantidade de pinos em relação a uma conexão paralela. Isso pode simplificar a integração física; no entanto, o consumo total depende da frequência, da atividade de comutação e da arquitetura implementada, não apenas do número de sinais.

---

## 5. Próximos Passos (Semana 02)

- Elaborar a especificação completa da microarquitetura do núcleo AES (modelo iterativo).
- Definir o mapa de registradores (Controle, Status, Key, DataIn, DataOut).
- Detalhar a estratégia de sincronização de domínios de clock (CDC).
- Apresentar o documento de arquitetura `v1.0` na defesa curta.