.section .data

.section .text
.globl _start

_start:
	call EndProg	

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
