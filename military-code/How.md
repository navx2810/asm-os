# How do I do this?

## Notes
65 is the decimal number for the letter a
97 is the decimal number for the capital A
there's a 32 digit difference between them
there's 27 letters in the alphabet

If the character's decimal code with an offset of -65 falls within 0-27 or 32-59, It is the character I want


Print:
	Offset by -65
	cmp 0, %al
	jl Print_BAD_INPUT

	cmp $57, %al
	jg Print_BAD_INPUT

	cmp $25, %al
	jg Print_UPPER_CASE_LETTER

	It's a correct lower-case letter

Print_BAD_INPUT:
	jmp TO_NEXT_LETTER

Print_UPPER_CASE_LETTER:
	Offset by -32
	cmp $0, %al
	jl Print_BAD_INPUT

	cmp $25, %al
	jg Print_BAD_INPUT

	It's a correct upper-case letter
