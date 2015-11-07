;NOMEDAROTINA:  Descricao
;               Entrada:
;               Saida:
;               Efeitos:

;PARTE I: Constantes
IO_WRITE           EQU FFFEh
IO_CONTROL         EQU FFFCh
SP_INICIAL         EQU FDFFh
FIM_STRING         EQU '@'
POS_MSG_INICIO1    EQU 0C23h
POS_MSG_INICIO2    EQU 0E1Dh
MASCARA_INICIO     EQU 0000000000000010b
MASCARA_JOGO       EQU 1000000000000111b
MASK_CONTROL       EQU FFFAh
LINHA0             EQU 0000h
LINHA23            EQU 1700h
PASSARO_POSINICIAL EQU 20

;PARTE II: Variaveis
                ORIG 8000h
FlagI0          WORD 0
FlagI1          WORD 0
FlagI2          WORD 0
FlagTemp        WORD 0
PosPassaro      WORD 0
MSG_INICIO1     STR  'Prepare-se', FIM_STRING
MSG_INICIO2     STR  'Prima o interruptor I1', FIM_STRING
ESPACOS         STR  '                                                                                ', FIM_STRING
TAB_LIMITE      STR  '--------------------------------------------------------------------------------', FIM_STRING
PassaroSTR      STR  'o>', FIM_STRING

;PARTE III: Interrupcoes
                ORIG FE00h
INT0            WORD  RotINT0
INT1            WORD  RotINT1
INT2            WORD  RotINT2
                ORIG  FE0Fh
INTTEMP         WORD  RotINTTemp

;PARTE IV: Código
                ORIG 0
                ;Inicializa a pilha
                MOV R1, SP_INICIAL
                MOV SP, R1
                ;Inicializa o controlo do ecra
                MOV R1, FFFFh
                MOV M[IO_CONTROL], R1
                ENI
                JMP main

;RotINT0:       Incrementa a flag I0
;               Entrada: --
;               Saida:   --
;               Efeitos: Muda M[FlagI0]
RotINT0:        INC M[FlagI0]
                RTI

;RotINT1:       Incrementa a flag I1
;               Entrada: --
;               Saida:   --
;               Efeitos: Muda M[FlagI1]
RotINT1:        INC M[FlagI1]
                RTI

;RotINT2:       Incrementa a flag I1
;               Entrada: --
;               Saida:   --
;               Efeitos: Muda M[FlagI2]
RotINT2:        INC M[FlagI2]
                RTI

;RotINTTemp:    Incrementa a flag I1
;               Entrada: --
;               Saida:   --
;               Efeitos: Muda M[FlagTemp]
RotINTTemp:     INC M[FlagTemp]
                RTI

;printChar:     Incrementa a flag I1
;               Entrada:  R1 - Caracter a escrever
;                         R2 - Posicao a escrever
;               Saida:   --
;               Efeitos: Escreve no ecra
printChar:      MOV M[IO_CONTROL], R2
                MOV M[IO_WRITE], R1
                RET


;printString:   Incrementa a flag I1
;               Entrada:  Pilha - Posicao de memoria do primeiro caracter
;               Saida:   --
;               Efeitos: Escreve no ecra, e retira uma posicao da pilha
printString:    PUSH  R1
                PUSH  R2
                PUSH  R3
                PUSH  R4
                MOV   R2, M[SP + 6] ;Posicao no ecra
                MOV   R3, M[SP + 7] ;Posicao de memoria da string
                MOV   R4, FIM_STRING
cicloPrintStr:  MOV   R1, M[R3]
                CALL  printChar
                INC   R2
                INC   R3
                CMP   M[R3], R4
                BR.NZ cicloPrintStr
                POP   R4
                POP   R3
                POP   R2
                POP   R1
                RETN 2


;limpaEcra:     limpaEcra
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
limpaEcra:      MOV R1, FFFFh
                MOV M[IO_CONTROL], R1
                RET

;desenhaEcra:   Desenha o ecra
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
desenhaEcra:    PUSH TAB_LIMITE
                PUSH LINHA0
                CALL printString
                PUSH TAB_LIMITE
                PUSH LINHA23
                CALL printString
                CALL DesenhaPassaro
                RET

;ligaLEDS:      Ativa ou desativa os leds
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
ligaLEDS:       NOP
                RET

;liga7SEG:      Desenha o ecra 7SEG
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
liga7SEG:       NOP
                RET

;desenhaLCD:    Desenha o ecra LCD
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
desenhaLCD:     NOP
                RET


;SobePassaro:
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
SobePassaro:    PUSH R1
                MOV M[FlagI0], R0
                MOV R1, 1
                CMP M[PosPassaro], R1
                BR.Z 1
                DEC M[PosPassaro]
                POP R1
                RET

;SobeNivel:
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
SobeNivel:      NOP
                RET

;DesceNivel:
;               Entrada:  --
;               Saida:   --
;               Efeitos: --
DesceNivel:     NOP
                RET


;DesenhaPassaro:
;               Entrada: --
;               Saida:   --
;               Efeitos: --
DesenhaPassaro: PUSH R1
                MOV R1, M[PosPassaro]
                SHL R1, 8
                ADD R1, 20
                PUSH  PassaroSTR
                PUSH  R1
                CALL  printString
                POP R1
                RET

main:           PUSH MSG_INICIO1
                PUSH POS_MSG_INICIO1
                CALL printString
                PUSH MSG_INICIO2
                PUSH POS_MSG_INICIO2
                CALL printString

                MOV  R1, MASCARA_INICIO
                MOV  M[MASK_CONTROL], R1

                CMP  M[FlagI1], R0
                BR.Z -3
                MOV  M[FlagI1], R0
                MOV  M[MASK_CONTROL], R0
                MOV  R1, PASSARO_POSINICIAL
                MOV  M[PosPassaro], R1
                MOV  R1, MASCARA_JOGO
                MOV  M[MASK_CONTROL], R1
cicloJogo:      CMP  M[FlagI0], R0
                CALL.NZ SobePassaro
                CMP  M[FlagI1], R0
                CALL.NZ SobeNivel
                CMP  M[FlagI2], R0
                CALL.NZ DesceNivel
                CALL limpaEcra
                CALL DesenhaPassaro
                ;CALL desenhaEcra
                BR   cicloJogo
                BR -1
