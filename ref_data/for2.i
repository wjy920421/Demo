	loadI 10 => r2		// source-level assignment
	loadI 1 => r0		// index variable initialization
	cmp_LE r0, r2 => r3	// index < UB
	cbr r3 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	write r0	
	loadI 1 => r1		// index variable initialization
	cmp_LE r1, r2 => r4	// index < UB
	cbr r4 -> L2, L3	// branch around loop
L2:	nop			// loop header label
	write r1	
	addI r1, 1 => r1	// update index
	cmp_LE r1, r2 => r5	// index < UB
	cbr r5 -> L2, L3	// branch back to loop header
L3:	nop			// loop exit label
	addI r0, 1 => r0	// update index
	cmp_LE r0, r2 => r6	// index < UB
	cbr r6 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
