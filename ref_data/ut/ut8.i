	loadI 1 => r0		// source-level assignment
	loadI 2 => r1		// source-level assignment
	loadI 3 => r2		// source-level assignment
	loadI 1 => r3		// source-level assignment
	loadI 0 => r4		// source-level assignment
	cmp_LT r0, r1 => r5	// 
	cbr r5 -> L0, L1	// if-then or if-then-else
L0:	nop			// then part
	write r3	
	br -> L2		// branch to exit label
L1:	nop			// else part
	write r4	
	br -> L2		// no fall-through in iloc
L2:	nop			// exit label for if-then-else
	cmp_GT r1, r2 => r6	// 
	cbr r6 -> L3, L4	// if-then or if-then-else
L3:	nop			// then part
	write r3	
L4:	nop			// exit label for if-then
	cmp_LE r1, r2 => r7	// 
	cbr r7 -> L6, L7	// if-then or if-then-else
L6:	nop			// then part
	write r4	
L7:	nop			// exit label for if-then
	cmp_LT r1, r2 => r8	// 
	cbr r8 -> L9, L10	// if-then or if-then-else
L9:	nop			// then part
	loadI 0 => r9		// int load of integer literal
	cmp_EQ r0, r9 => r10	// 
	cbr r10 -> L12, L13	// if-then or if-then-else
L12:	nop			// then part
	write r3	
	br -> L14		// branch to exit label
L13:	nop			// else part
	write r4	
	br -> L14		// no fall-through in iloc
L14:	nop			// exit label for if-then-else
L10:	nop			// exit label for if-then
