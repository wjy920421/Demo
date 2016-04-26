	loadI 1 => r0		// source-level assignment
	loadI 1 => r1		// index variable initialization
	loadI 10 => r2		// upper bound
	cmp_LE r1, r2 => r3	// index < UB
	cbr r3 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	addI r0, 1 => r4	// 
	i2i r4 => r0		// source-level assignment
	addI r1, 1 => r1	// update index
	cmp_LE r1, r2 => r5	// index < UB
	cbr r5 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
	write r0	
