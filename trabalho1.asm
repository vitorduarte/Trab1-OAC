.data

#Manipulação de Arquivos
ArquivoEntrada: .space 150
NomeArquivoSaida: .asciiz "out.s"

#Label
NomeLabel: .space 1000
EnderecoLabel: .space 400	#Espaço para registrar endereço de  100 Labels

#Tabela para Instrucoes
NomeInst: .ascii "add\0addu\0sub\0subu\0and\0or\0nor\0slt\0sltu\0addi\0addiu\0slti\0sltiu\0andi\0ori\0beq\0bne\0sll\0srl\0sra\0j\0jal\0jr\0lw\0lbu\0lhu\0ll\0sb\0sh\0sw\0sc\0lui\0mult\0multu\0div\0divu\0mfhi\0mflo\0move\0li\0blt\0bgt\0ble\0bge\0\0"
OpcodeInst: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 9, 10, 11, 12, 13, 4, 5, 0, 0, 0, 2, 3, 0, 35, 36, 37, 48, 40, 41, 43, 56, 15, 0, 0, 0, 0, 0,0
FunctInst: .word 32, 33, 34, 35, 36, 37, 39, 42, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 25, 26, 27, 16, 18  
TipoInst: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5,5, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 9, 9, 9, 9, 10, 10

#Tabela para registradores
NomeRegistrador: .asciiz "zero\0at\0v0\0v1\0a0\0a1\0a2\0a3\0t0\0t1\0t2\0t3\0t4\0t5\0t6\0t7\0s0\0s1\0s2\0s3\0s4\0s5\0s6\0s7\0t8\0t9\0k0\0k1\0gp\0sp\0fp\0ra\0\0"

#Tabela para conversão para hexadecimal
CaractereHexa:	.byte	'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'

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
Label: .space 50
NewLine: .asciiz "\n"
Espaco: .asciiz " "
Tab: .asciiz "\t"
InstrucaoHexa:	.byte	0,0,0,0,0,0,0,0,'\n'			# onde vai ser escrito a instrucao, ultimo byte \n


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
instrucao: .word 0
label: .word 0

#Mensagens
DigiteArquivoEntrada: .asciiz "Digite o arquivo que deseja realizar a leitura: "

#Erros
ErroLeituraArquivo: .asciiz "ERRO 1: O arquivo não pode ser lido."
ErronoMnemonico: .asciiz "ERRO 2: Uma instrução não pode ser interpretada."
ErronaSintaxe: .asciiz "ERRO 3: Erro na sintaxe, verifique os argumentos da instrução"
ErronoRegistrador: .asciiz "ERRO 4: Erro na leitura dos registradores."
ErronoText: .asciiz "ERRO 5: Referencia .text não encontrada"
ErronaConversao: .asciiz "ERRO 6: Erro na conversão para hexadecimal"
ErronaCriacaoArquivo: .asciiz "ERRO 7: Erro na criação do arquivo de gravação de dados"
ErronaLeituraImm: .asciiz "ERRO 8: Erro na leitura do imediato"
ErronnotipoInstrucao: .asciiz "ERRO 9: Essa instrução ainda não é suportada pelo nosso montador"
ErronaLabel: .asciiz "ERRO 10: Label informada não foi encontrada"

#s0 - Endereço do arquivo de leitura de dados
#s1 - Endereço do arquivo de gravação de dados
#s2 - Endereço de memoria dos dados lidos do arquivo de entrada
#s3 - Posição de inicio do .text
#s4 - Contador de instruções



.text

Main:
	jal NomeArquivodeEntrada
	jal AbrirArquivodeEntrada
	jal LerArquivoEntrada
	jal CriarArquivodeSaida
	jal EncontrarText
	jal InterpretadordeInstrucoes
	jal FechaArquivodeSaida
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

CriarArquivodeSaida:
	li $v0, 13
	la $a0, NomeArquivoSaida
	li $a1, 1			#Escrita
	li $a2, 0
	syscall
	
	beq $v0, -1, ErroCriacaoArquivo
	move $s1, $v0			#Endereço do arquivo lido
	jr $ra
	
	ErroCriacaoArquivo:
		li $v0, 4
		la $a0, ErronaCriacaoArquivo
		syscall
		j SaidadeErro
		
