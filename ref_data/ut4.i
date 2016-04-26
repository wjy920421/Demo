	loadI 2 => r0		// source-level assignment
	loadI 4 => r1		// source-level assignment
	add r0, r1 => r4	// 
	i2i r4 => r2		// source-level assignment
	mult r0, r1 => r5	// 
	i2i r5 => r3		// source-level assignment
	write r2	
	write r3	
