.data
    aa: .asciiz "-----------"
    prompt: .asciiz "Enter the matrix size in terms of its dimensions (N): "
    rowPrompt: .asciiz "Enter the row number you want to display the element of: "
    colPrompt: .asciiz "Enter the column number you want to display the element of: "
    rowSumPrompt: .asciiz "Enter the row number you want to display the summation of: "
    colSumPrompt: .asciiz "Enter the column number you want to display the summation of: "
    menuPrompt: .asciiz "Enter (1) to display a desired element, (2) to obtain summation of matrix elements row-major (row by row) summation, (3) to obtain summation of matrix elements column-major (column by column) summation "

.text
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 5
    syscall
    
    move $s0, $v0 # dimension of matrix

    move $s3, $s0 # N

    mul $s0, $s0, $s0 # size of matrix
    move $s2, $s0 # size

    addi $s1, $0, 2

    mul $s1, $s0, $s1 # size of matrix * 2 (space of matrix)

    li $v0, 9 # dynamic memory allocation
    move $a0, $s1 # allocated size * 2 space
    syscall
 
    move $s1, $v0 # pointer to matrix' beginning

    move $a0, $s1
    move $a1, $s2

    jal init
    
    disp:
    move $a0, $s3 # passing N
    move $a1, $s1 # passing pointer
    jal displayElements

    rowMaj:
    move $a0, $s3 # passing N
    move $a1, $s1 # passing pointer
    jal rowMajorSum
    move $s4, $v0 # row major summation

    colMaj:
    move $a0, $s3 # passing N
    move $a1, $s1 # passing pointer
    jal colMajorSum
    move $s5, $v0 # col major summation
    
    li $v0, 10
    syscall

init:  
    addi $sp, $sp, -20 
    sw $s3, 16($sp) 
    sw $s0, 12($sp) 
    sw $s2, 8($sp)     
    sw $s1, 4($sp)      
    sw $ra, 0($sp)      

    move $s1, $a0   
    move $s2, $a1

    addi $s0, $zero, 0

    traverse: 
        addi $s0, $s0, 1

        lh	$s3, 0($s1) 
        add $s3, $s3, $s0
        sh $s3, 0($s1)

        li $v0, 1
        lh $a0, 0($s1)
        syscall

        addi $s1, $s1, 2 # increment pointer by 2 (word size)
        
        blt $s0, $s2, traverse 

    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s0, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20

    jr $ra

displayElements:

    addi $sp, $sp, -16
    sw $s0, 12($sp) 
    sw $s1, 8($sp)     
    sw $s3, 4($sp)      
    sw $ra, 0($sp)  

    move $s1, $a0 # N
    move $s2, $a1 # pointer to beginning

    li $v0, 4
    la $a0, rowPrompt
    syscall

    li $v0, 5
    syscall

    move $s0, $v0 # row no (i)

    li $v0, 4
    la $a0, colPrompt
    syscall

    li $v0, 5
    syscall

    move $s3, $v0 # col no (j)

    subi $s0, $s0, 1 # i - 1 
    subi $s3, $s3, 1 # j - 1

    mul $s0, $s0, $s1 # (i-1)*N

    add $s0, $s0, $s3 # (i-1) * N + (j - 1)

        addi $s3, $zero, 2 

    mul $s0, $s0, $s3 # ( (i-1)*N+(j - 1) ) * 2 === displacement

    add $s2, $s2, $s0 

    # displaying the desired element
    li $v0, 1  
    lh $a0, 0($s2) 
    syscall 

    lw $ra, 0($sp)
    lw $s3, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    addi $sp, $sp, 16

    jr $ra

rowMajorSum:
    
    addi $sp, $sp, -24
    sw $s0, 20($sp) 
    sw $s1, 16($sp)     
    sw $s2, 12($sp)  
    sw $s3, 8($sp) 
    sw $s4, 4($sp)       
    sw $ra, 0($sp)  

    move $s0, $a0 # N
    move $s1, $a1 # pointer

    li $v0, 4
    la $a0, rowSumPrompt
    syscall

    li $v0, 5
    syscall

    move $s2, $v0 # row no  
    subi $s2, $s2, 1
    mul $s2, $s2, $s0
    add $s2, $s2, $s2 # where to start traversing

    add $s1, $s1, $s2

    addi $s3, $zero, 0
    
    # s0 === N

    traverseRow:  

        lh $s4, 0($s1)

        add $s3, $s3, $s4 # sum

        addi $s1, $s1, 2
        subi $s0, $s0, 1 
        bgt $s0, $zero, traverseRow

    li $v0, 1
    move $a0, $s3
    syscall

    move $v0, $s3

    lw $ra, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    addi $sp, $sp, 24

    jr $ra


colMajorSum:

    addi $sp, $sp, -32
    sw $s6, 28($sp) 
    sw $s5, 24($sp) 
    sw $s0, 20($sp) 
    sw $s1, 16($sp)     
    sw $s2, 12($sp)  
    sw $s3, 8($sp) 
    sw $s4, 4($sp)       
    sw $ra, 0($sp) 

    move $s0, $a0 # N
    move $s1, $a1 # pointer

    li $v0, 4
    la $a0, colSumPrompt
    syscall

    li $v0, 5
    syscall

    move $s2, $v0 # col no  

    add $s1, $s1, $s2 # add col no to find first element's address
    subi $s1, $s1, 1 # minus one - since index starts from 1, not 0

    addi $s5, $zero, 2 # 2
    mul $s5, $s0, $s5  # multiply N by 2 to find how many to add to pointer to find the other element in the following row yet in the same column

    addi $s3, $zero, 0 
    addi $s6, $zero, 0

    traverseCol:
        lh  $s4, 0($s1) # load halfword

        add $s3, $s3, $s4 # add to summation
        add $s1, $s1, $s5 # go to the next row same col

        addi $s6, $s6, 1
        blt $s6, $s0, traverseCol   

    li $v0, 1
    move $a0, $s3
    syscall

    move $v0, $s3 # summation of desired column

    lw $ra, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    addi $sp, $sp, 32

    jr $ra