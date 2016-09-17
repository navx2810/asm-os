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
	ret

P_LOOP:
	pushl	%ebx
	movl	%eax, %ebx
	imull	%ecx, %ebx
	movl	%ebx, %eax
	popl	%ebx
	jmp 	P_CONT
	
P_CONT:
	inc	%ecx
	cmp	$5, %ecx
	jae	P_END
	jmp	P_LOOP
	

P_END:
	popf
	popl	%eax
	popl	%ebx
	popl	%ecx
	popl	%edx
	ret

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
