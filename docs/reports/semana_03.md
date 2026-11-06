# Relatório de Atividades - Semana 03

| Campo | Informação |
| --- | --- |
| Projeto | Acelerador AES com interface SPI e baixo consumo |
| Autor | Emilieny De Souza Silva |
| Tag | `w03-microarquitetura-transformacoes-v1.0` |

## 1. Resumo

Nesta semana foi definida a microarquitetura do MiniSoC AES e implementadas as transformações de rodada ainda pendentes. O núcleo adota uma arquitetura iterativa com uma rodada completa por ciclo.

Os seguintes módulos foram implementados ou incorporados ao projeto:

- `rtl/minisoc_aes/minisoc_aes_mix_columns.sv`
- `rtl/minisoc_aes/minisoc_aes_add_round_key.sv`
- `rtl/minisoc_aes/minisoc_aes_inv_sbox.sv`
- `rtl/minisoc_aes/minisoc_aes_inv_sub_bytes.sv`
- `rtl/minisoc_aes/minisoc_aes_inv_shift_rows.sv`
- `rtl/minisoc_aes/minisoc_aes_inv_mix_columns.sv`

## 2. Documento de microarquitetura

Foi criado o documento [microarquitetura_v1.0.md](../architecture/microarquitetura_v1.0.md), com:

- Diagrama de blocos interno;
- Arquitetura iterativa do AES;
- Sequência de cifragem e decriptação;
- FSM proposta do `minisoc_aes_top`;
- Estratégia CDC por sincronização de toggle;
- Sequência de reset dos domínios do sistema;
- Convencao de posicionamento dos bytes;
- Lista das transformacoes implementadas.

O fluxo principal proposto foi documentado como:

```text
SubBytes -> ShiftRows -> MixColumns -> AddRoundKey
```

Para a decriptação, o fluxo inverso intermediário é:

```text
InvShiftRows -> InvSubBytes -> AddRoundKey -> InvMixColumns
```

## 3. Implementação das transformações

### 3.1 Transformações diretas

- MixColumns implementado no corpo finito `GF(2^8)`.
- AddRoundKey implementado por operação XOR entre estado e chave da rodada.

### 3.2 Transformações inversas

- InvSbox implementada com tabela de valores inversos.
- InvSubBytes aplicada a cada um dos 16 bytes do bloco.
- InvShiftRows implementada pela reordenação inversa dos bytes.
- InvMixColumns implementada com os coeficientes `0e`, `0b`, `0d` e `09`.

## 4. Verificação

Os seguintes testbenches foram utilizados:

- `tb/minisoc_aes/tb_semana03_round_transformations.sv`
- `tb/minisoc_aes/tb_semana03_inverse_transformations.sv`

Os testes verificaram os valores intermediários da cifra FIPS-197, incluindo:

- MixColumns da rodada intermediária do Apêndice B;
- AddRoundKey usando a chave intermediária;
- InvMixColumns do estado cifrado correspondente;
- InvShiftRows e InvSubBytes dos estados intermediários;
- Casos pontuais da InvSbox, incluindo `inv_sbox(63) = 00` e `inv_sbox(ed) = 53`.

### 4.1 Comandos executados

Para as transformações diretas:

```sh
make run_semana03
make wave_semana03
```

Para as transformações inversas:

```sh
make run_semana03_inverse
make wave_semana03_inverse
```

As formas de onda são geradas pelos testbenches nos arquivos:

```text
waves_semana03_round.fsdb
waves_semana03_inverse.fsdb
```

## 5. Resultados

### 5.1 MixColumns e AddRoundKey

Resultado registrado pelo simulador:

```text
STATUS FINAL: PASS - MixColumns e AddRoundKey passaram.
```

Valores observados na forma de onda:

```text
MixColumns entrada:
d4bf5d30e0b452aeb84111f11e2798e5

MixColumns saída:
046681e5e0cb199a48f8d37a2806264c

AddRoundKey:
046681e5e0cb199a48f8d37a2806264c XOR
a0fafe1788542cb123a339392a6c7605 =
a49c7ff2689f352b6b5bea43026a5049
```

### 5.2 Transformações inversas

Resultado registrado pelo simulador:

```text
STATUS FINAL: PASS - Transformacoes inversas passaram.
```

Valores observados na forma de onda:

```text
InvMixColumns:
d4bf5d30e0b452aeb84111f11e2798e5

InvShiftRows:
d42711aee0bf98f1b8b45de51e415230

InvSubBytes:
193de3bea0f4e22b9ac68d2ae9f84808

InvSbox:
63 -> 00
ED -> 53
```

## 6. Conclusão

A implementação das transformações direta e inversas da rodada AES foi concluída e validada por testbenches autoverificáveis e inspeção das formas de onda no Verdi.

Os resultados obtidos nos simuladores foram `PASS`, e os valores intermediários foram conferidos com os vetores utilizados nos Apêndices da FIPS-197.
