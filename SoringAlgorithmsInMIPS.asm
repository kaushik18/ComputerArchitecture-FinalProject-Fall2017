.data
			.align 2
	list: 		.space 100
			.align 2
	array:		.space 100
	size:		.word 0
	instrBubble:	.word 0
	instrHeap:	.word 0
	instrSelection:	.word 0 
	spacebar: 	.asciiz	" "
	askCount: 	.asciiz "How many numbers are to be sorted: "
	askNumbers: 	.asciiz "Enter the list: "
	newline: 	.asciiz "\n"
	prompt1: 	.asciiz "Which sort would you like to use? (Heap = 1, Bubble = 2, Selection = 3): "
	prompt2: 	.asciiz " instructions were executed. "
	prompt3: 	.asciiz "Here is the sorted list: "
	string: 	.asciiz
	 

.text

	lw $s5, instrBubble
	lw $s6, instrSelection
	lw $s7, instrHeap
	
	li $v0, 4				# ask for # of integers to be read
	la $a0, askCount
	syscall
	
	li $v0, 5				# get input
	syscall
	move $s1, $v0
	sw $s1, size
	
	li $v0, 4				# ask for the list
	la $a0, askNumbers
	syscall
	
	li $v0, 8				# get the list
	la $a0, string
	li $a1, 100
	syscall
	
	la $s2, list				# load address of array into s2
	li $v0, 0				
	lb $t6, spacebar			
	jal parser				# parse the string into an array
	jal arrayCopy				# generate a copy of the array 
	
	li $v0, 4
	la $a0, prompt1
	syscall
	
	li $v0, 5				# get input
	syscall
	
	beq $v0, 2, doBubble
	beq $v0, 3, doSelection
	beq $v0, 1, doHeap

doBubble: jal bubbleSort
	li $v0, 1
	move $a0, $s5
	syscall
	li $v0, 4
	la $a0, prompt2
	syscall
	la $a0, prompt3
	syscall
	lw $t1, size
	la $s2, array
	j printArray
doSelection: jal selectionSort
	li $v0, 1
	move $a0, $s6
	syscall
	li $v0, 4
	la $a0, prompt2
	syscall
	la $a0, prompt3
	syscall
	lw $t1, size
	la $s2, array
	j printArray
doHeap: jal HeapSort
	li $v0, 1
	move $a0, $s7
	syscall
	li $v0, 4
	la $a0, prompt2
	syscall
	la $a0, prompt3
	syscall
	lw $t1, size
	la $s2, array
	j printArray
	
################################################         HEAP SORT
  # HEAP SORT ALGORITHM STARTS HERE 
HeapSort: 
  la $a0, array					# a0 is the reference to the array
  lw $a1, size 				# set a1 to the size of the array
  subi $sp, $sp, 12 				# expand stack to add arguments
  sw $a1, 0($sp)  				# size saved onto stack as first argument
  sw $a2, 4($sp)  				# register a2 saved onto stack as second argument
  sw $ra, 8($sp)  				# return address saved onto stack as third argument
  
  move $a2, $a1  				# a2 = a1
  subi $a2, $a2, 1    				# decrement size of array by 1
  addi $s7, $s7, 9
  ble $a2, $zero, endHeap  			# branch to endHeap if size is less than or equal to 0
  
  jal heap  					#jumps and links to heap function
  
  li $a1, 0		 			# Clears register $a1


heapSortLoop:
  lw $t0, 0($a0)				# Loads word from memory address(array reference) to register 
  mul $t1, $a2, 4 				# t1 is set to the number of bytes allocated to array size
  add $t1, $t1, $a0				# t1 = t1 + a0
  
  # Loads and stores values between registers 
  lw $t2, 0($t1)				
  sw $t0, 0($t1)
  sw $t2, 0($a0)
  
  # Decrements size of array, a2 = a1 which was the array reference
  subi $a2, $a2, 1
  # Below jal executes iff a0 = &array, when a1 is set to 0 and a3 is set to size of array - 1
  jal heapBubbleDown  
  # Branches to heap sort loop if a2 != 0 
  addi $s7, $s7, 9
  bnez $a2, heapSortLoop
  
