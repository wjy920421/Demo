	loadI 1 => r0		// source-level assignment
	addI r0, 2 => r1	// 
	loadI 0 => r2		// start accum at 0
	subI r1, 1 => r3
	multI r3, 20 => r3
	add r2, r3 => r2
	loadI 1 => r3		// result of fold
	add r2, r3 => r2
	multI r2, 4 => r2	//  x sizeof(int)
	loadI 4 => r4		// base address of array b
	add r4, r2 => r4	// base + offset
	addI r0, 1 => r5	// 
	store r5 => r4		// int array store
