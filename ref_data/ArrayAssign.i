	loadI 0 => r0		// index variable initialization
	loadI 9 => r1		// upper bound
	cmp_LE r0, r1 => r2	// index < UB
	cbr r2 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	loadI 0 => r3		// start accum at 0
	subI r0, 0 => r4
	add r3, r4 => r3
	multI r3, 4 => r3	//  x sizeof(int)
	loadI 4 => r5		// base address of array A
	add r5, r3 => r5	// base + offset
	store r0 => r5		// int array store
	addI r0, 1 => r0	// update index
	cmp_LE r0, r1 => r6	// index < UB
	cbr r6 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
	loadI 0 => r0		// index variable initialization
	loadI 9 => r7		// upper bound
	cmp_LE r0, r7 => r8	// index < UB
	cbr r8 -> L2, L3	// branch around loop
L2:	nop			// loop header label
	loadI 0 => r9		// start accum at 0
	subI r0, 0 => r10
	add r9, r10 => r9
	multI r9, 4 => r9	//  x sizeof(int)
	loadI 4 => r11		// base address of array A
	add r11, r9 => r11	// base + offset
	load r11 => r12		// LValue -> RValue
	write r12	
	addI r0, 1 => r0	// update index
	cmp_LE r0, r7 => r13	// index < UB
	cbr r13 -> L2, L3	// branch back to loop header
L3:	nop			// loop exit label
