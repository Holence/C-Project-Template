	.text
	.globl	asm_s_func
asm_s_func:
	movl	$42, %eax
	ret
	.section	.note.GNU-stack,"",@progbits