FechaArquivodeSaida:
	li $v0, 16
	move $a0, $s1
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
						lbu $t1, 0($t6)
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
					bge $t3, 39, ContaPseudo
					addi $s4, $s4, 1
					jal TrataInstrucao
					j ProximaLinha
					j Sair
				
				ContaPseudo:
					addi $s4, $s4, 2
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
	beq $t2, 2, Tipo2
	beq $t2, 4, Tipo4
	beq $t2, 5, Tipo5
	beq $t2, 6, Tipo6
	beq $t2, 7, Tipo7
	beq $t2, 8, Tipo8
	beq $t2, 9, Tipo9
	beq $t2, 10, Tipo10
	j InstrucaonaoSuportada
	
		Tipo1:
			EncontraRd1:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRd1		#Encontra espaço
				beq $t2, 9, EncontraRd1		#Encontra tab
				beq $t2, 36, LerRd1		#Encontra $
				j ErrodeSintaxe
				
			LerRd1:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rd
				move $t0, $v1
				j EncontraRs1
			
			EncontraRs1:
				VirgulaRs1:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaRs1		#Encontra tab
					beq $t2, 32, VirgulaRs1		#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				CifraoRs1:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRs1		#Encontra espaço
					beq $t2, 9, CifraoRs1		#Encontra tab
					beq $t2, 36, LerRs1		#Encontra $
					j ErrodeSintaxe
			LerRs1:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rs
				move $t0, $v1
				j EncontraRt1
				
			EncontraRt1:
				VirgulaRt1:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaRt1		#Encontra tab
					beq $t2, 32, VirgulaRt1		#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				CifraoRt1:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRt1		#Encontra espaço
					beq $t2, 9, CifraoRt1		#Encontra tab
					beq $t2, 36, LerRt1		#Encontra $
					j ErrodeSintaxe
			LerRt1:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rt
				move $t0, $v1
			
			DadosTipo1:
				move $a0, $t1
				jal ObtemOpcode
				move $a0, $t1
				sw $zero, shamt
				move $a0, $t1
				jal ObtemFunct
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
				
		Tipo2:
			EncontraRt2:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRt2	#Encontra espaço
				beq $t2, 9, EncontraRt2		#Encontra tab
				beq $t2, 36, LerRt2		#Encontra $
				j ErrodeSintaxe
				
			LerRt2:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rt
				move $t0, $v1
				j EncontraRs2
			
			EncontraRs2:
				VirgulaRs2:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaRs2		#Encontra tab
					beq $t2, 32, VirgulaRs2		#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				CifraoRs2:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRs2		#Encontra espaço
					beq $t2, 9, CifraoRs2		#Encontra tab
					beq $t2, 36, LerRs2		#Encontra $
					j ErrodeSintaxe
					
			LerRs2:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rs
				move $t0, $v1
				j EncontraImm2
				
			EncontraImm2:
				VirgulaImm2:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaImm2		#Encontra tab
					beq $t2, 32, VirgulaImm2	#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				LerImm2:
					move $a0, $t0
					jal ObtemImediato
					sw $v0, imm
					move $t0, $v1
					
			DadosTipo2:
				move $a0, $t1
				jal ObtemOpcode
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
					
		Tipo4:
			EncontraRd4:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRd4	#Encontra espaço
				beq $t2, 9, EncontraRd4		#Encontra tab
				beq $t2, 36, LerRd4		#Encontra $
				j ErrodeSintaxe
				
			LerRd4:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rd
				move $t0, $v1
				j EncontraRt4
			
			EncontraRt4:
				VirgulaRt4:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaRt4		#Encontra tab
					beq $t2, 32, VirgulaRt4		#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				CifraoRt4:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRt4		#Encontra espaço
					beq $t2, 9, CifraoRt4		#Encontra tab
					beq $t2, 36, LerRt4		#Encontra $
					j ErrodeSintaxe
			LerRt4:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rt
				move $t0, $v1
				j EncontraImm4
			
			EncontraImm4:
				VirgulaImm4:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaImm4		#Encontra tab
					beq $t2, 32, VirgulaImm4	#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				LerImm4:
					move $a0, $t0
					jal ObtemImediato
					sw $v0, shamt
					move $t0, $v1
					j DadosTipo4
				
			DadosTipo4:
				move $a0, $t1
				jal ObtemOpcode		
				move $a0, $t1
				jal ObtemFunct
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
				
		Tipo5:
			EncontraLabel5:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraLabel5	#Encontra espaço
				beq $t2, 9, EncontraLabel5	#Encontra tab
				beq $t2, 36, ErrodeSintaxe	#Encontra $
				j LerLabel5
				
			LerLabel5:
				move $a0, $t0
				jal ObtemLabel
				sw $v0, label
				move $t0, $v1
				j DadosTipo5
			
			DadosTipo5:
				move $a0, $t1
				jal ObtemOpcode
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
			
		Tipo6:
			EncontraRs6:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRs6	#Encontra espaço
				beq $t2, 9, EncontraRs6		#Encontra tab
				beq $t2, 36, LerRs6		#Encontra $
				j ErrodeSintaxe
			
			LerRs6:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rs
				move $t0, $v1
			
			DadosTipo6:
				move $a0, $t1
				jal ObtemOpcode
				move $a0, $t1
				sw $zero, shamt
				move $a0, $t1
				jal ObtemFunct
				sw $zero, rt
				sw $zero, rd
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
		Tipo7:
			EncontraRt7:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRt7	#Encontra espaço
				beq $t2, 9, EncontraRt7		#Encontra tab
				beq $t2, 36, LerRt7		#Encontra $
				j ErrodeSintaxe
			
			LerRt7:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rt
				move $t0, $v1
				j EncontraImm7
			
			EncontraImm7:
				VirgulaImm7:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaImm7		#Encontra tab
					beq $t2, 32, VirgulaImm7	#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				LerImm7:
					move $a0, $t0
					jal ObtemImediato
					sw $v0, imm
					move $t0, $v1
					addi $t0, $t0, 1
					j EncontraRs7
					
			EncontraRs7:
				ParentesesRs7:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, ParentesesRs7	#Encontra espaço
					beq $t2, 9, ParentesesRs7	#Encontra tab
					bne $t2, 40, ErrodeSintaxe	#Encontra ' ( '
				
				CifraoRs7:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRs7		#Encontra espaço
					beq $t2, 9, CifraoRs7		#Encontra tab
					beq $t2, 36, LerRs7		#Encontra $
					j ErrodeSintaxe
					
				LerRs7:
					move $a0, $t0
					jal ObtemRegistrador
					sw $v0, rs
					move $t0, $v1
				
			DadosTipo7:
				move $a0, $t1
				jal ObtemOpcode
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
				
		Tipo8:
			EncontraRt8:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRt8	#Encontra espaço
				beq $t2, 9, EncontraRt8		#Encontra tab
				beq $t2, 36, LerRt8		#Encontra $
				j ErrodeSintaxe
				
			LerRt8:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rt
				move $t0, $v1
				j EncontraImm8
			
			EncontraImm8:
				VirgulaImm8:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaImm8		#Encontra tab
					beq $t2, 32, VirgulaImm8	#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				LerImm8:
					move $a0, $t0
					jal ObtemImediato
					sw $v0, imm
					move $t0, $v1
					
			DadosTipo8:
				move $a0, $t1
				jal ObtemOpcode
				sw $zero, rs
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
		
		Tipo9:
			EncontraRs9:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRs9	#Encontra espaço
				beq $t2, 9, EncontraRs9		#Encontra tab
				beq $t2, 36, LerRs9		#Encontra $
				j ErrodeSintaxe
				
			LerRs9:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rs
				move $t0, $v1
				j EncontraRt9
				
			EncontraRt9:
				VirgulaRt9:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 9, VirgulaRt9		#Encontra tab
					beq $t2, 32, VirgulaRt9		#Encontra espaço
					bne $t2, 44, ErrodeSintaxe	#Encontra virgula
				
				CifraoRt9:
					lbu $t2, ($t0)
					addi $t0, $t0, 1
					beq $t2, 32, CifraoRt9		#Encontra espaço
					beq $t2, 9, CifraoRt9		#Encontra tab
					beq $t2, 36, LerRt9		#Encontra $
					j ErrodeSintaxe
			LerRt9:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rt
				move $t0, $v1
				
			DadosTipo9:
				move $a0, $t1
				jal ObtemOpcode
				move $a0, $t1
				sw $zero, shamt
				move $a0, $t1
				jal ObtemFunct
				sw $zero, rd
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
		
		Tipo10:
			EncontraRd10:
				lbu $t2, ($t0)
				addi $t0, $t0, 1
				beq $t2, 32, EncontraRd10	#Encontra espaço
				beq $t2, 9, EncontraRd10		#Encontra tab
				beq $t2, 36, LerRd10		#Encontra $
				j ErrodeSintaxe
				
			LerRd10:
				move $a0, $t0
				jal ObtemRegistrador
				sw $v0, rd
				move $t0, $v1
			
			DadosTipo10:
				move $a0, $t1
				jal ObtemOpcode
				move $a0, $t1
				sw $zero, shamt
				move $a0, $t1
				jal ObtemFunct
				sw $zero, rs
				sw $zero, rt
				jal GeraHex
				jal GravaInstrucao
				j FimTrataInstrucao
			
					
				
		ErrodeSintaxe:
			li $v0, 4
			la $a0, ErronaSintaxe
			syscall
			j SaidadeErro
				
	FimTrataInstrucao:
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra

