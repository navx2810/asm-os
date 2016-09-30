# Program:	Print a stringifed representation of a check value
# Author:	Matt Fetterman
# Date:		09/30/2016

.section .data

	Prompt:	.asciz "Please enter a decimal number in the form of: 999.99\n"
	InvalidDecimal:	.asciz "You entered an invalid decimal, please enter it in the form of 999.99\n"

	Hundreds: .ascii "\0             ", "One-Hundred\0  ", "Two-Hundred\0  ", "Three-Hundred\0", "Four-Hundred\0 ", "Five-Hundred\0 ", "Six-Hundred\0  ", "Seven-Hundred\0", "Eight-Hundred\0", "Nine-Hundred\0 "
	HundredsOffset: .int 14

	Tens: .ascii "\0       ", "\0       ", "Twenty\0 ", "Thirty\0 ", "Fourty\0 ", "Fifty\0  ", "Sixty\0  ", "Seventy\0", "Eighty\0 ", "Ninty\0  "
	TensOffset: .int 8

	SpecialTens: .ascii "Ten\0      ", "Eleven\0   ", "Twelve\0   ", "Thirteen\0 ", "Fourteen\0 ", "Fifteen\0  ", "Sixteen\0  ", "Seventeen\0", "Eighteen\0 ", "Nineteen\0 "
	SpecialTensOffset: .int 10

	Ones: .ascii "\0     ", "One\0  ", "Two\0  ", "Three\0", "Four\0 ", "Five\0 ", "Six\0  ", "Seven\0", "Eight\0", "Nine\0 "
	OnesOffset: .int 6

	NewLine:	.asciz "\n"
	Space:		.asciz " "
	Hyphen:		.asciz "-"
	And:		.asciz " Dollars and "
	Cents:		.asciz "Cents"

	IsDecimal:						.int	0
	ShouldUseHyphen:				.int	0
	ShouldUseSpecialTens:			.int	0

	WholeNumberCount:				.int 	0
	DecimalNumberCount:				.int 	0

	NumberValue:					.int	0

	BuffLen:						.int	0

.section .bss

	.comm	MsgBuf, 1

.section .text
.globl _start

_start:
	movl	$Prompt,	%eax
	call	Print

Main:
	movl	$0, WholeNumberCount		# Initialize the Whole Number Count
	movl	$0, DecimalNumberCount		# Initialize the Decimal Number Count

	call	ReadInput
	call	FindCount

	cmpl	$1, DecimalNumberCount
	jne		PrintCount
DisplayError:
	movl	$InvalidDecimal, %eax
	call	Print
	jmp		Main

PrintCount:
	xorl	%edx, %edx
	movl	$0, %ecx		# Initialize the counter
	jmp		P_L				# Begin Loop

#----------------------
#	Printing Processes
#----------------------
P_L:
	movl	%esi, %ebx		# Place the pointer to MsgBuf into EBX
	addl	%ecx, %ebx		# Advance Pointer in MsgBuf(EBX)
	movb	(%ebx), %dl		# Place Char into DL

	cmpl	$10, %edx		# If the Char is a Line Feed
	jne		P_L_B
	subl	$1, DecimalNumberCount

P_L_B:
	cmpl	$1, IsDecimal	# Should I treat this as a decimal number?
	je		P_L_Decimal
	jmp		P_L_Whole

P_L_Whole:
	cmpl	$3, WholeNumberCount	# Check if the number is in the Hundreds
	je		P_G3A
	cmpl	$2, WholeNumberCount	# Check if the number is in the Tens
	je		P_G2A
	cmpl	$1, WholeNumberCount	# Check if the number is in the Ones
	je		P_G1A

	movl	$And, %eax				# If you reached 0 then you should start using decimals
	call	Print
	movl	$1, IsDecimal
	movl	$0, ShouldUseHyphen			# Clear any flags
	movl	$0, ShouldUseSpecialTens	# That might have been set
	jmp		P_CONT_FINAL

