########################################################################
# COMP1521 21T2 -- Assignment 1 -- Snake!
# <https://www.cse.unsw.edu.au/~cs1521/21T2/assignments/ass1/index.html>
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# For instructions, see: https://www.cse.unsw.edu.au/~cs1521/21T2/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by Amin Ghasembeigi (z5123456)
# on 01/07/2021
#
# Version 1.0 (2021-06-24): Team COMP1521 <cs1521@cse.unsw.edu.au>
#

	# Requires:
	# - [no external symbols]
	#
	# Provides:
	# - Global variables:
	.globl	symbols
	.globl	grid
	.globl	snake_body_row
	.globl	snake_body_col
	.globl	snake_body_len
	.globl	snake_growth
	.globl	snake_tail

	# - Utility global variables:
	.globl	last_direction
	.globl	rand_seed
	.globl  input_direction__buf

	# - Functions for you to implement
	.globl	main
	.globl	init_snake
	.globl	update_apple
	.globl	move_snake_in_grid
	.globl	move_snake_in_array

	# - Utility functions provided for you
	.globl	set_snake
	.globl  set_snake_grid
	.globl	set_snake_array
	.globl  print_grid
	.globl	input_direction
	.globl	get_d_row
	.globl	get_d_col
	.globl	seed_rng
	.globl	rand_value


########################################################################
# Constant definitions.

N_COLS          = 15
N_ROWS          = 15
MAX_SNAKE_LEN   = N_COLS * N_ROWS

EMPTY           = 0
SNAKE_HEAD      = 1
SNAKE_BODY      = 2
APPLE           = 3

NORTH       = 0
EAST        = 1
SOUTH       = 2
WEST        = 3


########################################################################
# .DATA
	.data

# const char symbols[4] = {'.', '#', 'o', '@'};
symbols:
	.byte	'.', '#', 'o', '@'

	.align 2
# int8_t grid[N_ROWS][N_COLS] = { EMPTY };
grid:
	.space	N_ROWS * N_COLS

	.align 2
# int8_t snake_body_row[MAX_SNAKE_LEN] = { EMPTY };
snake_body_row:
	.space	MAX_SNAKE_LEN

	.align 2
# int8_t snake_body_col[MAX_SNAKE_LEN] = { EMPTY };
snake_body_col:
	.space	MAX_SNAKE_LEN

# int snake_body_len = 0;
snake_body_len:
	.word	0

# int snake_growth = 0;
snake_growth:
	.word	0

# int snake_tail = 0;
snake_tail:
	.word	0

# Game over prompt, for your convenience...
main__game_over:
	.asciiz	"Game over! Your score was "


########################################################################
#
# Your journey begins here, intrepid adventurer!
#
# Implement the following 6 functions, and check these boxes as you
# finish implementing each function
#
#  - [ ] main
#  - [ ] init_snake
#  - [ ] update_apple
#  - [ ] update_snake
#  - [ ] move_snake_in_grid
#  - [ ] move_snake_in_array
#



########################################################################
# .TEXT <main>
	.text
main:

	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    $ra
	# Uses:	    $v0, $a0, $t0
	# Clobbers: $v0, $a0, $t0
	#
	# Locals:
	#   - `int direction` in $t0
	#   - `int score` in $t0
	#
	# Structure:
	#   main
	#   -> [prologue]
	#   -> main__loop_before
	#   	-> main__loop_body
	#   -> main__loop_cond
	#   -> main__loop_end
	#   -> [epilogue]

	# Code:
main__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

main__loop_before:
	jal	init_snake		# init_snake()
	jal	update_apple		# update_apple()

main__loop_body:
	jal	print_grid		# print_grid()
	jal	input_direction		# input_direction()
	move	$t0, $v0		# int direction = input_direction();
	move 	$a0, $t0		# $a0 = direction
	jal 	update_snake		# update_snake(direction)	
	move 	$t0, $v0		# $t0 = update_snake(direction)

main__loop_cond:
	beqz 	$t0, main__loop_end	# while (update_snake(direction))
	j 	main__loop_body

