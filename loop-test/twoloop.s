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

	# Start the counter
	movl	$1, %ecx
	movl	$2, %eax
	call	P_LOOP

	popl	%eax
	popl	%ebx
	popl	%ecx
	popl	%edx
	popf
	ret

P_LOOP:
	inc		%ecx
	jmp		P_NEXT
P_NEXT:
	cmp		$5, %ecx
	jne		P_LOOP
	ret
	
	

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
