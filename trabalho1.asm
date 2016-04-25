.data

#Manipulação de Arquivos
ArquivoEntrada: .space 150
NomeArquivoSaida: .asciiz "./out.txt"

#Label
NomeLabel: .space 1000
EnderecoLabel: .space 400	#Espaço para registrar endereço de  100 Labels

#Tabela para Instrucoes
NomeInst: .ascii "add\0addu\0sub\0subu\0and\0or\0nor\0slt\0sltu\0addi\0addiu\0slti\0sltiu\0andi\0ori\0beq\0bne\0sll\0srl\0sra\0j\0jal\0jr\0lw\0lbu\0lhu\0ll\0sb\0sh\0sw\0sc\0lui\0\0mult\0multu\0div\0divu\0mfhi\0mflo\0\0"
OpcodeInst: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 9, 10, 11, 12, 13, 4, 5, 0, 1, 3, 2, 3, 0, 35, 36, 37, 48, 40, 41, 43, 56, 15, 0, 0, 0, 0, 0,0
ShamtInst: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5,5, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 9, 9, 9, 9, 10, 10
FunctInst: .word 32, 33, 34, 35, 36, 37, 39, 42, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 25, 26, 27, 16, 17  
TipoInst: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5,5, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 9, 9, 9, 9, 10, 10

#Tabela para registradores
NomeRegistrador: .asciiz "zero\0at\0v0\0v1\0a0\0a1\0a2\0a3\0t0\0t1\0t2\0t3\0t4\0t5\0t6\0t7\0s0\0s1\0s2\0s3\0s4\0s5\0s6\0s7\0t8\0t9\0k0\0k1\0gp\0sp\0fp\0ra\0\0"

#Tipo 1 - R ($rd, $rs, $rt)
#Tipo 2 - I ($rt, $rs, Imm)
#Tipo 3 - I ($rt, $rs, Label)
#Tipo 4 - I ($rd, $rt, Imm)
#Tipo 5 - J 
#Tipo 6 (jr) - R ($rs)
#Tipo 7 - I ($rt, Imm($rs) )
#Tipo 8 (lui) - I ($t, Imm) 
#Tipo 9 - R ($rs, $rt)
#Tipo 10 (mfhi,mflo) - R ($rd)

#Endereços auxiliares
BufferLeitura: .space 4000
Instrucao: .space 8
Registrador: .space 8
NewLine: .asciiz "\n"
Espaco: .asciiz " "
Tab: .asciiz "\t"

#Endereço de leitura de registradores
rs: .word 0
rt: .word 0
rd: .word 0
opcode: .word 0
shamt: .word 0
funct: .word 0
imm: .word 0
address: .word 0
tipo: .word 0

#Mensagens
DigiteArquivoEntrada: .asciiz "Digite o arquivo que deseja realizar a leitura: "

#Erros
ErroLeituraArquivo: .asciiz "ERRO 1: O arquivo não pode ser lido."
ErronoMnemonico: .asciiz "ERRO 2: Uma instrução não pode ser interpretada."
ErronaSintaxe: .asciiz "ERRO 3: Erro na sintaxe, verifique os argumentos da instrução"
ErronoRegistrador: .asciiz "ERRO 4: Erro na leitura dos registradores."
ErronoText: .asciiz "ERRO 5: Referencia .text não encontrada"

#s0 - Endereço do arquivo de leitura de dados
#s1 - Endereço do arquivo de gravação de dados
#s2 - Endereço de memoria dos dados lidos do arquivo de entrada
#s3 - Posição de inicio do .text
#s4 - Contador de instruções
#s5 

.text

Main:
	jal NomeArquivodeEntrada
	jal AbrirArquivodeEntrada
	jal LerArquivoEntrada
	jal EncontrarText
	jal InterpretadordeInstrucoes
	j Sair
		
NomeArquivodeEntrada:
	li $v0, 4		
	la $a0, DigiteArquivoEntrada
	syscall
	
	li $v0, 8		
	la $a0, ArquivoEntrada
	li $a1, 150
	syscall
	
	la $t0, ArquivoEntrada
	
	EncontrarNewLine:
		lb $t1, 0($t0)
		beq $t1, 10, RemoverNewLine
		addi $t0, $t0, 1
		j EncontrarNewLine
	
	RemoverNewLine:
		li $t1, 0
		sb $t1, 0($t0)
		jr $ra
		
