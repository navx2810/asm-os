# Matt Fetterman
# Midterm

.section .data

Input: .byte '3'

Morning: .asciz "Good Morning\n"
Afternoon: .asciz "Good Afternoon\n"
Evening: .asciz "Good Evening\n"
Welcome: .asciz "Welcome\n"

.section .text
.globl _start

_start:
	movb	Input, %bl		# Move 3 into BL
	call	Switch
	call 	EndProg

Switch:
	cmpb	$'1', %bl			# Check if BL is 1
	je	S_One

	cmpb	$'2', %bl			# Check if BL is 2
	je	S_Two

	cmpb	$'3', %bl			# Check if BL is 3
	je	S_Three

	movl	$Welcome, %eax	# If BL was not 1, 2, or 3, Print the default statement
	call	Print
	ret

S_One:
	movl	$Morning, %eax
	call	Print
	ret

S_Two:
	movl	$Afternoon, %eax
	call	Print
	ret

S_Three:
	movl	$Evening, %eax
	call	Print
	ret

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

	popf
	popl	%edx
	popl	%ecx
	popl	%ebx

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



EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
