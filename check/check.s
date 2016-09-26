.section .data

	Prompt:	.asciz "Please enter a decimal number in the form of: 999.99\n"

	NewLine:	.asciz "\n"
	Space:		.asciz " "

.section .bss

	.comm	MsgBuf, 1

.section .text
.globl _start

_start:
	movl	$Prompt,	%eax
	call	Print
	call	EndProg	


######################################################
#
#	Printing Functions
#
######################################################

# { A function to print the buffer placed in eax }
#	EAX = Buffer
Print:
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushf

	movl	%eax,	%edx		# Put the prompt into D for latter
	call	strlen
	movl	%eax,	%ebx		# Place the length of the prompt into B
	movl	%edx,	%eax		# Place the string into A
	call 	PrintBuf

	popl	%ebx
	popl	%ecx
	popl	%edx
	popf

	ret

######################################################
#
#	Outside Functions
#
######################################################


PrintBuf:
	pushl	%eax				# Save the registers
	pushl	%ebx				# so the caller doesnt
	pushl	%ecx				# need to worry about
	pushl	%edx				# data loss in the regsters
	pushf						# Save the falgs as well

	movl	%eax, %ecx			# set buffer address for print
	movl	%ebx, %edx			# Set buffer length for print

	movl	$4, %eax			# prepare print function
	movl	$1, %ebx			# send buffer to screen
	int		$0x80

	popf
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax				# Restore all of the registers used

	ret							# Go back to the calling instruction

strlen:
	pushl	%edi				# Save the registers
								# so the caller doesnt
	pushl	%ecx				# need to worry about
								# data loss in the regsters
	pushf						# Save the falgs as well

	movl	%eax, %edi			# move address to %esi for evaluation
	movl	$256, %ecx			# Maximum string size is 255
	pushl	%ecx				#   This prevents a infinate loop
	movb	$0, %al				# Search string for a NULL
	cld							# Clear flags to move forward through string
	repne	scasb				#   Look for a NULL and stop when found
								#   or when 256 characters have been checked
								#   %ecx will be decrimented, %edi Incrimented
	popl	%eax				# Get maximum size
	subl	%ecx, %eax			# Find the length of the string for the return

	popf
	popl	%ecx
	popl	%edi				# Restore all of the registers used

	ret							# Go back to the calling instruction

PrintNL:
	pushl	%eax				# Save the registers
	pushl	%ebx				# so the caller doesnt
	pushl	%ecx				# need to worry about
	pushl	%edx				# data loss in the regsters
	pushf						# Save the falgs as well

	movl	$4, %eax			# Print a new Line Character
	movl	$1, %ebx
	movl	$NewLine, %ecx
	movl	$1, %edx
	int		$0x80

	popf
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax				# Restore all of the registers used

	ret							# Go back to the calling instruction

PrintSpace:
	pushl	%eax				# Save the registers
	pushl	%ebx				# so the caller doesnt
	pushl	%ecx				# need to worry about
	pushl	%edx				# data loss in the regsters
	pushf						# Save the falgs as well

	movl	$4, %eax			# Print a new Line Character
	movl	$1, %ebx
	movl	$Space, %ecx
	movl	$1, %edx
	int		$0x80

	popf
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax				# Restore all of the registers used

	ret							# Go back to the calling instruction

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