endHeap:
  lw $ra, 8($sp)				# restores return address
  lw $a2, 4($sp)				# restores $a2
  lw $a1, 0($sp)				# restores $a1
  
  addi $sp, $sp, 12				# $sp = $sp+12, stack space purposes
  addi $s7, $s7, 5
  jr $ra					# PC �? (ra)
  
heap: 
  subi $sp, $sp, 12				# $sp = $sp-12, stack space purposes
  sw $a1, 0($sp)				# Stores $a1 on stack
  sw $a2, 4($sp)				# Stores $a2 on stack
  sw $ra, 8($sp)				# Stores return address on stack
  
  # Decrement array size by 1 and then set the new size to $a2
  subi $a2, $a1, 1  
  
  subi $a1, $a1, 1 				 # set index to size - 1
  div $a1, $a1, 2  					
  addi $s7, $s7, 8
  blt $a1, $zero, exitHeap 			 # if index is less than 0 branch to exitHeap funct
  
heapLoop:
  jal heapBubbleDown 
  # Above executes if a0 = &array, and $a1 = index, $a2 = n(size) - 1
  
  subi $a1, $a1, 1
  addi $s7, $s7, 3
  ble $zero, $a1, heapLoop
  
exitHeap:
  lw $ra, 8($sp)				# restores return address
  lw $a2, 4($sp)				# restores $a2
  lw $a1, 0($sp)				# restores $a1
  
  addi $sp, $sp, 12
  addi $s7, $s7, 5
  jr $ra


heapBubbleDown: 
# $a2 = index_end
  move $t0, $a1 				# copy value in $a1 to $to
  mul $t1, $t0, 2  				# $t1 = multiply index by 2 and increment by 1
  addi $t1, $t1, 1				# t1 = t1+1
  addi $s7, $s7, 4
  bgt $t1, $a2, exitBubbleDown			# if $t1 > $a2, then branches to funct exitBubbleDown
  
  
LoopTwo:

  ble $a2, $t1, noinc
  mul $t3, $t1, 4  				# shifts left logical if 0 <= 2 <= 32
  add $t3, $t3, $a0				# t3 = t3 + a0
  
  lw $t3, 0($t3) 				
  mul $t4, $t1, 4 				# 0 ≤ 4 < 32 shift left logical
  addi $t4, $t4, 4 				# t4 = $t1 + 1 array increments
  add $t4, $t4, $a0				# t4 = t4 + a0
  
  lw $t4, 0($t4)  				
  ble $t4, $t3, noinc				# if t4 < t3, branch to noinc funct
  
  addi $t1, $t1, 1  				# t1 = t1 + 1
  addi $s7, $s7, 10
noinc:
  mul $t3, $t0, 4  				
  add $t3, $t3, $a0				# t3 = t3 + a0
  #t4 = arr[index], t3 = &arr[index]
  lw $t4, 0($t3)  				
  
  mul $t5, $t1, 4  
  add $t5, $t5, $a0
  lw $t6, 0($t5)  
  addi $s7, $s7, 7
  ble $t6, $t4, exitBubbleDown
  
  #t4 = arr[index], t6 = arr[child], t3 = &arr[index], t5 = &arr[child]
  sw $t4, 0($t5)
  sw $t6, 0($t3)
  
  # Here we are swappping the index of the array with the new element size
  move $t0, $t1  
  
  mul $t1, $t0, 2   
  addi $t1, $t1, 1
  addi $s7, $s7, 6
  ble $t1, $a2, LoopTwo
  
exitBubbleDown:
  jr $ra
  
##############################################################   BUBBLE SORT
bubbleSort:
	lw $s3, size 	# load in the number of elements minus 1 
	addi $s3, $s3, -1
	la $s1, array	#since that is the max number of loops we will need to sort the list
	li $t4, 1
	addi $s5, $s5, 4
	j outerLoopBubble2
	
outerLoopBubble1:
	beq	$zero, $t4, exitBubble
	addi $s5, $s5, 1
	
outerLoopBubble2: 
	bge	$zero, $s3, exitBubble
	li	$t4, 0		#variable to store if a swap has been made
	la 	$s1, array
	li	$s0, 0	#will serve as counter of how many comparisons we have made (loop counter)
	addi $s5, $s5, 4
