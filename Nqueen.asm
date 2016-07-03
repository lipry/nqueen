.data

size_string: .asciiz "Inserisci la dimensione della scacchiera: "
solution_string: .asciiz "Le tue soluzioni sono:\n"

.text
main: 

la $a0, size_string                   
li $v0, 4
syscall                               #stampo la stringa

li $v0, 5
syscall                               #input N

addi $t1, $v0, 0                      #$t1 = N
	
la $a0, solution_string               
li $v0, 4
syscall                               #stampo la stringa

sub $sp, $sp, $t1                     #alloco N byte nello stack
addi $t2, $sp, 0                      #$t2 = position


#evita disallineamenti dello stack
addi $t0, $zero, 4                    #$t0 = 4
div $t1, $t0                          
mfhi $t3                              # $t3 = N mod 4
sub $t0, $t0, $t3                     # $t0 = 4 - (N mod 4)
sub $sp, $sp, $t0                     # abbasso lo stack di 4 - (N mod 4)
                         

#chiamata solve
addi $a0, $zero, 0                    #$a0 <-- colonna
addi $a1, $t1, 0					  #$a1 <-- N
addi $a2, $t2, 0					  #$a2 <-- array
jal solve                             #chiamo solve


li $v0, 10                            
syscall 							  #end




#---------> isSafe <----------
isSafe:

	addi $sp, $sp, -4
	sw $s2, 0($sp)
	
	addi $s2, $a2, 0                      #salvo i parametri
	
	addi $t0, $zero, 0                    #init $t0 = 0
loopSafe:
    beq $t0, $a0, returnTrue              # if(i != queen_number) loop
	add $t1, $t0, $s2					  #$t1 = other_row_position
	lb $t1, 0($t1)                        # tiro fuori l i-esimo dato dall array
	beq $t1, $a1, returnFalse             #if(other_row_pos == row_pos
	sub $t2, $a0, $t0                     #      queen_number - i
	sub $t3, $a1, $t2                     #       row_position - (queen_number -i)
	beq $t1, $t3, returnFalse             # ||other_row_pos == row_position - (queen_number - i)
	add $t3, $a1, $t2                     #        row_position + (queen_number -i)
	beq $t1, $t3, returnFalse             # ||other_row_pos == row_position + (queen_number - i))
	addi $t0, $t0, 1                      # i++
	j loopSafe

	
returnTrue:	
	addi $v0, $zero, 1                    #return true
	j endSafe
returnFalse:
	addi $v0, $zero, 0                    #return false	
	
endSafe:
	
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

#----------> SOLVE <--------------

solve:
	addi $sp, $sp, -20                      #sistemo lo stack
	sw $ra, 0($sp)
	sw $s3, 4($sp)
	sw $s0, 8($sp)                          #indice ciclo
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	 
	add $s3, $a0, $zero  
	add $s1, $a1, $zero                     #salvo i parametri 
	add $s2, $a2, $zero
	
	
check:  
	bne $s3, $s1, recursion                 #condizione di ricorsione

	
	addi $t0, $zero, 0                      #stampa soluzione
loopStampa:
	add $t1, $t0, $s2
	lb $a0, 0($t1)
	li $v0, 1
	syscall
	li $a0, 32
	li $v0, 11
	syscall
	addi $t0, $t0, 1
bne $t0, $s1, loopStampa 
	
	
	li $v0, 11
	li $a0, 10                            
	syscall 	                      
	
	j end                                  #fine stampa
	
recursion:
    addi $s0, $zero, 0                 #$s0 = i = 0    init $s0
loop:
	add $a0, $s3, $zero				   #$a0 <-- k
	add $a1, $s0, $zero                #$a1 <-- i
	add $a2, $s2, $zero                #$a2 <-- array
	jal isSafe				           #chiamo isSafe
	beq $v0, $zero, fineif
		add $t0, $s2, $s3              # position[k]                 
		sb $s0, 0($t0)                 #posiziono la regina aggiornando l array
		addi $a0, $s3, 1               #$a0 <-- k+1
		addi $a1, $s1, 0               #$a1 <-- N
		addi $a2, $s2, 0 			   #$a2 <-- array
		jal solve                      #chiamo isSolve
	fineif:
	addi $s0, $s0, 1                   #i++
	bne $s0, $s1, loop                 #for condition (i<N)
end:	
	
	lw $s2, 16($sp)						
	lw $s1, 12($sp)
	lw $s0, 8($sp)                     
	lw $s3, 4($sp)
	lw $ra, 0($sp) 
	addi $sp, $sp, 20					#rialzo lo stack
	jr $ra