	loadI 1 => r0		// source-level assignment
	loadI 0 => r1		// start accum at 0
	loadI 3 => r2		// result of fold
	add r1, r2 => r1
	multI r1, 4 => r1	//  x sizeof(int)
	loadI 4 => r3		// base address of array a
	add r3, r1 => r3	// base + offset
	store r0 => r3		// int array store
	loadI 0 => r4		// start accum at 0
	loadI 3 => r5		// result of fold
	add r4, r5 => r4
	multI r4, 4 => r4	//  x sizeof(int)
	loadI 4 => r6		// base address of array a
	add r6, r4 => r6	// base + offset
	load r6 => r7		// LValue -> RValue
	write r7	
