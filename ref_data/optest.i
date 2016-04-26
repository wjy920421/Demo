	loadI 2 => r0		// source-level assignment
	loadI 1 => r1		// source-level assignment
	add r0, r1 => r3	// 
	i2i r3 => r2		// source-level assignment
	write r2	
	sub r0, r1 => r4	// 
	i2i r4 => r2		// source-level assignment
	write r2	
	mult r0, r1 => r5	// 
	i2i r5 => r2		// source-level assignment
	write r2	
	div r0, r1 => r6	// 
	i2i r6 => r2		// source-level assignment
	write r2	
	div r1, r0 => r7	// 
	i2i r7 => r2		// source-level assignment
	write r2	