InstrucaonaoSuportada:
	li $v0, 4
	la $a0, ErronnotipoInstrucao
ObtemRegistrador:
	#Recebe $a0 - Endereço do começo do registrador
	#Retorna $v0 - Valor do registrador lido
	#Retorna $v1  - Endereço do fim do registrador
	la $t3, Registrador
	SalvaRegistrador:
		lbu $t2, 0($a0)
		beq $t2, 32, RegistCompleto		#Encontra espaço
		beq $t2, 9, RegistCompleto		#Encontra Tab
		beq $t2, 44, RegistCompleto		#Encontra Vírgula
		beq $t2, 10, RegistCompleto		#Encontra NewLine
		beq $t2, 41, RegistCompleto		#Encontra fim parenteses " ) "
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
			
ObtemImediato:
	#Recebe $a0 - Endereço do começo do imediato
	#Retorna $v0 - Valor lido
	#Retorna $v1  - Endereço do fim do imediato
	move $t2, $zero
	move $t9, $zero
	li $t8, 1
	
	LoopObtemImediato:
		lb $t7, ($a0)
		addi $a0, $a0, 1
		beq $t7, 32, LoopObtemImediato		#Verifica Espaço
		beq $t7, 9, LoopObtemImediato		#Verifica Tab
		bltu $t7, 48, ImmInvalido
		bgtu $t7, 58, ImmInvalido
		addi $a0, $a0, -1
		j ObtemFimImediato
		
		ImmInvalido:
			li $v0, 4
			la $a0, ErronaLeituraImm
			syscall
			j SaidadeErro
		
		ObtemFimImediato:
			lb $t7, ($a0)
			addi $a0, $a0, 1
			addi $t2, $t2, 1
			beq $t7, 32, CalculoImediato	#Verifica Espaço
			beq $t7, 9, CalculoImediato	#Verifica Tab
			beq $t7, 10, CalculoImediato	#Verifica NewLine
			beq $t7, 40, CalculoImediato	#Verifica Parenteses " ( "
			beq $t7, 0, CalculoImediato	#Verifica final do arquivo
			bltu $t7, 48, ImmInvalido
			bgtu $t7, 58, ImmInvalido
			j ObtemFimImediato
			
	CalculoImediato:
		addi $a0, $a0, -2			#Volta para o local do digito das unidades
		move $v1, $a0				#Retorna o endereço do fim do mnemonico
		
		LoopCalculoImediato:
			lb $t7, ($a0)
			beq $t2, 1, FimCalculo 		#Verifica fim da leitura
			addi $t7, $t7, -48		#Converte de ascii para valor numerico
			mul $t7, $t7, $t8
			mul $t8, $t8, 10 
			addi $a0, $a0, -1
			addi $t2, $t2, -1
			add $t9, $t9, $t7
			j LoopCalculoImediato
			
		FimCalculo:
			move $v0, $t9
			jr $ra
