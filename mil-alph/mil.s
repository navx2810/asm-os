.section .data

.section .text
.globl _start

_start:
	call Process
	call EndProg	

Process:
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushf	

	popl	%eax
	popl	%ebx
	popl	%ecx
	popl	%edx
	popf
	
	ret

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
