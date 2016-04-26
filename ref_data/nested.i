	loadI 0 => r4		// source-level assignment
	loadI 2 => r3		// source-level assignment
	loadI 1 => r0		// index variable initialization
	loadI 100 => r5		// upper bound
	cmp_LE r0, r5 => r6	// index < UB
	cbr r6 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	loadI 1 => r1		// index variable initialization
	loadI 100 => r7		// upper bound
	cmp_LE r1, r7 => r8	// index < UB
	cbr r8 -> L2, L3	// branch around loop
L2:	nop			// loop header label
	loadI 1 => r2		// index variable initialization
	loadI 13 => r9		// upper bound
	cmp_LE r2, r9 => r10	// index < UB
	cbr r10 -> L4, L5	// branch around loop
L4:	nop			// loop header label
	loadI 2 => r11		// int load of integer literal
	cmp_EQ r3, r11 => r12	// 
	cbr r12 -> L6, L7	// if-then or if-then-else
L6:	nop			// then part
	addI r4, 1 => r13	// 
	i2i r13 => r4		// source-level assignment
L7:	nop			// exit label for if-then
	loadI 2 => r14		// int load of integer literal
	cmp_EQ r3, r14 => r15	// 
	cbr r15 -> L9, L10	// if-then or if-then-else
L9:	nop			// then part
	loadI 0 => r3		// source-level assignment
L10:	nop			// exit label for if-then
	addI r3, 1 => r16	// 
	i2i r16 => r3		// source-level assignment
	addI r2, 1 => r2	// update index
	cmp_LE r2, r9 => r17	// index < UB
	cbr r17 -> L4, L5	// branch back to loop header
L5:	nop			// loop exit label
	addI r1, 1 => r1	// update index
	cmp_LE r1, r7 => r18	// index < UB
	cbr r18 -> L2, L3	// branch back to loop header
L3:	nop			// loop exit label
	addI r0, 1 => r0	// update index
	cmp_LE r0, r5 => r19	// index < UB
	cbr r19 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
	write r4	
