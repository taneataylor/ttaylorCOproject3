# N = 31
.data
  emptyMsg: .asciiz "Input is empty."
  errorMsg: .asciiz "Input is too long."
  userMsg: .space 500
  invalidMsg: .asciiz "Invalid base-31 number."

.text
exit:  # exit function
  li $v0, 10 # loads exit/10
  syscall
  
error_empty_input:  # empty case
  la $a0, emptyMsg  # load emptyMsg string into register $a0  
  li $v0, 4  # print string
  syscall
  j exit  # jumps to exit function
  
error_long_input:  # long input case
  la $a0, errorMsg  # load errorMsg string into register
  li $v0, 4
  syscall
  j exit
  
error_invalid_input:  # invalid input case
  la $a0, invalidMsg  # loads invalidMsg string to register
  li $v0, 4
  syscall
  j exit

main:
  li $v0, 8  # reads the string in
  la $a0, userMsg
  li $a1, 250 # loads 250 into a1 register
  syscall
  
delete_left_spaces:  # deletes spaces from left side
  li $t3, 32  # $t3 = 32(space)
  lb $t4, 0($a0)
  beq $t3, $t4, delete_first_char  # branch to delete_first_char if $t3 == $t4
  move $t4, $a0  # copies value from $t4 register to $a0
  j input_length  # jumps to input_length function
  
delete_first_char:  # deletes first character
  addi $a0, $a0, 1    # $a0 = $a0 + 1
  j delete_left_spaces  # jumps to delete_left_spaces
 
input_length:
  addi $t0, $t0, 0  # $t0 = $t0 + 0
  addi $t1, $t1, 10    # $t1 = $t1 + 10
  add $t2, $t2, $a0    # $t2 = $t2 + $a0(1)

len_iter:
  lb $t8, 0($a0)  # loads byte into temp
  beqz $t8, len_found  
  beq $t8, $t1, len_found  # branches if equal
  addi $a0, $a0, 1 
  addi $t0, $t0, 1
  j len_iter  # jumps to len_iter function
  
len_found:
  beqz $t0, error_empty_input
  slti $t9, $t0, 5  # if $t0 is less than $t3, sets $t3 to 1
  beqz $t9, error_long_input
  move $a0, $t2  # $a0 == $t4
  j check_strings  # jumps to check_strings function
  
check_strings:  # function that checks user/input string
  lb $t5, 0($a0)  # takes memory from $t5 and place in $a0
  beqz $t5, conversion_prep
  beq $t5, $t1, conversion_prep
  slti $t6, $t5, 48
  bne $t6, $zero, error_invalid_input
  slti $t6, $t5, 58
  bne $t6, $zero, move_char
  slti $t6, $t5, 65
  bne $t6, $zero, error_invalid_input
  slti $t6, $t5, 86
  bne $t6, $zero, move_char
  slti $t6, $t5, 97
  bne $t6, $zero, error_invalid_input
  slti $t6, $t5, 118       
  bne $t6, $zero, move_char
  bgt $t5, 119, error_invalid_input  

move_char:  # function that moves char in string forward
  addi $a0, $a0, 1
  j check_strings # jumps to check_strings function
  
conversion_prep:  # function that prepares values for conversion
  move $a0, $t4
  addi $t7, $t7, 0
  add $s0, $s0, $t0
  addi $s0, $s0, -1
  li $s3, 3  # loads for saved register 3
  li $s2, 2  # loads for saved register 2
  li $s1, 1  # loads for saved register 1
  li $s5, 0  # loads for saved register 5
  
base_converter:  # calculates base conversion
  lb $s4, 0($a0)
  beqz $s4, print_answ
  beq $s4, $t1, print_answ
  slti $t6, $s4, 58
  bne $t6, $zero, base_10_conv
  slti $t6, $s4, 88
  bne $t6, $zero, base_33_upper
  slti $t6, $s4, 120
  bne $t6, $zero, base_33_lower


base_10_conv:
  addi $s4, $s4, -48
  j compiled_answ  # jumps to compiled_answ

base_33_upper:
  addi $s4, $s4, -55
  j compiled_answ  # jumps to compiled_answ
  
base_33_lower:
  addi $s4, $s4, -87

compiled_answ:  # compacts nums for final answer
  beq $s0, $s3, first_int
  beq $s0, $s2, second_int
  beq $s0, $s1, third_int
  beq $s0, $s5, fourth_int
  
# functions for integers(4)
first_int: 
  li $s6, 29791 # 31^3
  mult $s4, $s6
  mflo $s7
  add $t7, $t7, $s7
  addi $s0, $s0, -1
  addi $a0, $a0, 1
  j base_converter  # jumps to base_converter function

second_int:
  li $s6, 961 # 31^2
  mult $s4, $s6
  mflo $s7
  add $t7, $t7, $s7
  addi $s0, $s0, -1
  addi $a0, $a0, 1
  j base_converter  # jumps to base_converter function
  
third_int:
  li $s6, 31
  mult $s4, $s6
  mflo $s7
  add $t7, $t7, $s7
  addi $s0, $s0, -1
  addi $a0, $a0, 1
  j base_converter  # jumps to base_converter function

fourth_int:
  li $s6, 1  # 31 ^ 0
  mult $s4, $s6
  mflo $s7
  add $t7, $t7, $s7
  
print_answ:  # prints final answer
  li $v0, 1
  move $a0, $t7
  syscall

j exit  # jumps to exit/exit