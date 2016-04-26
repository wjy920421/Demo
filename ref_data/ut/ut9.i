	loadI 1 => r0		// source-level assignment
	loadI 2 => r1		// source-level assignment
	loadI 3 => r2		// source-level assignment
	loadI 1 => r3		// source-level assignment
	loadI 0 => r4		// source-level assignment
	cmp_LT r1, r2 => r5	// 
	cbr r5 -> L0, L1	// if-then or if-then-else
L0:	nop			// then part
	loadI 0 => r6		// int load of integer literal
	cmp_EQ r0, r6 => r7	// 
	cbr r7 -> L3, L4	// if-then or if-then-else
L3:	nop			// then part
	write r3	
	br -> L5		// branch to exit label
L4:	nop			// else part
	write r4	
	br -> L5		// no fall-through in iloc
L5:	nop			// exit label for if-then-else
L1:	nop			// exit label for if-then
