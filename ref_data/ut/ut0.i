	loadI 1 => r0		// source-level assignment
	loadI 2 => r1		// source-level assignment
	add r0, r1 => r4	// 
	i2i r4 => r2		// source-level assignment
	mult r0, r2 => r5	// 
	i2i r5 => r3		// source-level assignment
	subI r0, 1 => r6	// 
	i2i r6 => r0		// source-level assignment
	div r1, r2 => r7	// 
	i2i r7 => r1		// source-level assignment