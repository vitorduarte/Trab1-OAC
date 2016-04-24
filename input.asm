# Exemplo Clear

# Clear 1 - Array
.data
size:	.word	4
array1:	.word	12, 45, 50, 33

.text

.globl main

main: 
	la $t4, size
	lw $a1, 0($t4)
	la $t5, array1
	lw $a0, 0($t5)
	jal clear2
	j exit

clear1:	move $t0,$zero
Loop1:	sll $t1,$t0,2
	add $t2,$t5,$t1
	sw $zero,0($t2)
	addi $t0,$t0,1
	slt $t3,$t0,$a1
	bne $t3,$zero,Loop1
	jr $ra
	
clear2: move $t0,$a1
Loop2:	sw $zero,0($t5)
	addi $t5,$t5,4
	addi $t0,$t0,-1
	bne $t0,$zero,Loop2
	jr $ra
exit:	
