# Program:	Print the Military alphabet for each input value
# Author:	Matt Fetterman
# Date:		09/16/2016

.section .data
Alphabet:	.asciz	"ALPHA","BRAVO","CHARLIE","DELTA","ECHO","FOXTROT","GOLF","HOTEL","INDIA","JULIETT","KILO","LIMA","MIKE","NOVEMBER","OSCAR","PAPA","QUEBEC","ROMEO","SIERRA","TANGO","UNIFORM","VICTOR","WHISKEY","XRAY","YANKEE","ZULU"
AlphaSize:	.int	5,	5,	7, 	5,	4,	7,	4,	5,	5,	7,	4,	4,	4,	8,	5,	4,	6,	5,	6,	5,	7,	6,	7,	4,	6,	4
AlphaOffset:	.int	0,	6,	12,	20,	26,	31,	39,	44,	50,	56,	64, 69,	74,	79,	88,	94,	99,	106,	112,	119, 125, 133, 140,	148, 153, 160
NewLine:	.asciz "\n"
Space:		.asciz " "

Counter:	.int	0
Prompt:	  .asciz "Please enter a sentence with a character limit of 256.\n"
KeyPress: .ascii "  "

.section .bss
	.comm	MsgBuf, 1
.section .text
.globl   _start

####################
# How should I work?
#	Decimal value for a is 65, Decimal value for A is 93. There is a 32 digit difference
#	If the offset value is greater than 27, It is uppercase, set a flag and shift the numbers down 32 digits
#	Offsetting the character by 65 means anything from 0-27 is a digit I want
#	Take the number and offset the Alphabet array to find the appropriate value


_start:
	##	Display Prompt To User	##
	movl	$Prompt, %eax
	call	strlen
	movl	%eax,	%ebx		# Place the length of the prompt into B
	movl	$Prompt,	%eax	# Place the string into A
	call 	PrintBuf

	##	Read Prompt From User	##
	call	Read
	call Process


	##	Print Buffer Entered By User	##
	# movl	$MsgBuf, %eax
	# call	strlen
	# movl	%eax,	%ebx
	# movl	$MsgBuf,	%eax
	# call	PrintBuf


	#call PrintTest

	call ExitProg

# I am here to make sure that the damn offsets are correct
PrintTest:
	movl $0, %ecx
	jmp PT_L1
	# movl $1, %ecx
	# movl $AlphaOffset, %esi
	# imull $4, %ecx
	# addl %ecx, %esi

	# movl %esi, %eax
	# movl $Alphabet, %edx
	# addl (%esi), %edx
	# movl %edx, %eax

	# call strlen
	# movl %eax, %ebx
	# movl %edx, %eax
	# call PrintBuf

PT_L1:
	movl %ecx, %ebx
	movl $AlphaOffset, %esi
	imull $4, %ebx
	addl %ebx, %esi

	movl %esi, %eax
	movl $Alphabet, %edx
	addl (%esi), %edx
	movl %edx, %eax

	call strlen
	movl %eax, %ebx
	movl %edx, %eax
	call PrintBuf
	call PrintNL
	jmp PT_CMP
PT_CMP:
	cmp $25, %ecx
	jae PT_DONE
	inc %ecx
	jmp PT_L1

PT_DONE:
	ret

Read:
	movl	$0,	%ebx
	movl	$3, %eax
	movl	$MsgBuf,	%ecx
	movl	$256,	%edx
	int 	$0x80
	ret

###
#	Process is used to loop through the entered text and print the character
Process:

	# Get the length of the string
	movl $MsgBuf, %eax
	call strlen

	movl %eax, %edx	# Make D contain the number of times to loop through

	movl $0, %ecx	# Set the initial value of the counter to 0

	# Start Loop
	jmp PROCESS_L1


PROCESS_L1:
	movl $0, %eax
	movl $MsgBuf, %esi
	addl %ecx,	%esi		# Increment to next character

	movb (%esi), %al

	cmpb $32, %al			# Check to see if character is a space or not, space in decimal is 32
	je PROCESS_PRINT_NL		# If it is equal, print a new line because its now a new word


	# movl %esi, %eax			# Prepare to print the letter
	# movl $1, %ebx
	# call PrintBuf

	call PROCESS_PRINT_ALPHABET
	inc %ecx				# Increment the counter
	jmp PROCESS_CMP			# Check to see if were done

