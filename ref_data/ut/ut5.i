	loadI 1 => r0		// source-level assignment
	loadI 2 => r1		// source-level assignment
	i2i r0 => r2		// index variable initialization
	multI r0, 10 => r3	// 
	cmp_LE r2, r3 => r4	// index < UB
	cbr r4 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	addI r0, 1 => r5	// 
	i2i r5 => r0		// source-level assignment
	multI r1, 2 => r6	// 
	add r6, r0 => r7	// 
	i2i r7 => r1		// source-level assignment
	addI r2, 1 => r2	// update index
	cmp_LE r2, r3 => r8	// index < UB
	cbr r8 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
	write r0	
	write r1	