innerLoopBubble: 
	bge	$s0, $s3, exitInnerBubble
	lw	$t2, ($s1)	#compare adjacent values
	lw	$t3, 4($s1)	#if the 1st one is greater than the 2nd one, swap. otherwise don't swap
	ble	$t2, $t3, noSwap
	li	$t4, 1
	sw	$t3, ($s1)	#swapping 2 adjacent values
	sw	$t2, 4($s1)
	addi $s5, $s5, 7
noSwap:
	addi	$s1, $s1, 4 	#increment array index to get the next 2 adjacent values
	addi	$s0, $s0, 1	#increment loop counter
	addi $s5, $s5, 3
	j innerLoopBubble
	
exitInnerBubble:
	addi	$s3, $s3, -1	#after each round, at least one element is in order
	addi $s5, $s5, 2
	j outerLoopBubble1	#hence the max number of comparisons will decrease by 1
	
exitBubble:
	jr $ra
	
##################################################################### SELECTION SORT
selectionSort:
	lw $s1, size 
	la $s0, array
	move $s3, $s1	#s1 holds the array size --> s3 holds the loop counter
	lw $t2, ($s0)	#t2 holds the smallest element in the array
	addi $s6, $s6, 4
outerLoop: 
	bge $zero, $s3, exitSort	#exit the sort if we have gone through all of the elements
	move $s2, $s0			#s0 holds the address of the array
	move $t0, $s3			#t0 is the loop counter for the inner loop
	lw $t2, ($s0)	#clears the value of t2 from the last iteration of the loop
	li $t1, 0	#contains the current element in array
	li $t3, 0	#hold the address of the smallest element of array
	addi $s6, $s6, 6
	
innerLoop:
	bge $zero, $t0, exitInner
	lw $t1, ($s2)			# load the element at the current address
	blt $t2, $t1, notFound		# check to see if it is smaller than the current smallest
	move $t2, $t1			# if it is, then store that element and its address
	move $t3, $s2
	addi $s6, $s6, 5
	
notFound:
	addi $t0, $t0, -1
	addi $s2, $s2, 4
	addi $s6, $s6, 3
	j innerLoop
	
exitInner:
	addi $s3, $s3, -1		#once the smallest element has been found
	lw $t6, ($s0)			#place it at the start of the array 
	sw $t2, ($s0)			#and then increment the array index by 4
	sw $t6, ($t3)			#so that we can start working on the rest of the elements
	addi $s0, $s0, 4
	addi $s6, $s6, 6
	j outerLoop
	
exitSort:
	jr $ra
	
#######################################################################################
printArray: 
	beq $t1, $zero, Exit
	subi $t1, $t1, 1
	li $v0, 1				# print array
	lw $a0, ($s2)
	syscall
	addi $s2, $s2, 4
	li  $v0, 4
	la  $a0, spacebar			# print space          
    	syscall
	j printArray
	
############################################################# 
parser:
    	lb      $t0, ($a0)
    	slti    $t2, $t0, 58			# if number < 9
    	seq     $t3, $t0, 0			# if number = nul
    	seq     $t4, $t0, 32			# if number = space 		
    	seq	$t5, $t0, 10			# if number = newline
    	beq     $t6, $t0, storeArray		
    	beq     $t2, $zero, storeArray
    	bne     $t3, $zero, storeArray
    	bne     $t5, $zero, storeArray
    	mul 	$v0, $v0, 10			# number * 10 
    	addi    $t0, $t0, -48
    	add     $v0, $v0, $t0			# add the next digit to the number
    	addi    $a0, $a0, 1			# increment to the next byte of the string
    	j   parser
    
storeArray:
    	sw $v0, ($s2)
    	bne $t3, $zero, exitParser		#if the last byte is nul, exit parser
    	bne $t5, $zero, exitParser		#if the last byte is newline, exit parser
    	add $s2, $s2, 4
    	addi    $a0, $a0, 1
    	li $v0, 0
    	j parser
    
exitParser:
    	jr      $ra         # return
    	
######################################################################### COPY STRING
arrayCopy:
	lw $s4, size
	la $t1, list
	la $t2, array
loop: 	bge $zero, $s4, endLoop
	lw $t3, ($t1)
	sw $t3, ($t2)
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	addi $s4, $s4, -1
	j loop

endLoop: jr $ra

########################################################################## 
Exit: 	li 	$v0, 10
	syscall