AbrirArquivodeEntrada:
	li $v0, 13
	la $a0, ArquivoEntrada
	li $a1, 0			#Leitura
	li $a2, 0
	syscall
	
	beq $v0, -1, ErroLeitura
	move $s0, $v0			#Endereço do arquivo lido
	jr $ra
	
	ErroLeitura:
		li $v0, 4
		la $a0, ErroLeituraArquivo
		syscall
		j SaidadeErro

LerArquivoEntrada:
	la $s2, BufferLeitura
	move $t0, $s2
	LoopLeitura:
		li $v0, 14
		move $a0, $s0
		move $a1, $t0
		li $a2, 1
		syscall
		beq $v0, 0, FimArquivo
		lbu $t1, 0($t0)
		beq $t1, 35, PulaLinha		#Encontra  #	
		beq $t1, 10, LinhaDupla		#Encontra #
		addi $t0, $t0, 1
		j LoopLeitura
		
	PulaLinha:
		li $v0, 14		
		move $a0, $s0			
		move $a1, $t0		
		li $a2, 1			
		syscall
		beq $v0, 0, FimArquivo
		lbu $t1, 0($t0)
		beq $t1, 10, AcabouLinha	#Encontra NewLine
		j PulaLinha
			
		AcabouLinha:
			addi $t0, $t0, 1
			lbu $t3, -1($t0)
			beq $t3, 10, LoopLeitura
			sb $t1, 0($t0)
			j LoopLeitura
	
	LinhaDupla:
		#Verifica se a linha é vazia
		lbu $t3, -1($t0)
		beq $t3, 10, LoopLeitura
		addi $t0, $t0, 1
		j LoopLeitura
		
	FimArquivo:
		li $v0, 16	#Fecha arquivo de leitura
		move $a0, $s0
		syscall
		jr $ra
		
EncontrarText:
	move $t0, $s2
	LoopEncontraText:
		EncontraPonto:
			lbu $t1, 0($t0)
			beq $t1, 0, ErroText	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 46, EncontraT1		#Encontrar o ponto ( .)
			j LoopEncontraText
			
		EncontraT1:
			lbu $t1, 0($t0)
			beq $t1, 0,  ErroText	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 116, EncontraE		#Encontrar ( T )
			j LoopEncontraText
		
		EncontraE:
			lbu $t1, 0($t0)
			beq $t1, 0,  ErroText	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 101, EncontraX 	#Encontrar ( E )
			j LoopEncontraText
		
		EncontraX:
			lbu $t1, 0($t0)
			beq $t1, 0,  ErroText	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 120, EncontraT2	#Encontrar ( X )
			j LoopEncontraText
			
		EncontraT2:
			lbu $t1, 0($t0)
			beq $t1, 0,  ErroText	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 116, EncontraFim 	#Encontrar ( T )
			j LoopEncontraText
			
		EncontraFim:
			lbu $t1, 0($t0)
			beq $t1, 0, TextEncontrado	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 32, TextEncontrado		#Encontra Espaço
			beq $t1, 10, TextEncontrado		#Encontra NewLine
			beq $t1, 9, TextEncontrado		#Encontra Tab	
			j LoopEncontraText

	ErroText:
		li $v0, 4
		la $a0, ErronoText
		j SaidadeErro
	TextEncontrado:
		move $s3, $t0
		jr $ra

