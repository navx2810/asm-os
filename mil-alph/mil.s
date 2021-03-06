.section .data

Alphabet: .ascii "ALPHA\0   ", "BRAVO\0   ", "CHARLIE\0 ", "DELTA\0   ", "ECHO\0    ", "FOXTROT\0 ", "GOLF\0    ", "HOTEL\0   ", "INDIA\0   ", "JULIETT\0 ", "KILO\0    ", "LIMA\0    ", "MIKE\0    ", "NOVEMBER\0", "OSCAR\0   ", "PAPA\0    ", "QUEBEC\0  ", "ROMEO\0   ", "SIERRA\0  ", "TANGO\0   ", "UNIFORM\0 ", "VICTOR\0  ", "WHISKEY\0 ", "XRAY\0    ", "YANKEE\0  ", "ZULU\0    "
NewLine:	.asciz "\n"
Space:		.asciz " "

Prompt:	  .asciz "Please enter a sentence with a character limit of 256.\n"

.section .bss
	.comm	MsgBuf, 1

.section .text
.globl _start

_start:
	movl	$Prompt, %eax
	call	Print

	call	Read

	call 	Process
	call	PrintNL
	call 	EndProg

# { Process the letters in the buffer to print the corresponding code }
Process:
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushf

	movl	$MsgBuf, %eax	# Get the length of the buffer
	call	strlen
	movl	%eax, %edx		# Put the length of the buffered input into EDX
	subl	$2, %edx		# Remove the Line Feed and Carriage Return portions
	movl	$0, %ecx		# Set the counter variable to 0
	call	P_LOOP

	popl	%eax
	popl	%ebx
	popl	%ecx
	popl	%edx
	popf

	ret

# { The loop for getting the next character }
#	ECX = Increment counter
#	EDX = Length of buffer
P_LOOP:
#	{{{ Get The next character present in the buffer }}}
	movl 	$0, %eax
	movl 	$MsgBuf, %esi
	addl 	%ecx,	%esi		# Increment to next character
	movb 	(%esi), %al			# Place next character into AL

#	{{ Check if character is a space }}
	cmpb	$32, %al
	je		P_SPACE

#	{{ Check to see if character is upper or lower case }}
	cmpb	$90, %al
	jbe		P_UPPER
	jmp		P_LOWER

	jmp		P_CONT
	ret

# { Branch to handle the character code in AL if it's an upper-case character on the ASCII table }
P_UPPER:
	subb	$65, %al			# Offset the ASCII value by 65 to set A=0 and Z=25
	jmp		P_CMP

# { Branch to handle the character code in AL if it's a lower-case character on the ASCII table }
P_LOWER:
	subb	$97, %al			# Offset the ASCII value by 97 to set a=0 and z=25
	jmp		P_CMP

# { Branch to handle the character code in AL if it's a space character on the ASCII table }
P_SPACE:
	call	PrintNL				# Just print a new line character
	jmp		P_CONT

# { Branch to compare the clamped ASCII character if it's within the alphabet range, 0-25 }
P_CMP:
#	{{ Check to see if the character is out of range of what we want, 0-25 }}
	cmpb	$0, %al
	jb		P_CONT
	cmpb	$25, %al
	ja		P_CONT

	jmp		P_PRINT				# The character is acceptable

# { Branch to print the military alphabet message }
P_PRINT:
#	{{ Print the associated military code for the acceptable letter in AL }}
	pushl	%eax
	pushl	%esi
	pushl	%ebx

	imull	$9, %eax			# Multiply counter by 9 to get the array ptr math to locate the military letter start

	movl	$Alphabet, %esi		# Make a pointer into ESI
	addl	%eax, %esi			# Walk the pointer to the alphabet location

	movl	%esi, %eax
	call	strlen
	movl	%eax, %ebx
	movl	%esi, %eax
	call	PrintBuf
	call 	PrintSpace

	popl	%eax				# Restore EAX to the AL ASCII value
	popl	%ebx
	popl	%esi
	jmp		P_CONT

# { Increment the counter and proceed through another loop }
P_CONT:
	inc		%ecx
	cmp		%edx,	%ecx
	jb		P_LOOP
	ret

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

# { Accept 256 characters into the MsgBuffer from stdin }
Read:

	movl	$0,	%ebx
	movl	$3, %eax
	movl	$MsgBuf,	%ecx
	movl	$256,	%edx
	int 	$0x80

	ret

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

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int		$0x80
