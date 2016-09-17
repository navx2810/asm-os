.section .data

.section .text
.globl _start

_start:
	movl $2, %eax
	movl $1, %ebx
	cmp %eax, %ebx
	call EndProg	

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