InterpretadordeInstrucoes:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	move $t0, $s3
	li $s4, 0
	la $t4, NomeLabel
	la $t5, EnderecoLabel
	la $t6, NomeInst 
	
	LoopInterpretador:
		lbu $t1, 0($t0)
		beq $t1, 58, NovaLabel			#Encontra ( : )
		beq $t1, 46, NovaReferencia		#Encontra ( . )
		beq $t1, 32, NovaInstrucao		#Encontra Espaço
		beq $t1, 9, NovaInstrucao		#Encontra Tab
		beq $t1, 0, FimInterpretador 		#Encontra NULL
		addi $t0, $t0, 1
		j LoopInterpretador
		
		NovaInstrucao:
			lbu $t1, -1($t0)
			addi $t0, $t0, 1
			beq $t1, 58, LoopInterpretador		#Encontra ( : )
			beq $t1, 32, LoopInterpretador		#Encontra Espaço
			beq $t1, 9, LoopInterpretador		#Encontra Tab
			beq $t1, 10, LoopInterpretador		#Encontra NewLine
			move $t2, $t0
			addi $s4, $s4, 1
			
			InicioInstrucao:
				addi $t2, $t2, -1
				lbu $t1, -1($t2)
				beq $t1, 9, GravaPalavra
				beq $t1, 10, GravaPalavra
				beq $t1, 32, GravaPalavra
				j InicioInstrucao
			GravaPalavra:
				la $t6, NomeInst 
				la $t7, Instrucao
				addi $t3, $t0, -2
				
				LoopGravaPalavra:
					lbu $t1, 0($t2)
					sb $t1, 0($t7)
					beq $t2, $t3, GravaFim
					addi $t2, $t2, 1
					addi $t7, $t7, 1
					j LoopGravaPalavra 
					
					GravaFim:
						addi $t7, $t7, 1
						li $t1, 0
						sb $t1, 0($t7)
						j EncontraMnemonico
						
			EncontraMnemonico:
				la $t7, Instrucao
				li $t3, 0
				
				LoopEncontraMnemonico:
					lbu $t1, 0($t7)
					lbu $t2, 0($t6)
					bne $t1, $t2, ProximoMnemonico
					beq $t1, 0, ArmazenaMnemonico
					addi $t7, $t7, 1
					addi $t6, $t6, 1
					j LoopEncontraMnemonico
				
				ProximoMnemonico:
					lbu $t1, 0($t6)
					addi $t6, $t6, 1
					beq $t1, 0, VerificaFim
					j ProximoMnemonico
					
					VerificaFim:
						lbu $t1, 1($t6)
						beq $t1, 0, ErroMnemonico
						j TestaOutro
					
					ErroMnemonico:
						li $v0, 4
						la $a0, ErronoMnemonico
						syscall
						j SaidadeErro
							
					TestaOutro:
						addi $t3, $t3, 1
						la $t7, Instrucao
						j LoopEncontraMnemonico
				
				ArmazenaMnemonico:
					move $a0, $t3			#Armazena o numero correspondente a função
					jal TrataInstrucao
					j ProximaLinha
					j Sair
			
			ProximaLinha:
				lbu $t1, 0($t0)
				beq $t1, 10, LoopInterpretador		#Encontra NewLine
				beq $t1, 0, FimInterpretador		#Encontra Fim Arquivo
				addi $t0, $t0, 1
				j ProximaLinha	
		
		NovaLabel:
			addi $s4, $s4, 1
			sw $s4, 0($t5)			#Grava endereço correspondente a Label encontrada
			addi $t5, $t5, 4 
			move $t1, $t0
			move $t2, $t0
			addi $t2, $t2, -1
			
			IniciodaLabel:
				addi $t1, $t1, -1
				lbu $t3, -1($t1)
				beq $t3, 10, GravaLabel		#Encontra NewLine
				beq $t3, 9, GravaLabel		#Encontra Tab
				beq $t3, 32, GravaLabel		#Encontra Espaço
				j IniciodaLabel
			
			GravaLabel:
				lbu $t3, 0($t1)
				sb $t3, 0($t4)
				beq $t1, $t2, FimNovaLabel
				addi $t1, $t1, 1
				addi $t4, $t4, 1
				j GravaLabel
			
			FimNovaLabel:
				lui $t3, 0
				addi $t4, $t4, 1
				sb $t3, 0($t4)
				addi $t0, $t0, 2
				addi $t4, $t4, 1
				j LoopInterpretador
	
		NovaReferencia:
			lbu $t1, 0($t0)
			addi $t0, $t0, 1
			beq $t1, 10, FimNovaReferencia
			j NovaReferencia
			
			FimNovaReferencia:
				j LoopInterpretador
				
	FimInterpretador:
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra

