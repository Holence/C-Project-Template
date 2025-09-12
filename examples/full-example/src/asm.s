	.text
	.globl	call_me_from_c
call_me_from_c:
	movl	$42, %eax
	ret
	.section	.note.GNU-stack,"",@progbits