ObtemLabel:
	#Recebe $a0 - Endereço do começo da label
	#Retorna $v0 - Endereço da label
	#Retorna $v1  - Endereço do fim da label
	addi $a0, $a0, -1
	move $t2, $a0
	la $t3, NomeLabel 
	move $t9, $zero			#Contador
	
	LoopObtemLabel:
		lb $t7, ($t2)
		lb $t8, ($t3)
		beq $t7, 32, ObtemEndereco	#Verifica Espaço
		beq $t7, 9, ObtemEndereco	#Verifica Tab
		beq $t7, 10, ObtemEndereco	#Verifica NewLine
		beq $t7, 0, ObtemEndereco	#Verifica final do arquivo
		bne $t8, $t7, EncontraNovaLabel
		addi $t2, $t2, 1
		addi $t3, $t3, 1
		j LoopObtemLabel
			
			EncontraNovaLabel:
				lb $t8, ($t3)
				addi $t3, $t3, 1
				beq $t8, 0, TestaFim
				j EncontraNovaLabel
				
			TestaFim:
				lb $t8, ($t3)
				beq $t8, 0, ErrodeLabel
				j TestaNovaLabel
				
			TestaNovaLabel:
				addi $t9, $t9, 1
				move $t2, $a0
				j LoopObtemLabel
				
	ObtemEndereco:
		move $v1, $t2			#Retorno V1
		mul $t9, $t9, 4			#Multiplicação para obter a word
		lw $t7, EnderecoLabel($t9)
		mul $t7, $t7, 4			#Multiplicação devivo aos acrescimos serem feitos de 4 em 4
		addi $t7, $t7, 0x00400000	#Adição da constante de endereçamento para .text
		move $v0, $t7			#Retorno V0
		jr $ra
	
	ErrodeLabel:
		li $v0, 4
		la $a0, ErronaLabel
		syscall
		j SaidadeErro
	
