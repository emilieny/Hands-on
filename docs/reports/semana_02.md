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



## 4. Dúvidas sobre o Block Guide