main__loop_end:
	lw 	$t0, snake_body_len 	# int score = snake_body_len
	div	$t0, $t0, 3		# int score = score / 3

	li	$v0, 4
	la	$a0, main__game_over	# printf("Game over! Your score was")
	syscall				

	li	$v0, 1
	move	$a0, $t0
	syscall				# printf("%d", score)

	li	$v0, 11
	li	$a0, '\n'
	syscall				# putchar('\n')

main__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra			# return 0



########################################################################
# .TEXT <init_snake>
	.text
init_snake:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra
	# Uses:     $a0, $a1, $a2
	# Clobbers: $a0, $a1, $a2
	#
	# Locals: None
	#
	# Structure:
	#   init_snake
	#   -> [prologue]
	#   -> init_snake__body
	#   -> [epilogue]

	# Code:
init_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

init_snake__body:
        li	$a0, 7
        li	$a1, 7
        li	$a2, SNAKE_HEAD
	jal 	set_snake			# set_snake(7, 7, SNAKE_HEAD);

        li	$a0, 7
        li	$a1, 6
        li	$a2, SNAKE_BODY
	jal 	set_snake			# set_snake(7, 6, SNAKE_BODY);

        li	$a0, 7
        li	$a1, 5 
        li	$a2, SNAKE_BODY
	jal 	set_snake			# set_snake(7, 5, SNAKE_BODY);

        li	$a0, 7
        li	$a1, 4
        li	$a2, SNAKE_BODY
	jal 	set_snake			# set_snake(7, 4, SNAKE_BODY);


init_snake__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra			# return;



########################################################################
# .TEXT <update_apple>
	.text
update_apple:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1
	# Uses:     $a0, $s0, $s1, $t0, $t1
	# Clobbers: $a0, $t0, $t1
	#
	# Locals:
	#   - `int apple_row` in $s0
	#   - `int apple_col` in $s1
	#
	# Structure:
	#   update_apple
	#   -> [prologue]
	#   	-> update_apple__loop_body
	#   -> update_apple__loop_cond
	#   -> update_apple__loop_end
	#   -> [epilogue]

	# Code:
update_apple__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1, 0($sp)

update_apple__loop_body:
	la	$a0, N_ROWS
	jal	rand_value  
	move	$s0, $v0		# int apple_row = rand_value(N_ROWS)

	la	$a0,  N_COLS
	jal	rand_value  
	move	$s1, $v0		# int apple_col = rand_value(N_COLS)

update_apple__loop_cond:
	mul	$t0, $s0, N_ROWS			# apple_row * N_ROWS
	add	$t0, $t0, $s1				# (apple_row * N_ROWS) + apple_col
	lb	$t1, grid($t0)				# grid + ((apple_row * N_ROWS) + apple_col)
	bne	$t1, EMPTY, update_apple__loop_body
	j	update_apple__loop_end

update_apple__loop_end:
	mul	$t0, $s0, N_ROWS	# apple_row * N_ROWS
	add	$t0, $t0, $s1		# (apple_row * N_ROWS) + apple_col
	li	$t1, APPLE
	sb	$t1, grid($t0)		# grid + ((apple_row * N_ROWS) + apple_col)
	
