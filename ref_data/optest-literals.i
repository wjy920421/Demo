	loadI 2 => r0		// source-level assignment
	loadI 1 => r1		// source-level assignment
	addI r0, 1 => r3	// 
	i2i r3 => r2		// source-level assignment
	write r2	
	addI r0, 1 => r4	// 
	i2i r4 => r2		// source-level assignment
	write r2	
	subI r0, 1 => r5	// 
	i2i r5 => r2		// source-level assignment
	write r2	
	multI r0, 1 => r6	// 
	i2i r6 => r2		// source-level assignment
	write r2	
	multI r0, 1 => r7	// 
	i2i r7 => r2		// source-level assignment
	write r2	
	divI r0, 1 => r8	// 
	i2i r8 => r2		// source-level assignment
	write r2	
	divI r1, 2 => r9	// 
	i2i r9 => r2		// source-level assignment
	write r2	
