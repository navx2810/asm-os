.section .data

	TestData:	.asciz "9.99\n"

	Prompt:	.asciz "Please enter a decimal number in the form of: 999.99\n"

	Hundreds: .ascii "\0             ", "One-Hundred\0  ", "Two-Hundred\0  ", "Three-Hundred\0", "Four-Hundred\0 ", "Five-Hundred\0 ", "Six-Hundred\0  ", "Seven-Hundred\0", "Eight-Hundred\0", "Nine-Hundred\0 "
	HundredsOffset: .int 14

	Tens: .ascii "\0       ", "Twenty\0 ", "Thirty\0 ", "Fourty\0 ", "Fifty\0  ", "Sixty\0  ", "Seventy\0", "Eighty\0 ", "Ninty\0  "
	TensOffset: .int 8

	SpecialTens: .ascii "Ten\0      ", "Eleven\0   ", "Twelve\0   ", "Thirteen\0 ", "Fourteen\0 ", "Fifteen\0  ", "Sixteen\0  ", "Seventeen\0", "Eighteen\0 ", "Nineteen\0 "
	SpecialTensOffset: .int 10

	Ones: .ascii "\0     ", "One\0  ", "Two\0  ", "Three\0", "Four\0 ", "Five\0 ", "Six\0  ", "Seven\0", "Eight\0", "Nine\0 "
	OnesOffset: .int 6

	NewLine:	.asciz "\n"
	Space:		.asciz " "

	IsDecimal:			.int	0
	ShouldUseHyphen:	.int	0

	WholeNumberCount:	.int 	0
	DecimalNumberCount:	.int 	0

	BuffLen:			.int	0

.section .bss

	.comm	MsgBuf, 1

.section .text
.globl _start

_start:
	movl	$Prompt,	%eax
	call	Print

	#>>>> Read The Input
	#movl	$0,	%ebx
	#movl	$3, %eax
	#movl	$MsgBuf,	%ecx
	#movl	$7,	%edx			# Read till 7 characters, this includes an enter press at 999.99\n
	#int 	$0x80
	#movl	%eax, BuffLen

	#movl	%ecx, %eax

	# --- Test Data --- #
	#movl	$TestData, %eax
	#movl	$5, BuffLen
	call	ReadInput
	call	FindCount
	call	EndProg


#=======================
#	Input Functions
#=======================

ReadInput:
	movl	$0,	%ebx
	movl	$3, %eax
	movl	$MsgBuf,	%ecx
	movl	$7,	%edx			# Read till 7 characters, this includes an enter press at 999.99\n
	int 	$0x80
	movl	%eax, BuffLen

	movl	%ecx, %eax

# { Find the count of the string placed in EAX }
FindCount:
	pushl	%ecx
	pushl	%ebx
	pushl	%edx

	movl	%eax, %esi
	movl	$0, %ecx

	jmp		FC_LP

FC_LP:
	#xorl	%eax, %eax		# Clear
	#movl	$1, %eax		# Offset the pointer by 4 (bytes)
	#mull	%ecx			# Multiply ECX by 4 into EAX
	movl	%esi, %ebx		# Place pointer into EDI
	addl	%ecx, %ebx
	movb	(%ebx), %dl

	jmp		FC_CMP

FC_CMP:
	cmpb	$'.', %dl
	jl		FC_CONT_LAST
	cmpb	$'9', %dl
	jg		FC_CONT_LAST

	cmpb	$'.', %dl
	jne		FC_CONT

	movl	$1, IsDecimal
	jmp		FC_CONT_LAST


FC_CONT:
	cmpb	$10, %dl
	je		FC_END
	cmpb	$'Q', %dl
	je		FC_END

	cmpl	$0, IsDecimal
	je		FC_INC_WHOLE

	jmp		FC_INC_DECIMAL

FC_INC_WHOLE:
	addl	$1,	WholeNumberCount
	jmp		FC_CONT_LAST

FC_INC_DECIMAL:
	addl	$1,	DecimalNumberCount
	jmp		FC_CONT_LAST

FC_CONT_LAST:
	inc 	%ecx
	cmpl	BuffLen, %ecx
	jge		FC_END
	jmp		FC_LP

FC_END:
	popl	%ecx
	popl	%ebx
	popl	%edx

	movl	$0, IsDecimal
	ret


######################################################
#
#	Additional Functions
#
######################################################

#---------------------------------------------
#	Gets the address offset of the given array
#	EAX =>	Index Offset		# 3
#	EBX =>	ArrayOffsetValue	# HundredsOffset
#	ESI =>	Array				# Hundreds
#
#	Eax <=	Pointer to value
#---------------------------------------------
GetOffset:

	mull	%ebx
	addl	%esi,	%eax

	xorl	%esi,	%esi	# Clear ESI
	xorl	%ebx,	%ebx	# Clear EBX

	ret

Test:
	movl	$3,	%eax
	movl	HundredsOffset, %ebx
	movl	$Hundreds, %esi
	call	GetOffset

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
