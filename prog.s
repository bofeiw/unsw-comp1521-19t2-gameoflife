# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by Bofei Wang, July 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

## pre defined data
	.align 2
	.data
MSG_ITERATION:	.asciiz	"# Iterations: "
MSG_AFTERITER_1:	.asciiz	"=== After iteration "
MSG_AFTERITER_2:	.asciiz " ===\n"
MSG_CHAR_DOT:	.word '.'
MSG_CHAR_HASH:	.word '#'
MSG_NEWLINE:	.word '\n'

## variables in main
	.align 2
maxiters:	.space 4
main__n:	.space 4
main__i:	.space 4
main__j:	.space 4

## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow

# .TEXT <main>
	.text
main:
	# Set up stack frame
	sw	$fp, -4($sp)
	la	$fp, -4($sp)
	sw	$ra, -4($fp)
	sw	$s0, -8($fp)
	addi	$sp, $sp, -12
	
	# printf ("# Iterations: ");
	la $a0, MSG_ITERATION
	li $v0, 4
	syscall

	# scanf ("%d", &maxiters);
	li $v0, 5
	syscall
	sw $v0 maxiters

	# for (int n = 1; n <= maxiters; n++) {
	li $t0, 1
	sw $t0, main__n
main__for_n_start:
	lw $t0, main__n		# t0: n
	lw $t1, maxiters	# t1: maxiters
	bgt $t0, $t1, main__for_n_end	

	li $t0, 0
	sw $t0, main__i
main__for_i_start:
	lw $t0, main__i		# t0: i
	lw $t1, N			# t1: N
	bge $t0, $t1, main__for_i_end

	li $t0, 0
	sw $t0, main__j
main__for_j_start:
	lw $t0, main__j		# t0: j
	lw $t1, N			# t1: N
	bge $t0, $t1, main__for_j_end
	
	# int nn = neighbours (i, j);
	# a0: i
	# a1: j
	lw $a0, main__i
	lw $a1, main__j
	jal neighbours
	move $a1, $v0

	# newboard[i][j] = decideCell (board[i][j], nn);
	lw $t0, main__i		# t0: i
	lw $t1, main__j		# t1: j
	lw $t2, N			# t2: N
	mul $t0, $t0, $t2	# t0: i * N
	add $t0, $t0, $t1	# t0: i * N + j, offset
	la $t1, board		# t1: board address
	la $t2, newBoard	# t2: newBoard address
	addu $t1, $t1, $t0	# t1: address of board[i][j]
	addu $t2, $t2, $t0	# t1: address of newBoard[i][j]
	move $s0, $t2		# s0: address of newBoard[i][j], saved
	lb $t1, ($t1)		# t1: value at board[i][j]
	move $a0, $t1		# a0: board[i][j]
	jal decideCell
	sb $v0, ($s0)

	# j++
	lw $t0, main__j		# t0: j
	addi $t0, $t0, 1
	sw $t0, main__j
	j main__for_j_start

main__for_j_end:
	# i++
	lw $t0, main__i		# t0: i
	addi $t0, $t0, 1
	sw $t0, main__i
	j main__for_i_start

main__for_i_end:
	# printf ("=== After iteration %d ===\n", n);
	la $a0, MSG_AFTERITER_1
	li $v0, 4
	syscall
	lw $t0, main__n
	move $a0, $t0
	li $v0, 1
	syscall
	la $a0, MSG_AFTERITER_2
	li $v0, 4
	syscall

	jal copyBackAndShow

	# n++
	lw $t0, main__n		# t0: n
	addi $t0, $t0, 1
	sw $t0, main__n
	j main__for_n_start

main__for_n_end:
	# clean up stack frame
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)	
	lw	$fp, ($fp)	

	# return back to caller
	li	$v0, 0
	jr	$ra		# return 0
	

decideCell:
	sw $fp, -4($sp)	
	la $fp, -4($sp)	
	sw $ra, -4($fp)	
	sw $s0, -8($fp)	
	addi	$sp, $sp, -12

	# t0: ret
	# t1: old
	# t2: nn
	li $t0, 0
	move $t1, $a0
	move $t2, $a1

	# outer if
	# if (old == 1) {
	li $t3, 1
	beq $t1, $t3, decideCell__old1
	# else if (nn == 3) {
	li $t3, 3
	beq $t2, $t3, decideCell__nn3
	# else
	# ret = 0;
	li $t0, 0
	j decideCell__if_end

decideCell__nn3:
	# ret = 1;
	li $t0, 1
	j decideCell__if_end

decideCell__old1:
	# inner if
	# if (nn < 2)
	li $t3, 2
	blt $t2, $t3, decideCell__nn2
	# else if (nn == 2 || nn == 3)
	li $t3, 2
	beq $t2, $t3, decideCell__nn2_or_3	# nn == 2
	li $t3, 3
	beq $t2, $t3, decideCell__nn2_or_3	# nn == 3
	# inner else
	li $t0, 0

	j decideCell__inner_end

decideCell__nn2:
	li $t0, 0
	j decideCell__inner_end

decideCell__nn2_or_3:
	li $t0, 1

decideCell__inner_end:

decideCell__if_end:
	move $v0, $t0

	lw $s0, -8($fp)	
	lw $ra, -4($fp)	
	la $sp, 4($fp)	
	lw $fp, ($fp)	
	jr $ra

neighbours:
	sw $fp, -4($sp)	
	la $fp, -4($sp)	
	sw $ra, -4($fp)	
	sw $s0, -8($fp)	
	addi	$sp, $sp, -12

	# t0: nn
	# t1: x
	# t2: y
	# t3: i
	# t4: j
	# t5: xEnd
	# t6: yEnd
	li $t0, 0		# int nn = 0;
	move $t3, $a0	# i = a0
	move $t4, $a1	# j = a1
	li $t5, 1
	li $t6, 1	

	li $t1, -1		# int x = -1
neighbours_for_x_start:
	bgt $t1, $t5, neighbours_for_x_end

	li $t2, -1
neighbours_for_y_start:
	bgt $t2, $t6, neighbours_for_y_end
	
	# if (i + x < 0 || i + x > N - 1) continue;
	add $t7, $t3, $t1	# t7: i + x
	bltz $t7, neighbours_continue	# i + x < 0
	lw $t8, N			# t8: N
	addi $t8, $t8, -1	# t8: N - 1
	bgt $t7, $t8, neighbours_continue	# i + x > N - 1

	# if (j + y < 0 || j + y > N - 1) continue;
	add $t7, $t4, $t2	# t7: i + y
	bltz $t7, neighbours_continue	# i + y < 0
	lw $t8, N			# t8: N
	addi $t8, $t8, -1	# t8: N - 1
	bgt $t7, $t8, neighbours_continue	# i + y > N - 1

	# if (x == 0 && y == 0) continue;
	bnez $t1, neighbours_if_false	# x == 0
	beqz $t2, neighbours_continue	# y == 0
neighbours_if_false:

	# if (board[i + x][j + y] == 1) nn++;
	add $t7, $t3, $t1	# t7: i + x
	add $t8, $t4, $t2	# t8: j + y
	lw $t9, N			# t9: N
	mul $t7, $t7, $t9	# t7: (i + x) * N
	add $t7, $t7, $t8	# t7: (i + x) * N + (j + y), offset
	la $t8, board		# t8: board address
	addu $t7, $t7, $t8	# t7: address of board[i + x][j + y]
	lb $t7, ($t7)		# t7: value of board[i + x][j + y]
	li $t8, 1
	bne $t7, $t8, neighbours_if_false_nn	# board[i + x][j + y] == 1
	addi $t0, $t0, 1	# nn++;
neighbours_if_false_nn:
neighbours_continue:
	# y++
	addi $t2, $t2, 1
	j neighbours_for_y_start
	
neighbours_for_y_end:
	# x++
	addi $t1, $t1, 1
	j neighbours_for_x_start

neighbours_for_x_end:
	move $v0, $t0

	lw $s0, -8($fp)	
	lw $ra, -4($fp)	
	la $sp, 4($fp)	
	lw $fp, ($fp)	
	jr $ra

copyBackAndShow:
	sw $fp, -4($sp)	
	la $fp, -4($sp)	
	sw $ra, -4($fp)	
	sw $s0, -8($fp)	
	addi	$sp, $sp, -12

	# t0: i
	# t1: j
	# t2: N
	lw $t2, N
	li $t0, 0
copyBackAndShow_for_i_start:
	bge $t0, $t2, copyBackAndShow_for_i_end
	
	li $t1, 0
copyBackAndShow_for_j_start:
	bge $t1, $t2, copyBackAndShow_for_j_end

	# t3: offset
	mul $t3, $t0, $t2	# t3 = i * N
	add $t3, $t3, $t1	# t3 = t3 + j

	# t4: board[i][j] address
	la $t4, board		# base address
	addu $t4, $t3, $t4	# add offset

	# t5: newBoard[i][j] address
	la $t5, newBoard	# base address
	addu $t5, $t3, $t5	# add offset

	# t3: byte at newBoard[i][j]
	lb $t3, ($t5)

	# board[i][j] = newboard[i][j];
	sb $t3, ($t4)

	# if (board[i][j] == 0)
	beq $t3, $0, copyBackAndShow_else

	# putchar ('#');
	lw $t5, MSG_CHAR_HASH
	move $a0, $t5
	li $v0, 11
	syscall

	j copyBackAndShow_if_end

copyBackAndShow_else:
	# putchar ('.');
	lw $t5, MSG_CHAR_DOT
	move $a0, $t5
	li $v0, 11
	syscall
copyBackAndShow_if_end:

	# j++
	addi $t1, $t1, 1
	j copyBackAndShow_for_j_start

copyBackAndShow_for_j_end:
	# putchar ('\n');
	lw $t3, MSG_NEWLINE
	move $a0, $t3
	li $v0, 11
	syscall

	# i++
	addi $t0, $t0, 1
	j copyBackAndShow_for_i_start

copyBackAndShow_for_i_end:
	lw $s0, -8($fp)	
	lw $ra, -4($fp)	
	la $sp, 4($fp)	
	lw $fp, ($fp)	
	jr $ra