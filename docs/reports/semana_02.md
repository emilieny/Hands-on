# Relatório de Atividades - Semana 02

| Campo | Informação |
| --- | --- |
| Projeto | Acelerador AES com interface SPI e baixo consumo |
| Autor | Emilieny De Souza Silva |
| Tag | `w02-subbytes-shiftrows-v1.0` |

## 1. Resumo

Nesta semana foram implementados os módulos combinacionais de SubBytes e ShiftRows do MiniSoC AES:

- `rtl/minisoc_aes/minisoc_aes_sbox.sv`
- `rtl/minisoc_aes/minisoc_aes_sub_bytes.sv`
- `rtl/minisoc_aes/minisoc_aes_shift_rows.sv`

Também foi preparado um testbench autoverificável em `tb/minisoc_aes/tb_semana02.sv`.

## 2. Verificação

O testbench verifica:

- A S-box nas entradas `00` e `53`;
- Todas as 256 entradas da S-box contra um array de referência FIPS-197;
- SubBytes e ShiftRows da rodada 1 do Apêndice B da FIPS-197;
- SubBytes e ShiftRows da rodada 10 do Apêndice B da FIPS-197;

O fluxo pode ser executado pelo comando:

```sh
make run
```

## 3. Status da execução

Executado com o comando:

```sh
make run
```

Resultado:

- S-box: PASS — 256/256 entradas verificadas.
- Casos especiais: PASS — `sbox(00) = 63` e `sbox(53) = ed`.
- Rodada 1: PASS — SubBytes e ShiftRows conforme o Apêndice B.
- Rodada 10: PASS — SubBytes e ShiftRows conforme o Apêndice B.
- STATUS FINAL: PASS — TODOS OS TESTES PASSARAM.

Saídas relevantes registradas pelo simulador:

```text
-> S-box: PASS (256/256 entradas verificadas)
-> Rodada 1: PASS
-> Rodada 10: PASS
STATUS FINAL: PASS - TODOS OS TESTES PASSARAM!
```


## 4. Dúvidas sobre o Block Guide

- Como será determinado o endereço-base inicial dos blocos processados pelo AES, já que cada bloco ocupa quatro palavras consecutivas?
- Como serão definidos os sinais e o protocolo do datapath para carregar, processar e devolver um bloco de 128 bits ao motor AES?
- Qual sequência de sinais e quantos ciclos são necessários para transferir a posse da memória ao AES antes de aceitar START?
