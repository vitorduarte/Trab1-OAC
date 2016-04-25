.data

#Endereço de leitura de registradores
rs: .word 10
rt: .word 11
rd: .word 9
opcode: .word 0
shamt: .word 0
funct: .word 37
imm: .word 0
address: .word 0
tipo: .word 0
instrucao: .word 1

ErronaInstrucao: .asciiz "Erro : Valor inválido"

.text
lw $t1, instrucao
beq $t1, 1, Tipo1
j Erro

Tipo1:
	jal ArmazenaOp
	jal ArmazenaRs
	jal ArmazenaRt
	jal ArmazenaRd
	jal ArmazenaShamt
	jal ArmazenaFunct
	j Saida

ArmazenaOp:
	lw $t2, opcode
	bge $t2, 63, Erro
	sll $t2, $t2, 26	
	add $t1, $t1, $t2
	jr $ra
	
ArmazenaRs:
	lw $t2, rs
	bge $t2, 32, Erro
	sll $t2, $t2, 21
	add $t1, $t1, $t2
	jr $ra

ArmazenaRt:
	lw $t2, rt
	bge $t2, 32, Erro
	sll $t2, $t2, 16
	add $t1, $t1, $t2
	jr $ra

ArmazenaRd:
	lw $t2, rd
	bge $t2, 32, Erro
	sll $t2, $t2, 11
	add $t1, $t1, $t2
	jr $ra
	
ArmazenaShamt:
	lw $t2, shamt
	bge $t2, 32, Erro
	sll $t2, $t2, 6
	add $t1, $t1, $t2
	jr $ra

ArmazenaFunct:
	lw $t2, funct
	bge $t2, 64, Erro
	add $t1, $t1, $t2
	jr $ra



Erro:
	li $v0, 4
	la $a0, ErronaInstrucao
	syscall
	
Saida:
	li $v0, 34
	move $a0, $t1
	syscall
