#define BUILD_INFO __DATE__ " " __TIME__
#define STARTUP_MSG "Greetings sire! Built on " BUILD_INFO

    .data
    .globl startup_message
startup_message:
    .asciz STARTUP_MSG
	.section	.note.GNU-stack,"",@progbits

	.text
	.globl	asm_S_func
asm_S_func:
	leaq	startup_message(%rip), %rax
	ret
	.section	.note.GNU-stack,"",@progbits