TrataInstrucao:
	#Recebe $a0 - Numero da instrução
	addi $sp, $sp, -4
	sw $ra, ($sp)
	mul $t1, $a0, 4 
	lw $t2, TipoInst($t1)
	sw $t2, tipo
	beq $t2, 1, Tipo1
	
		Tipo1:
			EncontraRd:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRd		#Encontra espaço
				beq $t2, 9, EncontraRd		#Encontra tab
				beq $t2, 36, LerRd		#Encontra $
				j ErrodeSintaxe
				
			LerRd:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rd
				move $t0, $v1
				j EncontraRs
			
			EncontraRs:
				VirgulaRs:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaRs		#Encontra tab
					beq $t2, 32, VirgulaRs		#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				CifraoRs:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRs		#Encontra espaço
					beq $t2, 9, CifraoRs		#Encontra tab
					beq $t2, 36, LerRs		#Encontra $
					j ErrodeSintaxe
			LerRs:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rs
				move $t0, $v1
				j EncontraRt
				
			EncontraRt:
				VirgulaRt:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaRt		#Encontra tab
					beq $t2, 32, VirgulaRt		#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				CifraoRt:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRt		#Encontra espaço
					beq $t2, 9, CifraoRt		#Encontra tab
					beq $t2, 36, LerRt		#Encontra $
					j ErrodeSintaxe
			LerRt:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rt
				move $t0, $v1
			
			DadosTipo1:
				move $a0, $t1
				jal ObtemOpcode
				jal ObtemShamt
				jal ObtemFunct
				#jal GeraHexa
				j FimTrataInstrucao
				
			ErrodeSintaxe:
				li $v0, 4
				la $a0, ErronaSintaxe
				syscall
				j SaidadeErro
				
	mul $t1, $t1, 4
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, Tab
	syscall
	li $v0, 1
	lw $a0, TipoInst($t1)
	syscall
	li $v0, 4
	la $a0, NewLine
	syscall
	FimTrataInstrucao:
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
	
ObtemRegistrador:
	#Recebe $a0 - Endereço do começo do registrador
	#Retorna $v0 - Valor do registrador lido
		#Se não encontrado  $v0 = -1
	#Retorna $v1  - Endereço do fim do registrador
	la $t3, Registrador
	SalvaRegistrador:
		lbu $t2, 0($a0)
		beq $t2, 32, RegistCompleto		#Encontra espaço
		beq $t2, 9, RegistCompleto		#Encontra Tab
		beq $t2, 44, RegistCompleto		#Encontra Vírgula
		beq $t2, 10, RegistCompleto		#Encontra NewLine
		beq $t2, 0, RegistCompleto		#Encontra Fim
		sb  $t2, ($t3)
		addi $a0, $a0, 1
		addi $t3, $t3, 1
		j SalvaRegistrador
		
		RegistCompleto:
			move $v1, $a0
			li $t2, 0
			addi $t3, $t3, 1
			sb $t2, ($t3)
			j ComparaRegistrador
	
	ComparaRegistrador:
		la $t2, Registrador
		la $t3, NomeRegistrador
		li $t9, 0
		
		LoopComparaRegist:
			lbu $t7, ($t2)
			lbu $t8, ($t3)
			bne $t7, $t8, ProximoRegist
			beq $t7, 0, RegistEncontrado
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			j LoopComparaRegist
			
			ProximoRegist:
				lbu $t7, ($t3)
				addi $t3, $t3, 1
				beq $t7, 0, VerificaFimComparacao
				j ProximoRegist
				
				VerificaFimComparacao:
					lbu $t7, ($t3)
					beq $t7, 0, RegistInvalido
					j TestaOutroRegist
				
				TestaOutroRegist:
					addi $t9, $t9, 1
					la $t2, Registrador
					j LoopComparaRegist
					
		RegistInvalido:
			li $v0, 4
			la $a0, ErronoRegistrador
			syscall
			j SaidadeErro
		
		RegistEncontrado:
			move $v0, $t9
			jr $ra

ObtemOpcode:
	lw $t2, OpcodeInst($a0)
	sw $t2, opcode
	jr $ra
	
ObtemShamt:
	lw $t2, ShamtInst($a0)
	sw $t2, shamt
	jr $ra
ObtemFunct:
	lw $t2, FunctInst($a0)
	sw $t2, funct
	jr $ra

SaidadeErro:
	li $v0, 10
	syscall	
	
Sair:
