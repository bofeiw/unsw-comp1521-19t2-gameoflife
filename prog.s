# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by <<Bofei Wang>>, June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

# boardX.s
########################################################################
# board1.s ... Game of Life on a 10x10 grid

	.data

N:	.word 10  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

newBoard: .space 100

########################################################################

## defined data
	.data
MSG_ITERATION:	.asciiz	"# Iterations: "
MSG_AFTERITER_1:	.asciiz	"=== After iteration "
MSG_AFTERITER_2:	.asciiz " ===\n"
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


########################################################################
# .TEXT <main>
	.text
main:
	# Set up stack frame
	sw	$fp, -4($sp)	# push $fp onto stack
	la	$fp, -4($sp)	# set up $fp for this function
	sw	$ra, -4($fp)	# save return address
	sw	$s0, -8($fp)	# save $s0 to use as ... int n
	addi	$sp, $sp, -12	# reset $sp to last pushed item
	
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
	#TODO 

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

	# n++
	lw $t0, main__n		# t0: n
	addi $t0, $t0, 1
	sw $t0, main__n
	j main__for_n_start

main__for_n_end:
	# clean up stack frame
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	# restore $sp (remove stack frame)
	lw	$fp, ($fp)	# restore $fp (remove stack frame)

	# return back to caller
	li	$v0, 0
	jr	$ra		# return 0
	

decideCell:
neighbours:
copyBackAndShow: