	loadI 0 => r0		// source-level assignment
	loadI 0 => r1		// index variable initialization
	loadI 9 => r2		// upper bound
	cmp_LE r1, r2 => r3	// index < UB
	cbr r3 -> L0, L1	// branch around loop
L0:	nop			// loop header label
	loadI 0 => r4		// start accum at 0
	subI r1, 0 => r5
	add r4, r5 => r4
	multI r4, 4 => r4	//  x sizeof(int)
	loadI 4 => r6		// base address of array b
	add r6, r4 => r6	// base + offset
	multI r1, 2 => r7	// 
	store r7 => r6		// int array store
	addI r1, 1 => r1	// update index
	cmp_LE r1, r2 => r8	// index < UB
	cbr r8 -> L0, L1	// branch back to loop header
L1:	nop			// loop exit label
	loadI 0 => r1		// index variable initialization
	loadI 9 => r9		// upper bound
	cmp_LE r1, r9 => r10	// index < UB
	cbr r10 -> L2, L3	// branch around loop
L2:	nop			// loop header label
	loadI 0 => r11		// start accum at 0
	subI r1, 0 => r12
	add r11, r12 => r11
	multI r11, 4 => r11	//  x sizeof(int)
	loadI 4 => r13		// base address of array b
	add r13, r11 => r13	// base + offset
	load r13 => r14		// LValue -> RValue
	add r0, r14 => r15	// 
	i2i r15 => r0		// source-level assignment
	addI r1, 1 => r1	// update index
	cmp_LE r1, r9 => r16	// index < UB
	cbr r16 -> L2, L3	// branch back to loop header
L3:	nop			// loop exit label
	write r0	