PROCESS_PRINT_NL:
	call PrintNL
	inc %ecx
	jmp PROCESS_CMP

PROCESS_CMP:
	cmp %ecx, %edx
	ja	PROCESS_L1
	ret

# A process that prints the alphabet
PROCESS_PRINT_ALPHABET:
	# Check to see if the letter is even a letter at all, if not, return
	pushl %edx
	pushf

	subb $65, %al	# Offset the character by 65

	cmpb $0, %al
	jb	PROCESS_BAD_INPUT

	cmpb $57, %al
	ja	PROCESS_BAD_INPUT

	cmpb $25, %al
	ja	PROCESS_PRINT_UPPERCASE

	# Prepare to print the alphabet code
	call PROCESS_PRINT

	popf
	popl %edx
	ret

PROCESS_BAD_INPUT:
	popf
	ret	# Bad input, move onto next letter

PROCESS_PRINT_UPPERCASE:
	subb $32, %al

	cmpb $0, %al
	jb	PROCESS_BAD_INPUT

	cmpb $25, %al
	ja	PROCESS_BAD_INPUT

	# Prepare to print the alphabet code
	call PROCESS_PRINT

	popf
	ret

PROCESS_PRINT:
	pushl %esi
	pushl %edi

	movl %eax, %edi
	movl AlphaOffset(, %edi, 4), %esi

	movl $Alphabet, %edi
	addl %esi, %edi

	pushl %eax

	movl %edi, %eax
	call strlen
	movl %eax, %ebx


	movl %edi, %eax
	call PrintBuf

	call PrintSpace

	popf
	popl %esi
	popl %edi
	popl %eax
	inc %ecx
	jmp PROCESS_CMP

; # Checks the %al and treats it as if it was a lower-case letter
; PROCESS_CHECK_LOWER_CASE:
; 	pushl %ecx	# C is being used as a condition variable
; 	pushf
;
; 	subb $65, %al
; 	call PROCESS_CHECK_BETWEEN_RANGE
;
; 	popf
; 	popl %ecx
;
; # Checks the %al and treats it as if it was an upper-case letter
; PROCESS_CHECK_UPPER_CASE:
; 	subb $32, %al
;
;
; # ** Function assumes that the al value is offset to 0 being a and z being 25
; # %ecx becomes 0 for false and 1 for true
; PROCESS_CHECK_BETWEEN_RANGE:
; 	pushf
;
; 	cmpb $0, %al
; 	jb PROCESS_RANGE_IS_BAD
; 	cmpb $25, %al
; 	jg PROCESS_RANGE_IS_BAD
;
; 	movl $1, %ecx	# Range is okay, returning true
;
; 	popf
; 	ret

PROCESS_RANGE_IS_BAD:
	movl $0, %ecx	# Range was not acceptable, returning false
	popf
	ret

ExitProg:
	call	PrintNL			# Spit out an extra NL before leaving
	movl	$1,%eax
	movl	$0,%ebx
	int	$0x80



#**************************************************************
# A simple procedure with no parameters or a return value
#
#  void PrintNL() - Print a NL character to the screen
#
#**************************************************************

PrintNL:
	pushl	%eax		# Save the registers
	pushl	%ebx		# so the caller doesnt
	pushl	%ecx		# need to worry about
	pushl	%edx		# data loss in the regsters
	pushf			# Save the falgs as well

	movl	$4, %eax	# Print a new Line Character
	movl	$1, %ebx
	movl	$NewLine, %ecx
	movl	$1, %edx
	int	$0x80

	popf
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax		# Restore all of the registers used

	ret			# Go back to the calling instruction

#**************************************************************

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

#**************************************************************
#	A simple procedure that has two parameters
#
#	void PrintBuf(string Buffer, long Length)
#		%eax = Buffer Address
#		%ebx = Length of Buffer to print
#**************************************************************

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

#**************************************************************

#**************************************************************
#   Get the length of a buffer terminated by NUL
#	int strlen(string buffer)
#	  %eax = buffer address
#	  return %eax = Length of the string
#
#**************************************************************
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

#**************************************************************