update_apple__epilogue:
	# tear down stack frame
	lw	$s1, 0($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	jr	$ra			# return;

########################################################################
# .TEXT <update_snake>
	.text
update_snake:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra, $s0, $s1, $s2
	# Uses:     $v0, $a0, $a1, $s0, $s1, $s2, $t0, $t1, $t2, $t3
	# Clobbers: $v0, $a0, $a1, $t0, $t1, $t2, $t3
	#
	# Locals:
	#   - `int direction` in $s0
	#   - `int d_row` in $s1
	#   - `int d_col` in $s2
	#   - `int head_row` in $t0
	#   - `int head_col` in $t1
	#   - `int apple` in $s0
	#
	# Structure:
	#   update_snake
	#   -> [prologue]
	#   -> update_snake__prologue
	#   -> update_snake__body
	#   -> update_snake__grid_eq_apple
	#   	-> update_snake__grid_eq_apple_true
	#   	-> update_snake__grid_eq_apple_false
	#   -> update_snake__grid_eq_apple_end
	#   -> update_snake__move_snake_in_grid_eq_0
	#   -> update_snake__return_false
	#   	-> update_snake__move_snake_in_grid_eq_0_false
	#   -> update_snake__apple_eq_1
	#   	-> update_snake__apple_eq_1_true
	#   	-> update_snake__apple_eq_1_false
	#   -> [epilogue]

	# Code:
update_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s0, 8($sp)
	sw	$s1, 4($sp)
	sw	$s2, 0($sp)

update_snake__body:
	move 	$s0, $a0		# $a0 = direction
	jal 	get_d_row			
	move 	$s1, $v0		# int d_row = get_d_row(direction)
	move 	$a0, $s0		# $a0 = direction
	jal 	get_d_col
	move 	$s2, $v0		# int d_col = get_d_col(direction)

	lb 	$t0, snake_body_row	# int head_row = snake_body_row[0]
	lb 	$t1, snake_body_col	# int head_col = snake_body_col[0]

	mul	$t2, $t0, N_ROWS	# head_row * N_ROWS
	add	$t2, $t2, $t1		# (head_row * N_ROWS) + head_col
	li	$t3, SNAKE_BODY
	sb	$t3, grid($t2)		# grid[head_row][head_col] = SNAKE_BODY

	add	$s1, $t0, $s1		# int new_head_row = head_row + d_row
	add	$s2, $t1, $s2		# int new_head_col = head_col + d_col

	bltz	$s1, update_snake__return_false			# if (new_head_row < 0)       return false
	bge	$s1, N_ROWS, update_snake__return_false		# if (new_head_row >= N_ROWS) return false
	bltz	$s2, update_snake__return_false			# if (new_head_col < 0)       return false
	bge	$s2, N_COLS, update_snake__return_false		# if (new_head_col >= N_COLS) return false
	
update_snake__grid_eq_apple:
	mul	$t0, $s1, N_ROWS				# new_head_row * N_ROWS
	add	$t0, $t0, $s2					# (new_head_row * N_ROWS) + new_head_col
	lb	$t1, grid($t0)					# grid + ((new_head_row * N_ROWS) + new_head_col)
	beq	$t1, APPLE, update_snake__grid_eq_apple_true	# grid[new_head_row][new_head_col] == APPLE
	j update_snake__grid_eq_apple_false

update_snake__grid_eq_apple_true:
	li	$s0, 1				# bool apple = true
	j update_snake__grid_eq_apple_end

update_snake__grid_eq_apple_false:
	li	$s0, 0				# bool apple = false
	j update_snake__grid_eq_apple_end

update_snake__grid_eq_apple_end:
	la	$t2, snake_tail		
	lw	$t3, snake_body_len
	addi	$t3, $t3, -1
	sw	$t3, 0($t2)		# int snake_tail = snake_body_len - 1

update_snake__move_snake_in_grid_eq_0:
	move	$a0, $s1				# $a0 = new_head_row
	move	$a1, $s2				# $a0 = new_head_col
	jal 	move_snake_in_grid			# move_snake_in_grid(new_head_row, new_head_col)
	move	$t0, $v0
	beqz	$t0, update_snake__return_false
	j	update_snake__move_snake_in_grid_eq_0_false

update_snake__return_false:
	# tear down stack frame
	lw	$s2, 0($sp)
	lw	$s1, 4($sp)
	lw	$s0, 8($sp)
	lw	$ra, 12($sp)
	addiu 	$sp, $sp, 16

	li	$v0, 0
	jr	$ra			# return false

update_snake__move_snake_in_grid_eq_0_false:
	jal 	move_snake_in_array

update_snake__apple_eq_1:
	beq	$s0, 1, update_snake__apple_eq_1_true
	j 	update_snake__apple_eq_1_false

update_snake__apple_eq_1_true:
	la	$t0, snake_growth
	lw	$t1, snake_growth
	addi	$t1, $t1, 3
	sw	$t1, 0($t0)		# snake_growth += 3
	jal 	update_apple		# update_apple()

update_snake__apple_eq_1_false:

update_snake__epilogue:
	# tear down stack frame
	lw	$s2, 0($sp)
	lw	$s1, 4($sp)
	lw	$s0, 8($sp)
	lw	$ra, 12($sp)
	addiu 	$sp, $sp, 16

	li	$v0, 1
	jr	$ra			# return true

########################################################################
# .TEXT <move_snake_in_grid>
	.text
move_snake_in_grid:

	# Args:
	#   - $a0: new_head_row
	#   - $a1: new_head_col
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra, $s0, $s1
	# Uses:     $v0, $a0, $a1, $s0, $s1, $t0, $t1, $t2, $t3, $t4, $t5 
	# Clobbers: $v0, $a0, $a1, $t0, $t1, $t2, $t3, $t4, $t5
	#
	# Locals:
	#   - `int tail` in $t0
	#   - `int tail_row` in $t2 
	#   - `int tail_col` in $t3
	#
	# Structure:
	#   move_snake_in_grid
	#   -> [prologue]
	#   -> move_snake_in_grid__snake_growth_gt_0
	#   	-> move_snake_in_grid__snake_growth_gt_0_true
	#   	-> move_snake_in_grid__snake_growth_gt_0_false
	#   -> move_snake_in_grid__grid_eq_snake_body
	#   	-> move_snake_in_grid__grid_eq_snake_body_true
	#   	-> move_snake_in_grid__grid_eq_snake_body_false
	#   -> [epilogue]

	# Code:
move_snake_in_grid__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1, 0($sp)

move_snake_in_grid__snake_growth_gt_0:
	lw	$t0, snake_growth
	bgtz	$t0, move_snake_in_grid__snake_growth_gt_0_true		# if (snake_growth > 0)
	j	move_snake_in_grid__snake_growth_gt_0_false

move_snake_in_grid__snake_growth_gt_0_true:
	la	$t0, snake_tail
	lw	$t1, snake_tail
	addi	$t1, $t1, 1
	sw	$t1, 0($t0)		# snake_tail++

	la	$t0, snake_body_len
	lw	$t1, snake_body_len
	addi	$t1, $t1, 1
	sw	$t1, 0($t0)		# snake_body_len++

	la	$t0, snake_growth
	lw	$t1, snake_growth

	addi	$t1, $t1, -1
	sw	$t1, 0($t0)		# snake_growth--
	j	move_snake_in_grid__grid_eq_snake_body

move_snake_in_grid__snake_growth_gt_0_false:
	lw	$t0, snake_tail				# int tail = snake_tail
	
	lb	$t2, snake_body_row($t0)		# int tail_row = snake_body_row[tail]
	lb	$t3, snake_body_col($t0)		# int tail_col = snake_body_col[tail]

	mul	$t4, $t2, N_ROWS			# tail_row * N_ROWS
	add	$t4, $t4, $t3				# (tail_row * N_ROWS) + tail_col
	li	$t5, EMPTY
	sb	$t5, grid($t4)				# grid + ((tail_row * N_ROWS) + tail_col)
	j 	move_snake_in_grid__grid_eq_snake_body

move_snake_in_grid__grid_eq_snake_body:
	mul	$t0, $a0, N_ROWS						# new_head_row * N_ROWS
	add	$t0, $t0, $a1							# (new_head_row * N_ROWS) + new_head_col
	lb	$t1, grid($t0)							# grid + ((new_head_row * N_ROWS) + new_head_col)

	beq	$t1, SNAKE_BODY, move_snake_in_grid__grid_eq_snake_body_true	# if (grid[new_head_row][new_head_col] == SNAKE_BODY)
	j	move_snake_in_grid__grid_eq_snake_body_false

move_snake_in_grid__grid_eq_snake_body_true:
	# tear down stack frame
	lw	$s1, 0($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	li	$v0, 0
	jr	$ra			# return false;

move_snake_in_grid__grid_eq_snake_body_false:
	mul	$t0, $a0, N_ROWS	# new_head_row * N_ROWS
	add	$t0, $t0, $a1		# (new_head_row * N_ROWS) + new_head_col
	li	$t1, SNAKE_HEAD	
	sb	$t1, grid($t0)		# grid + ((new_head_row * N_ROWS) + new_head_col)

move_snake_in_grid__epilogue:
	# tear down stack frame
	lw	$s1, 0($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	li	$v0, 1
	jr	$ra			# return true;


########################################################################
# .TEXT <move_snake_in_array>
	.text
move_snake_in_array:

	# Arguments:
	#   - $a0: int new_head_row
	#   - $a1: int new_head_col
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1, $s2
	# Uses:     $a0, $a1, $s0, $s1, $s2
	# Clobbers: $a0, $a1
	#
	# Locals:
	#   - `int i` in $s2
	#
	# Structure:
	#   move_snake_in_array
	#   -> [prologue]
	#   -> move_snake_in_array__loop_init
	#   -> move_snake_in_array__loop_cond
	#   	-> move_snake_in_array__loop_body
	#   	-> move_snake_in_array__loop_step
	#   -> move_snake_in_array__loop_end
	#   -> [epilogue]

	# Code:
move_snake_in_array__prologue:
	# set up stack frame
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s0, 8($sp)
	sw	$s1, 4($sp)
	sw	$s2, 0($sp)

move_snake_in_array__loop_init:
	move	$s0, $a0
	move	$s1, $a1
	lw	$s2, snake_tail		# int i = snake_tail

move_snake_in_array__loop_cond:
	blt	$s2, 1, move_snake_in_array__loop_end	
	j	move_snake_in_array__loop_body

move_snake_in_array__loop_body:
	addi	$t0, $s2, -1			# i - 1
	lb	$a0, snake_body_row($t0)	# snake_body_row[i - 1]
	lb	$a1, snake_body_col($t0)	# snake_body_row[i - 1]
	move 	$a2, $s2
	jal	set_snake_array 		# set_snake_array(snake_body_row[i - 1], snake_body_col[i - 1], i);

move_snake_in_array__loop_step:
	addi 	$s2, $s2, -1			# i--
	j 	move_snake_in_array__loop_cond

move_snake_in_array__loop_end:
	move	$a0, $s0
	move	$a1, $s1
	li	$a2, 0
	jal 	set_snake_array 	# set_snake_array(new_head_row, new_head_col, 0);

move_snake_in_array__epilogue:
	# tear down stack frame
	lw	$s2, 0($sp)
	lw	$s1, 4($sp)
	lw	$s0, 8($sp)
	lw	$ra, 12($sp)
	addiu 	$sp, $sp, 16

	jr	$ra			# return;


########################################################################
####                                                                ####
####        STOP HERE ... YOU HAVE COMPLETED THE ASSIGNMENT!        ####
####                                                                ####
########################################################################

##
## The following is various utility functions provided for you.
##
## You don't need to modify any of the following.  But you may find it
## useful to read through --- you'll be calling some of these functions
## from your code.
##

	.data

last_direction:
	.word	EAST

rand_seed:
	.word	0

input_direction__invalid_direction:
	.asciiz	"invalid direction: "

input_direction__bonk:
	.asciiz	"bonk! cannot turn around 180 degrees\n"

	.align	2
input_direction__buf:
	.space	2



########################################################################
# .TEXT <set_snake>
	.text
set_snake:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1
	# Uses:     $a0, $a1, $a2, $t0, $s0, $s1
	# Clobbers: $t0
	#
	# Locals:
	#   - `int row` in $s0
	#   - `int col` in $s1
	#
	# Structure:
	#   set_snake
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

	# Code:
set_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1,  ($sp)

set_snake__body:
	move	$s0, $a0		# $s0 = row
	move	$s1, $a1		# $s1 = col

	jal	set_snake_grid		# set_snake_grid(row, col, body_piece);

	move	$a0, $s0
	move	$a1, $s1
	lw	$a2, snake_body_len
	jal	set_snake_array		# set_snake_array(row, col, snake_body_len);

	lw	$t0, snake_body_len
	addiu	$t0, $t0, 1
	sw	$t0, snake_body_len	# snake_body_len++;

set_snake__epilogue:
	# tear down stack frame
	lw	$s1,  ($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_grid>
	.text
set_snake_grid:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2, $t0
	# Clobbers: $t0
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake
	#   -> body

	# Code:
	li	$t0, N_COLS
	mul	$t0, $t0, $a0		#  15 * row
	add	$t0, $t0, $a1		# (15 * row) + col
	sb	$a2, grid($t0)		# grid[row][col] = body_piece;

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_array>
	.text
set_snake_array:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int nth_body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake_array
	#   -> body

	# Code:
	sb	$a0, snake_body_row($a2)	# snake_body_row[nth_body_piece] = row;
	sb	$a1, snake_body_col($a2)	# snake_body_col[nth_body_piece] = col;

	jr	$ra				# return;



########################################################################
# .TEXT <print_grid>
	.text
print_grid:

	# Args:     void
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1, $t2
	# Clobbers: $v0, $a0, $t0, $t1, $t2
	#
	# Locals:
	#   - `int i` in $t0
	#   - `int j` in $t1in $t2
	#
	# Structure:
	#   print_grid
	#   -> for_i_cond
	#     -> for_j_cond
	#     -> for_j_end
	#   -> for_i_end

	# Code:
	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	li	$t0, 0			# int i = 0;

print_grid__for_i_cond:
	bge	$t0, N_ROWS, print_grid__for_i_end	# while (i < N_ROWS)

	li	$t1, 0			# int j = 0;

print_grid__for_j_cond:
	bge	$t1, N_COLS, print_grid__for_j_end	# while (j < N_COLS)

	li	$t2, N_COLS
	mul	$t2, $t2, $t0		#                             15 * i
	add	$t2, $t2, $t1		#                            (15 * i) + j
	lb	$t2, grid($t2)		#                       grid[(15 * i) + j]
	lb	$t2, symbols($t2)	# char symbol = symbols[grid[(15 * i) + j]]

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t2
	syscall				# putchar(symbol);

	addiu	$t1, $t1, 1		# j++;

	j	print_grid__for_j_cond

print_grid__for_j_end:

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	addiu	$t0, $t0, 1		# i++;

	j	print_grid__for_i_cond

print_grid__for_i_end:
	jr	$ra			# return;



########################################################################
# .TEXT <input_direction>
	.text
input_direction:

	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $a1, $t0, $t1
	# Clobbers: $v0, $a0, $a1, $t0, $t1
	#
	# Locals:
	#   - `int direction` in $t0
	#
	# Structure:
	#   input_direction
	#   -> input_direction__do
	#     -> input_direction__switch
	#       -> input_direction__switch_w
	#       -> input_direction__switch_a
	#       -> input_direction__switch_s
	#       -> input_direction__switch_d
	#       -> input_direction__switch_newline
	#       -> input_direction__switch_null
	#       -> input_direction__switch_eot
	#       -> input_direction__switch_default
	#     -> input_direction__switch_post
	#     -> input_direction__bonk_branch
	#   -> input_direction__while

	# Code:
input_direction__do:
	li	$v0, 8			# syscall 8: read_string
	la	$a0, input_direction__buf
	li	$a1, 2
	syscall				# direction = getchar()

	lb	$t0, input_direction__buf

input_direction__switch:
	beq	$t0, 'w',  input_direction__switch_w	# case 'w':
	beq	$t0, 'a',  input_direction__switch_a	# case 'a':
	beq	$t0, 's',  input_direction__switch_s	# case 's':
	beq	$t0, 'd',  input_direction__switch_d	# case 'd':
	beq	$t0, '\n', input_direction__switch_newline	# case '\n':
	beq	$t0, 0,    input_direction__switch_null	# case '\0':
	beq	$t0, 4,    input_direction__switch_eot	# case '\004':
	j	input_direction__switch_default		# default:

input_direction__switch_w:
	li	$t0, NORTH			# direction = NORTH;
	j	input_direction__switch_post	# break;

input_direction__switch_a:
	li	$t0, WEST			# direction = WEST;
	j	input_direction__switch_post	# break;

input_direction__switch_s:
	li	$t0, SOUTH			# direction = SOUTH;
	j	input_direction__switch_post	# break;

input_direction__switch_d:
	li	$t0, EAST			# direction = EAST;
	j	input_direction__switch_post	# break;

input_direction__switch_newline:
	j	input_direction__do		# continue;

input_direction__switch_null:
input_direction__switch_eot:
	li	$v0, 17			# syscall 17: exit2
	li	$a0, 0
	syscall				# exit(0);

input_direction__switch_default:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__invalid_direction
	syscall				# printf("invalid direction: ");

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t0
	syscall				# printf("%c", direction);

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# printf("\n");

	j	input_direction__do	# continue;

input_direction__switch_post:
	blt	$t0, 0, input_direction__bonk_branch	# if (0 <= direction ...
	bgt	$t0, 3, input_direction__bonk_branch	# ... && direction <= 3 ...

	lw	$t1, last_direction	#     last_direction
	sub	$t1, $t1, $t0		#     last_direction - direction
	abs	$t1, $t1		# abs(last_direction - direction)
	beq	$t1, 2, input_direction__bonk_branch	# ... && abs(last_direction - direction) != 2)

	sw	$t0, last_direction	# last_direction = direction;

	move	$v0, $t0
	jr	$ra			# return direction;

input_direction__bonk_branch:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__bonk
	syscall				# printf("bonk! cannot turn around 180 degrees\n");

input_direction__while:
	j	input_direction__do	# while (true);



########################################################################
# .TEXT <get_d_row>
	.text
get_d_row:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_row
	#   -> get_d_row__south:
	#   -> get_d_row__north:
	#   -> get_d_row__else:

	# Code:
	beq	$a0, SOUTH, get_d_row__south	# if (direction == SOUTH)
	beq	$a0, NORTH, get_d_row__north	# else if (direction == NORTH)
	j	get_d_row__else			# else

get_d_row__south:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_row__north:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_row__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <get_d_col>
	.text
get_d_col:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_col
	#   -> get_d_col__east:
	#   -> get_d_col__west:
	#   -> get_d_col__else:

	# Code:
	beq	$a0, EAST, get_d_col__east	# if (direction == EAST)
	beq	$a0, WEST, get_d_col__west	# else if (direction == WEST)
	j	get_d_col__else			# else

get_d_col__east:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_col__west:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_col__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <seed_rng>
	.text
seed_rng:

	# Args:
	#   - $a0: unsigned int seed
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   seed_rng
	#   -> body

	# Code:
	sw	$a0, rand_seed		# rand_seed = seed;

	jr	$ra			# return;



########################################################################
# .TEXT <rand_value>
	.text
rand_value:

	# Args:
	#   - $a0: unsigned int n
	# Returns:
	#   - $v0: unsigned int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1
	# Clobbers: $v0, $t0, $t1
	#
	# Locals:
	#   - `unsigned int rand_seed` cached in $t0
	#
	# Structure:
	#   rand_value
	#   -> body

	# Code:
	lw	$t0, rand_seed		#  rand_seed

	li	$t1, 1103515245
	mul	$t0, $t0, $t1		#  rand_seed * 1103515245

	addiu	$t0, $t0, 12345		#  rand_seed * 1103515245 + 12345

	li	$t1, 0x7FFFFFFF
	and	$t0, $t0, $t1		# (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF

	sw	$t0, rand_seed		# rand_seed = (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF;

	rem	$v0, $t0, $a0
	jr	$ra			# return rand_seed % n;

