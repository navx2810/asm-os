.section .data

Alphabet: .ascii "ALPHA\0   ", "BRAVO\0   ", "CHARLIE\0 ", "DELTA\0   ", "ECHO\0    ", "FOXTROT\0 ", "GOLF\0    ", "HOTEL\0   ", "INDIA\0   ", "JULIETT\0 ", "KILO\0    ", "LIMA\0    ", "MIKE\0    ", "NOVEMBER\0", "OSCAR\0   ", "PAPA\0    ", "QUEBEC\0  ", "ROMEO\0   ", "SIERRA\0  ", "TANGO\0   ", "UNIFORM\0 ", "VICTOR\0  ", "WHISKEY\0 ", "XRAY\0    ", "YANKEE\0  ", "ZULU\0    "
Space: .ascii " "

.section .text
.globl _start

_start:
	call Loop
	call EndProg

Loop:
	movl	$0, %ecx
	jmp		L1

	ret
L1:
	pushl	%esi		# Save any ESI vars
	movl	%ecx, %ebx	# Place the current counter into EBX for multiplication
	imull	$9, %ebx	# Multiply the counter by 9 to get the array pointer math to locate the alphabet start

	movl	$Alphabet, %esi	# Put the pointer into ESI

	addl	%ebx, %esi		# Add the array pointer math stored in EBX to get the offset position for the military letter

	movl	%esi, %eax		# Place the pointer into EAX to get the length of the military letter
	call 	strlen
	movl	%eax, %ebx		# Move the length returned in EAX to EBX
	movl	%esi, %eax		# Put the pointer back into EAX to print
	call PrintBuf
	call PrintSpace

	popl	%esi
	jmp 	L_CONT

L_CONT:
	inc %ecx
	cmp	$25, %ecx
	jb	L1
	ret

strlen:
	pushl	%edi		# Save the registers
				# so the caller doesnt
	pushl	%ecx		# need to worry about
				# data loss in the regsters
	pushf			# Save the falgs as well

	movl	%eax, %edi	# move address to %esi for evaluation
	movl	$256, %ecx	# Maximum string size is 255
	pushl	%ecx		#   This prevents a infinate loop
	movb	$0, %al		# Search string for a NULL
	cld			# Clear flags to move forward through string
	repne	scasb		#   Look for a NULL and stop when found
				#   or when 256 characters have been checked
				#   %ecx will be decrimented, %edi Incrimented
	popl	%eax		# Get maximum size
	subl	%ecx, %eax	# Find the length of the string for the return

	popf
	popl	%ecx
	popl	%edi		# Restore all of the registers used

	ret		# Go back to the calling instruction

PrintBuf:
	pushl	%eax		# Save the registers
	pushl	%ebx		# so the caller doesnt
	pushl	%ecx		# need to worry about
	pushl	%edx		# data loss in the regsters
	pushf			# Save the falgs as well

	movl	%eax, %ecx	# set buffer address for print
	movl	%ebx, %edx	# Set buffer length for print

	movl	$4, %eax	# prepare print function
	movl	$1, %ebx	# send buffer to screen
	int	$0x80

	popf
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax		# Restore all of the registers used

	ret		# Go back to the calling instruction

PrintSpace:
	pushl	%eax		# Save the registers
	pushl	%ebx		# so the caller doesnt
	pushl	%ecx		# need to worry about
	pushl	%edx		# data loss in the regsters
	pushf			# Save the falgs as well

	movl	$4, %eax	# Print a new Line Character
	movl	$1, %ebx
	movl	$Space, %ecx
	movl	$1, %edx
	int	$0x80

	popf
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax		# Restore all of the registers used

	ret			# Go back to the calling instruction


EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
