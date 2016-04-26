	loadI 1 => r0		// source-level assignment
	loadI 2 => r1		// source-level assignment
	loadI 3 => r2		// source-level assignment
	loadI 1 => r3		// source-level assignment
	loadI 0 => r4		// source-level assignment
	cmp_LE r0, r1 => r5	// 
	cbr r5 -> L0, L1	// if-then or if-then-else
L0:	nop			// then part
	write r3	
	br -> L2		// branch to exit label
L1:	nop			// else part
	write r4	
	br -> L2		// no fall-through in iloc
L2:	nop			// exit label for if-then-else
