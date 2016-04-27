#Arquivo de teste de instruçoes suportadas

.text
label1:
add $t1,  $t2, $t3
addu $s1,  $t2, $t6
sub  $s1,  $t2, $t3
subu $s0,  $t2, $t3
and $t2, $t0, $t9
or $t4,  $t1, $t6
nor $t1, $t5, $t3
slt $a0, $t3, $t4
sltu $a1, $a3, $s3
addi $t1, $t2, 2
addiu $t1, $t2, 2
slti $t2, $s0, 4
sltiu $a0, $a1, 31
andi $t2, $t5, 5
label2:
ori $t4, $t5, 21
jr $ra
lui $t1, 21
mult $t1, $t6
multu $a0, $v1
div $a1, $t5
divu $a1, $t3
mfhi $t1
mflo $v0
    label4:
sll $t1, $t4, 20
srl $t3, $t1, 3
sra $t5, $t7, 12
lw $t2, 4($t4)
        label5:
lbu $t2, 3($t2)
lhu $t4, 9($t4)
ll $s0, 1($t2)
sb $t2, 4($t4)
sh $t2, 3($t2)
sw $t6, 4($t1)
sc $a0, 43($t0)
j label2
jal label1
jal label4
j label6
label6:
