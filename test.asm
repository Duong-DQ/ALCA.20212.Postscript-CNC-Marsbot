.eqv 	IN_ADRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv 	OUT_ADRESS_HEXA_KEYBOARD 	0xFFFF0014
# receive row and column of the key pressed, 0 if not key pressed 
# equal 0x11, means that key button 0 pressed.
# equal 0x14, means that key button 4 pressed.
# equal 0x18, means that key button 8 pressed.
.eqv  HEADING    0xffff8010    	# Integer: An angle between 0 and 359
								# 0 : North (up)
								# 90: East (right)
								# 180: South (down)
								# 270: West  (left)
.eqv  MOVING     0xffff8050  	# Boolean: whether or not to move
.eqv  LEAVETRACK 0xffff8020    	# Boolean (0 or non-0): whether or not to leave a track

.data
	#postscript [{goc, tg, cat/k cat}, {},...], -1 = end
	postscript0:	.word	135,2000,0, 180,12000,1, 60,3000,1, 30,3000,1, 0,3000,1, 330,3000,1, 300,3000,1, 90,10000,0, 250,3000,1 200,3000,1, 180,3500,1, 160,3000,1, 110,3000,1, 90,6000,0, 270,4000,1, 0,12000,1, 90,4000,1, 180,6000,0, 270,4000,1, 90,10000,0,-1 
	postscript4:	.word	120,3500,0, 180,12000,1, 270,2000,0, 90,4000,1, 0,12000,0, 270,4000,1, 90,10000,0, 250,3000,1 200,3000,1, 180,3500,1, 160,3000,1, 110,3000,1, 90,4000,0, 0,12000,1, 270,2000,0, 90,4000,1, 90,2000,0,-1
	postscript8:	.word	90,6000,0, 180,6000,0, 210,3000,1, 270,3000,1, 150,3000,1, 210,3000,1, 90,3000,1, 150,3000,1, 30,3000,1, 90,3000,1, 330,3000,1, 30,3000,1, 270,3000,1, 330,3000,1, 90,2000,0,-1
	str1:  .asciiz ","
	str2:  .asciiz " - "
	
.text
Key_READ:
	li 		$t7, IN_ADRESS_HEXA_KEYBOARD
 	li 		$t8, OUT_ADRESS_HEXA_KEYBOARD
 	move	$t5, $zero							 
	polling:
		move	$t4, $t5								# previously pressed key
		move 	$t5, $zero				
		
		li 		$t6, 0x01 								# check row 1 with key 0, 1, 2, 3
		sb 		$t6, 0($t7) 							# must reassign expected row
 		lb 		$t6, 0($t8) 							# read scan code of key button
		or 		$t5, $t5, $t6
 		
 		li 		$t6, 0x02 								# check row 1 with key 4, 5, 6, 7
		sb 		$t6, 0($t7) 							# must reassign expected row
 		lb 		$t6, 0($t8) 							# read scan code of key button
		or 		$t5, $t5, $t6
		
		li 		$t6, 0x04 								# check row 1 with key 8, 9, A, B
		sb 		$t6, 0($t7) 							# must reassign expected row
 		lb 		$t6, 0($t8) 							# read scan code of key button
		or 		$t5, $t5, $t6
 		
 		sub		$t4, $t4, $t5
 		beqz	$t4, back_to_polling
 		beq		$t5, 0x11, key0_pressed
 		beq		$t5, 0x12, key4_pressed
 		beq		$t5, 0x14, key8_pressed
	back_to_polling: 
		li    $a0, 100
		addi	$v0, $zero, 32        
		syscall	
		j 		polling 								# continue polling

	#-------------------set_postscript--------------------------
	key0_pressed:												
		la 		$t0, postscript0																				
		j		Marbot_DRAW									
	key4_pressed:												
		la 		$t0, postscript4									
		j		Marbot_DRAW									
	key8_pressed:												
		la 		$t0, postscript8							
		j		Marbot_DRAW									
# END_KEY_READING:


Marbot_DRAW:
	read_postscript:	
		lw		$s0, ($t0)		# $s0: goc chuyen dong
		beq		$s0, -1, end_read_postscript
		addi	$t0, $t0, 4
		lw		$s1, ($t0)		# $s1: thoi gian
		addi	$t0, $t0, 4
		lw		$s2, ($t0)		# $s2: cat/khong cat
		addi	$t0, $t0, 4
	
		jal		__console_print
		
		
		move	$a0, $s0
		jal		ROTATE
		
		beqz	$s2, not_track
		jal		TRACK
		not_track:
		jal		GO
		move    $a0, $s1
		addi	$v0, $zero, 32        
		syscall	
		jal		STOP
		jal		UNTRACK
		addi 	$t2, $t2, 1			# i++
		j read_postscript
	
#-----------------------------------------------------------
# GO procedure, to start running
# param[in]    none
#-----------------------------------------------------------
GO:     
	li    	$at, MOVING     	# change MOVING port
	addi  	$k0, $zero, 1    	# to  logic 1,
	sb    	$k0, 0($at)     	# to start running
	nop       
	jr    	$ra
	nop
	
#-----------------------------------------------------------
# STOP procedure, to stop running
# param[in]    none
#-----------------------------------------------------------
STOP:     
	li    	$at, MOVING     	# change MOVING port TO 0
	sb    	$zero, 0($at)     	# to stop running
	nop       
	jr    	$ra
	nop
	
#-----------------------------------------------------------
# TRACK procedure, to start drawing line 
# param[in]    none
#-----------------------------------------------------------
TRACK:  
	li    	$at, LEAVETRACK 	# change LEAVETRACK port
	addi  	$k0, $zero, 1    	# to  logic 1,
	sb    	$k0, 0($at)     	# to start tracking
	nop
	jr    	$ra
	nop
	
#-----------------------------------------------------------
# UNTRACK procedure, to stop drawing line 
# param[in]    none
#-----------------------------------------------------------
UNTRACK:  
	li    	$at, LEAVETRACK 	# change LEAVETRACK port to 0
	sb    	$zero, 0($at)     	# to start tracking
	nop
	jr    	$ra
	nop  

#-----------------------------------------------------------
# ROTATE procedure, to rotate the robot
# param[in]    $a0, An angle between 0 and 359
#            		0 : North (up)
#                   90: East  (right)
#                  180: South (down)
#                  270: West  (left)
#-----------------------------------------------------------
ROTATE: 
	li    	$at, HEADING    # change HEADING port
	sw    	$a0, 0($at)     # to rotate robot
	nop
	jr    	$ra
	nop

__console_print:			# print s0, s1, s2
	la 		$a0, str2
    li 		$v0, 4
    syscall
	li 		$v0, 1
    move 	$a0, $s0
    syscall
    la 		$a0, str1
    li 		$v0, 4
    syscall
    li 		$v0, 1
    move 	$a0, $s1
    syscall
    la 		$a0, str1
    li 		$v0, 4
    syscall
    li 		$v0, 1
    move 	$a0, $s2
    syscall
    jr    	$ra

end_read_postscript: 
	jal STOP
	j	back_to_polling
	nop