ObtemOpcode:
	lw $t2, OpcodeInst($a0)
	sw $t2, opcode
	jr $ra
	
ObtemFunct:
	lw $t2, FunctInst($a0)
	sw $t2, funct
	jr $ra

GeraHex:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	lw $t1, tipo
	beq $t1, 1, HexTipoR
	beq $t1, 2, HexTipoI
	beq $t1, 4, HexTipoR
	beq $t1, 5, HexTipoJ
	beq $t1, 6, HexTipoR
	beq $t1, 7, HexTipoI
	beq $t1, 8, HexTipoI
	beq $t1, 9, HexTipoR
	beq $t1, 10, HexTipoR
	j ErrodeConversao

	HexTipoR:
		lw $t1, instrucao
		move $t1, $zero
		jal ArmazenaOp
		jal ArmazenaRs
		jal ArmazenaRt
		jal ArmazenaRd
		jal ArmazenaShamt
		jal ArmazenaFunct
		move $a0, $t1
		jal ConverteHex
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
		
	HexTipoI:
		lw $t1, instrucao
		move $t1, $zero
		jal ArmazenaOp	
		jal ArmazenaRs
		jal ArmazenaRt
		jal ArmazenaImm
		move $a0, $t1
		jal ConverteHex
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
	
	HexTipoJ:
		lw $t1, instrucao
		move $t1, $zero
		jal ArmazenaOp
		jal ArmazenaEndereco
		move $a0, $t1
		jal ConverteHex
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra

ArmazenaOp:
	lw $t2, opcode
	bge $t2, 63, ErrodeConversao
	sll $t2, $t2, 26	
	add $t1, $t1, $t2
	jr $ra
	
ArmazenaRs:
	lw $t2, rs
	bge $t2, 32, ErrodeConversao
	sll $t2, $t2, 21
	add $t1, $t1, $t2
	jr $ra

ArmazenaRt:
	lw $t2, rt
	bge $t2, 32, ErrodeConversao
	sll $t2, $t2, 16
	add $t1, $t1, $t2
	jr $ra

ArmazenaRd:
	lw $t2, rd
	bge $t2, 32, ErrodeConversao
	sll $t2, $t2, 11
	add $t1, $t1, $t2
	jr $ra
	
ArmazenaShamt:
	lw $t2, shamt
	bge $t2, 32, ErrodeConversao
	sll $t2, $t2, 6
	add $t1, $t1, $t2
	jr $ra

ArmazenaFunct:
	lw $t2, funct
	bge $t2, 64, ErrodeConversao
	add $t1, $t1, $t2
	jr $ra
	
ArmazenaImm:
	lw $t2, imm
	bge $t2, 0xFFFF, ErrodeConversao	#Verifica valor maximo do imediato
	add $t1, $t1, $t2
	jr $ra

ArmazenaEndereco:
	lw $t2, label
	bge $t2, 0x3FFFFFF, ErrodeConversao
	srl $t2, $t2, 2
	add $t1, $t1, $t2
	jr $ra

ErrodeConversao:
	li $v0, 4
	la $a0, ErronaConversao
	syscall
	j SaidadeErro

ConverteHex:
	li $t1, 8			# numeros de bytes para converter
	la $t2, CaractereHexa		# endereco do vetor de caracteres
	la $t3, InstrucaoHexa+7		# endereco do InstrucaoHexa
	
	LoopConverteHex:	
		andi $t7, $a0, 0xF			# mascaramento
		add $t8, $t2, $t7			# somar o valor do digito com o endereco de hexa para pegar o endereco do digito
		lb $t8, 0($t8)			# pegar o valor ascci do digito
		sb $t8, 0($t3)			# salvar o valor ascci no InstrucaoHexa
		srl $a0, $a0, 4			# pegar os proximos 4 digitos da instrucao
		addi $t3, $t3, -1			# andar na posicao do InstrucaoHexa
		addi $t1, $t1, -1			# decrementar $t1 para saber que andou para o proximo digito
		bne $t1, $0, LoopConverteHex		# checar se tem mais digitos
	
	ImprimeTela:
		la $a0, InstrucaoHexa
		li $v0, 4			# mudar para escrever em arquivo
		syscall
		jr $ra
		
GravaInstrucao:
	li $v0, 15
	move $a0, $s1
	la $a1, InstrucaoHexa($zero)
	la $a2, 9
	syscall
	jr $ra

SaidadeErro:
	li $v0, 10
	syscall	
	
Sair:
