############################################
#
# Project1.asm
# Author: Kevin Garsjo
#
# Created:  10/20/11
# Modified: 10/20/11
#
# Purpose: Collects grade inputs up to 50 words
#	from the console, sorts them numerically
#	per input, and prints statistics when
#	finished. (-1) is the end-input
#	sentinel.
#
############################################

	
############################################
# Data Delcaration
############################################			
	.data
Array:	.space 200	# Declare 200 byte space (50 word space) in memory
Prompt:	.asciiz "Welcome! Enter grades one at a time, or -1 to exit\n\n"
PPref:	.asciiz "You have entered "
PSuff:	.asciiz " grades.\n"
PGrade:	.asciiz "Grade Breakdown:\n"
Acolon:	.asciiz "A: "
Bcolon: .asciiz "B: "
Ccolon:	.asciiz "C: "
Dcolon: .asciiz "D: "
Fcolon:	.asciiz "F: "
Max:	.asciiz "Maximum:\t"
Min:	.asciiz "Minimum:\t"
Mean:	.asciiz "Mean:\t"
Median:	.asciiz "Median\t"
Space:	.asciiz " "
Endl:	.asciiz "\n"

	.text
	.globl main
############################################
# Program Entry / Exit
############################################
main:
	# Global Variables
	add $s0, $zero, $zero
	addi $s1, $zero, -1	# $s1 = Sentinel integer
	li $v0, 4
	la $a0, Prompt
	syscall

	# Begin Input and InsertSort Loop
Loop:	jal Input	
	beq $v0, $s1, Exit
	blt $v0, -1, Loop
	bgt $v0, 100, Loop
	
	move $a0, $v0
	jal InsertSort
	jal Print
	
	j Loop
	

Exit:	jal Newline
	jal Newline
	jal PrintTotal
	
	jal Stats
	
	li $v0, 10
	syscall
	
	
############################################
# Input
#	Args: N/A
#	Retn: $v0 - Integer from console
############################################
Input:	li $v0, 5
	syscall
	jr $ra
	

############################################
# InsertSort
#	Args: $a0 - Number to Insert
#	Retn: N/A
############################################
InsertSort:
	add $t0, $0, $0		# $t0 = i counter
				# $s0 = array size
	move $t1, $a0		# $t1 = Num to Insert

L1:	slt $t3, $t0, $s0	# If i < n ...
	bne $t3, 1, L2		# else goto 2nd loop
	
	lw $t2, Array($t0)	# $t2 = A[i]
	
	slt $t3, $t2, $t1	# and A[i] < x ...
	bne $t3, 1, L2
	
	addi $t0, $t0, 4	# increment i and keep looping
	j L1
	
L2:	move $t3, $s0		# $t3 = j counter = array size
L2a:	slt $t4, $t0, $t3	# If i < j stay in loop ...
	bne $t4, 1, Fin		# else goto Finish
	
	addi $t5, $t3, -4
	lw $t4, Array($t5)	# $t4 = A[j-1]
	sw $t4, Array($t3)	# A[j] = $t4
	addi $t3, $t3, -4	# Decrement j and keep looping
	j L2a
	
Fin:	addi $s0, $s0, 4	# Increment array size
	sw $t1, Array($t0)	# A[i] = num to insert
	
	jr $ra


############################################
# Stats
#	Args: N/A
#	Retn: N/A
############################################
Stats:	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t0, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	
	######################	
	# Run through array for stats
	######################
SL0:	bge $t0, $s0, SLFin
	
	lw $t1, Array($t0)
	blt $t1, 90 SL1
	addi $t9, $t9, 1
	j SL5
	
SL1:	blt $t1, 80, SL2
	addi $t8, $t8, 1
	j SL5
	
SL2:	blt $t1, 70, SL3
	addi $t7, $t7, 1
	j SL5
	
SL3:	blt $t1, 60, SL4
	addi $t6, $t6, 1
	j SL5
	
SL4:	addi $t5, $t5, 1

SL5:	add $t3, $t3, $t1
	addi $t0, $t0, 4
	j SL0


	######################	
	# Max / Min Code
	######################	
SLFin:	li $v0, 4
	la $a0, Max
	syscall
	
	li $v0, 1
	addi $a0, $s0, -4
	lw $a0, Array($a0)
	syscall
	
	jal Newline
	
	li $v0, 4
	la $a0, Min
	syscall
	
	li $v0, 1
	lw $a0, Array($zero)
	syscall
	
	jal Newline
	
	######################	
	# Mean code
	######################
	li $v0, 4
	la $a0, Mean
	syscall
	
	li $v0, 1
	bne $s0, $0, Me1	# If no input, set zero
	move $a0, $0
	j Me2
Me1:	div $a0, $s0, 4
	div $a0, $t3, $a0
Me2:	syscall
	
	jal Newline

	######################	
	# Median code
	######################	
	li $v0, 4
	la $a0, Median
	syscall

	add $t2, $0, $0
	beq $s0, $0, MFin	# If no input, set zero

	div $t0, $s0, 4		# $t0 = size
	div $t1, $t0, 2		
	sll $t1, $t1, 2		# $t1 = pos = size/2 * 4
	lw $t2, Array($t1)	# $t2 = Median value
	li $t3, 2
	div $t0, $t3
	mfhi $t3
	bne $t3, $0, MFin	# if size mod 2 = 1, done
	addi $t1, $t1, -4
	lw $t3, Array($t1)	# $t3 = Array[pos + 1]
	add $t2, $t2, $t3
	div $t2, $t2, 2
MFin:	li $v0, 1
	move $a0, $t2
	syscall

	jal Newline
	jal Newline

	######################	
	# Grade Tally Code
	######################
	li $v0, 4
	la $a0, PGrade
	syscall
	
	li $v0, 4
	la $a0, Acolon
	syscall
	
	li $v0, 1
	move $a0, $t9
	syscall
	
	jal Newline
	
	li $v0, 4
	la $a0, Bcolon
	syscall
	
	li $v0, 1
	move $a0, $t8
	syscall
	
	jal Newline
	
	li $v0, 4
	la $a0, Ccolon
	syscall
	
	li $v0, 1
	move $a0, $t7
	syscall
	
	jal Newline
	
	li $v0, 4
	la $a0, Dcolon
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	jal Newline
	
	li $v0, 4
	la $a0, Fcolon
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	jal Newline
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


############################################
# Print - Prints the sorted array
#	Args: N/A
#	Retn: N/A
############################################
Print:	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t0, $zero
	
PL:	slt $t1, $t0, $s0
	bne $t1, 1, PLF
	
	li $v0, 1
	lw $a0, Array($t0)
	syscall
	
	li $v0, 4
	la $a0, Space
	syscall
	
	addi $t0, $t0, 4
	j PL
	
PLF:	jal Newline

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


############################################
# PrintTotal - Prints the total num entries
#	Args: N/A
#	Retn: N/A
############################################
PrintTotal:	
	li $v0, 4
	la $a0, PPref
	syscall
	
	li $v0, 1
	div $a0, $s0, 4
	syscall
	
	li $v0, 4
	la $a0, PSuff
	syscall
	jr $ra


############################################
# Newline
#	Args: N/A
#	Retn: N/A
############################################
Newline:
	li $v0, 4
	la $a0, Endl
	syscall
	jr $ra