	loadI 1 => r0		// source-level assignment
	loadI 2 => r1		// source-level assignment
	loadI 1 => r2		// index variable initialization
	loadI 10 => r4		// upper bound
	cmp_LE r2, r4 => r5	// index < UB
	cbr r5 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	addI r0, 1 => r6	// 
	i2i r6 => r0		// source-level assignment
	addI r1, 1 => r3	// 
	add r2, r3 => r2	// update_index
	cmp_LE r2, r4 => r7	// index < UB
	cbr r7 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
	write r0	
