	loadI 1 => r0		// source-level assignment
	loadI 10 => r1		// source-level assignment
	cmp_LT r0, r1 => r2	// 
	cbr r2 -> L0, L1	// 
L0:	nop			// top of while loop
	write r0	
	addI r0, 1 => r3	// 
	i2i r3 => r0		// source-level assignment
	cmp_LT r0, r1 => r2	// 
	cbr r2 -> L0, L1	// 
L1:	nop			// bottom of while loop
