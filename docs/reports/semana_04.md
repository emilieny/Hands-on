# Relatório de Atividades - Semana 04

| Campo | Informação |
| --- | --- |
| Projeto | Acelerador AES com interface SPI e baixo consumo |
| Autor | Emilieny De Souza Silva |
| Semana | 04 |

## 1. Objetivo

Implementar a expansão de chave AES-128 e um datapath iterativo de bloco,
com cifragem e decriptação, usando uma rodada por ciclo.

## 2. Implementação

Foram adicionados:

- `rtl/minisoc_aes/minisoc_aes_key_exp.sv`: gera as 11 round keys AES-128;
- `rtl/minisoc_aes/minisoc_aes_dp.sv`: datapath sequencial com `start`, `busy`
  e `done`;
- `tb/minisoc_aes/tb_semana04_aes128.sv`: testbench autoverificável.

Na cifragem, o datapath aplica `AddRoundKey` inicial, nove rodadas completas
e a rodada final sem `MixColumns`. Na decriptação, inicia com a round key 10,
processa as rodadas inversas em ordem decrescente e termina com a rodada
inversa sem `InvMixColumns`.

## 3. Vetores de referência

O testbench utiliza os vetores AES-128 da FIPS-197:

```text
key  = 000102030405060708090a0b0c0d0e0f
pt   = 00112233445566778899aabbccddeeff
ct   = 69c4e0d86a7b0430d8cdb78070b4c55a

key  = 2b7e151628aed2a6abf7158809cf4f3c
pt   = 3243f6a8885a308d313198a2e0370734
ct   = 3925841d02dc09fbdc118597196a0b32
```

## 4. Execução

```sh
make run_semana04
```

Critério de aceite: cifragem e decriptação dos dois vetores devem terminar
com `STATUS FINAL: PASS`.
