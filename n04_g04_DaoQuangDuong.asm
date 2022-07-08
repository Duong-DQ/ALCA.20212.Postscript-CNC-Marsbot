.eqv  HEADING    0xffff8010    	# Integer: An angle between 0 and 359
								# 0 : North (up)
								# 90: East (right)
								# 180: South (down)
								# 270: West  (left)
.eqv  MOVING     0xffff8050  	# Boolean: whether or not to move
.eqv  LEAVETRACK 0xffff8020    	# Boolean (0 or non-0):
								#    whether or not to leave a track
.eqv  WHEREX     0xffff8030    	# Integer: Current x-location of MarsBot
.eqv  WHEREY     0xffff8040    	# Integer: Current y-location of MarsBot

.data
	#postscript [{goc, tg, cat/k cat}, {},...]
	postscript0:	.word	135,4000,0, 225,1414,1, 90,3000,1, 315,1414,1, 270,800,1, 0,2000,0
	postscript1:	.word	90,4000,0, 180,4000,0, 120,4000,1, 150,4000,1, 180,4000,1, 210,4000,1, 240,4000,1, 0,13500,1
	size1: 8
	
.text  
main:
	la 		$t0,postscript1
	lw 		$t1,size1
	li 		$t2,0		#i=0
loop:	
	beq		$t2,$t1,end
	lw		$s0,($t0)		# $s0: goc chuyen dong
	addi	$t0,$t0,4
	lw		$s1,($t0)		# $s1: thoi gian
	addi	$t0,$t0,4
	lw		$s2,($t0)		# $s2: cat/khong cat
	addi	$t0,$t0,4
	
	move	$a0,$s0
	jal		ROTATE
	
	bnez	$s2,is_track
	jal		UNTRACK
	j		endif
	is_track:	
		jal		TRACK
	endif:
	move 	$a0,$s1
	jal		GO
	nop
	addi	$v0,$zero,32
	move    $s1,$a0        
	syscall
	nop
	jal     UNTRACK         	# keep old track
	nop
	jal     TRACK           	# and draw new track line
	nop
	addi 	$t2,$t2,1		# i++
	j loop
            
end_main:
	
#-----------------------------------------------------------
# GO procedure, to start running
# param[in]    none
#-----------------------------------------------------------
GO:     
	li    	$at, MOVING     	# change MOVING port
	addi  	$k0, $zero,1    	# to  logic 1,
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
	addi  	$k0, $zero,1    	# to  logic 1,
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
end: 
	jal STOP
	nop