P_L_Decimal:
	cmpl	$3, DecimalNumberCount	# Check if the number is in the Hundreds
	je		P_G3A
	cmpl	$2, DecimalNumberCount	# Check if the number is in the Tens
	je		P_G2A
	cmpl	$1, DecimalNumberCount	# Check if the number is in the Ones
	je		P_G1A

	call	PrintSpace
	movl	$Cents, %eax
	call	Print
	jmp		P_CONT_FINAL					# If you reached 0 in the decimal place, youre done writing


P_G3A:
	cmpb	$0, %dl
	je		P_CONT

	movl	%edx, %eax						# Prepare for the offset function
	subl	$48, %eax						# Offset the ASCII value with the actual value
	movl	HundredsOffset, %ebx
	movl	$Hundreds, %edi
	call	GetOffset

	call	Print
	call	PrintSpace

	jmp		P_CONT

P_G2A:
	cmpb	$48, %dl					# If the value in place is 0, skip it
	je		P_CONT
	cmpb	$49, %dl					# If the value in place is 1, youre going to use special values like fourteen
	je		P_G2_Use_Special
	movl	$1, ShouldUseHyphen			# If nothing went through, it is a regular tweny-ninety number, so youll use a hyphen

	movl	%edx, %eax					# Prepare for the offset function
	subl	$48, %eax					# Offset the ASCII value with the actual value
	movl	TensOffset, %ebx
	movl	$Tens, %edi
	call	GetOffset
	call	Print

	jmp		P_CONT

P_G2_Use_Special:
	movl	$1,	ShouldUseSpecialTens
	jmp		P_CONT


P_G1A:
	cmpl	$1, ShouldUseHyphen			# Was the tens place between 2-9?
	je		P_G1_Hyphen
	cmpl	$1, ShouldUseSpecialTens	# Was the tens place 1?
	je		P_G1_Tens
	jmp		P_G1_Print

P_G1_Tens:
	movl	%edx, %eax					# Prepare for the offset function
	subl	$48, %eax					# Offset the ASCII value with the actual value
	movl	SpecialTensOffset, %ebx
	movl	$SpecialTens, %edi
	call	GetOffset
	call	Print
	jmp		P_CONT

P_G1_Hyphen:
	movl	$Hyphen, %eax				# Print a hyphen
	call	Print
	jmp		P_G1_Print

P_G1_Print:
	movl	%edx, %eax				# Prepare for the offset function
	subl	$48, %eax				# Offset the ASCII value with the actual value
	movl	OnesOffset, %ebx
	movl	$Ones, %edi
	call	GetOffset
	call	Print
	jmp		P_CONT

P_CONT:
	cmpl	$1,	IsDecimal				# Should I decrement the counter from whole numbers or decimal?
	je		P_CONT_Decrement_Decimal
	jmp		P_CONT_Decrement_Whole
P_CONT_Decrement_Decimal:
	subl	$1,	DecimalNumberCount
	jmp		P_CONT_FINAL
P_CONT_Decrement_Whole:
	subl	$1, WholeNumberCount
	jmp		P_CONT_FINAL
P_CONT_FINAL:
	inc 	%ecx
	cmpl 	%ecx, BuffLen				# Have I run out of characters to process?
	jle		EndProg
	jmp		P_L




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

	ret

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
	#jmp		PrintCount


######################################################
#
#	Additional Functions
#
######################################################

#---------------------------------------------
#	Gets the address offset of the given array
#	EAX =>	Index Offset		# 3
#	EBX =>	ArrayOffsetValue	# HundredsOffset
#	EDI =>	Array				# Hundreds
#
#	Eax <=	Pointer to value
#---------------------------------------------
GetOffset:
	mull	%ebx
	addl	%edi,	%eax

	xorl	%edi,	%edi	# Clear EDI
	xorl	%ebx,	%ebx	# Clear EBX
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
	call	PrintNL
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
