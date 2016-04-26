	loadI 10 => r1		// source-level assignment
	loadI 1 => r0		// index variable initialization
	loadI 10 => r2		// upper bound
	cmp_LE r0, r2 => r3	// index < UB
	cbr r3 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	write r0	
	addI r0, 1 => r0	// update index
	cmp_LE r0, r2 => r4	// index < UB
	cbr r4 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
