.data

#Manipulação de Arquivos
ArquivoEntrada: .space 150
NomeArquivoSaida: .asciiz "./out.txt"

#Label
NomeLabel: .space 1000
EnderecoLabel: .space 400	#Espaço para registrar endereço de  100 Labels

#Instrucoes
NomeInst: .ascii "add\0addu\0"
OpcodeInst: .word 0
FunctInst: .word 32
TipoInst: .word 1

#Tipo 1 - R


BufferLeitura: .space 4000
Instrucao: .space 8

#Mensagens
DigiteArquivoEntrada: .asciiz "Digite o arquivo que deseja realizar a leitura: "

#Erros
ErroLeituraArquivo: .asciiz "ERRO 1: O arquivo não pode ser lido."

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
		jr $ra
		
EncontrarText:
	move $t0, $s2
	LoopEncontraText:
		EncontraPonto:
			lbu $t1, 0($t0)
			beq $t1, 0, FimdeLeitura	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 46, EncontraT1		#Encontrar o ponto ( .)
			j LoopEncontraText
			
		EncontraT1:
			lbu $t1, 0($t0)
			beq $t1, 0, FimdeLeitura	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 116, EncontraE		#Encontrar ( T )
			j LoopEncontraText
		
		EncontraE:
			lbu $t1, 0($t0)
			beq $t1, 0, FimdeLeitura	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 101, EncontraX 	#Encontrar ( E )
			j LoopEncontraText
		
		EncontraX:
			lbu $t1, 0($t0)
			beq $t1, 0, FimdeLeitura	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 120, EncontraT2	#Encontrar ( X )
			j LoopEncontraText
			
		EncontraT2:
			lbu $t1, 0($t0)
			beq $t1, 0, FimdeLeitura	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 116, EncontraFim 	#Encontrar ( T )
			j LoopEncontraText
			
		EncontraFim:
			lbu $t1, 0($t0)
			beq $t1, 0, FimdeLeitura	#Encontra NULL
			addi $t0, $t0, 1
			beq $t1, 32, FimdeLeitura		#Encontra Espaço
			beq $t1, 10, FimdeLeitura		#Encontra NewLine
			beq $t1, 9, FimdeLeitura		#Encontra Tab	
			j LoopEncontraText

	FimdeLeitura:
		move $s3, $t0
		jr $ra

InterpretadordeInstrucoes:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t0, $s3
	li $s4, 0
	la $t4, NomeLabel
	la $t5, EnderecoLabel
	la $t6, NomeInst 
	
	LoopInterpretador:
		lbu $t1, 0($t0)
		beq $t1, 58, NovaLabel			#Encontra ( : )
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
				beq $t1, 10, GravaPalavra
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
					beq $t1, 0, TestaOutro
					j ProximoMnemonico
					
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
				
	FimInterpretador:
		lw $ra, ($sp) 
		addi $sp, $sp, 4
		jr $ra

TrataInstrucao:
	li $v0, 1
	syscall
	jr $ra

SaidadeErro:
	li $v0, 10
	syscall	
	
Sair: