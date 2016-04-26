	loadI 1 => r0		// source-level assignment
	loadI 2 => r1		// source-level assignment
	loadI 3 => r2		// source-level assignment
	cmp_EQ r0, r0 => r3	// 
	cbr r3 -> L0, L1	// if-then or if-then-else
L0:	nop			// then part
	write r0	
L1:	nop			// exit label for if-then
	cmp_EQ r0, r1 => r4	// 
	cbr r4 -> L3, L4	// if-then or if-then-else
L3:	nop			// then part
	write r1	
	br -> L5		// branch to exit label
L4:	nop			// else part
	write r0	
	br -> L5		// no fall-through in iloc
L5:	nop			// exit label for if-then-else
	add r0, r0 => r5	// 
	cmp_EQ r5, r1 => r6	// 
	cbr r6 -> L6, L7	// if-then or if-then-else
L6:	nop			// then part
	write r0	
	br -> L8		// branch to exit label
L7:	nop			// else part
	write r1	
	br -> L8		// no fall-through in iloc
L8:	nop			// exit label for if-then-else
	cmp_LT r0, r1 => r7	// 
	cbr r7 -> L9, L10	// if-then or if-then-else
L9:	nop			// then part
	loadI 0 => r8		// int load of integer literal
	cmp_EQ r0, r8 => r9	// 
	cbr r9 -> L12, L13	// if-then or if-then-else
L12:	nop			// then part
	write r0	
	br -> L14		// branch to exit label
L13:	nop			// else part
	write r1	
	br -> L14		// no fall-through in iloc
L14:	nop			// exit label for if-then-else
	br -> L11		// branch to exit label
L10:	nop			// else part
	write r2	
	br -> L11		// no fall-through in iloc
L11:	nop			// exit label for if-then-else
	cmp_LT r1, r0 => r10	// 
	cbr r10 -> L15, L16	// if-then or if-then-else
L15:	nop			// then part
	loadI 0 => r11		// int load of integer literal
	cmp_EQ r0, r11 => r12	// 
	cbr r12 -> L18, L19	// if-then or if-then-else
L18:	nop			// then part
	write r0	
	br -> L20		// branch to exit label
L19:	nop			// else part
	write r1	
	br -> L20		// no fall-through in iloc
L20:	nop			// exit label for if-then-else
	br -> L17		// branch to exit label
L16:	nop			// else part
	write r2	
	br -> L17		// no fall-through in iloc
L17:	nop			// exit label for if-then-else
