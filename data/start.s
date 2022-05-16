.section .text
.extern main
.global _start

.equ STACK_SIZE,1024*1024

_start:
	li sp,STACK_SIZE
	jal main
aa:
	j aa
