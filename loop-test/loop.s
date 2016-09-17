.section .data
Ar: .int 0, 1, 2, 3

.section .text
.globl _start

_start:
	movl Ar(0,$2, 3), %eax
	
	call EndProg

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
