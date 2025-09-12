#define BUILD_INFO __DATE__ " " __TIME__
#define STARTUP_MSG "Startup complete! Built on " BUILD_INFO "\n"

    .data
    .globl startup_message
startup_message:
    .asciz STARTUP_MSG
	.section	.note.GNU-stack,"",@progbits
