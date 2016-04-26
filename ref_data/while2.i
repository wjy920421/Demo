	loadI 1 => r0		// source-level assignment
	loadI 10 => r1		// source-level assignment
	cmp_LT r0, r1 => r3	// 
	cbr r3 -> L0, L1	// 
L0:	nop			// top of while loop
	loadI 10 => r5		// int load of character literal
	i2c r5 => r4		// convert integer to character
	cwrite r4	
	write r0	
	loadI 32 => r7		// int load of character literal
	i2c r7 => r6		// convert integer to character
	cwrite r6	
	loadI 9 => r2		// source-level assignment
	loadI 1 => r8		// int load of integer literal
	cmp_GE r2, r8 => r9	// 
	cbr r9 -> L2, L3	// 
L2:	nop			// top of while loop
	write r2	
	subI r2, 1 => r10	// 
	i2i r10 => r2		// source-level assignment
	loadI 1 => r8		// int load of integer literal
	cmp_GE r2, r8 => r9	// 
	cbr r9 -> L2, L3	// 
L3:	nop			// bottom of while loop
	addI r0, 1 => r11	// 
	i2i r11 => r0		// source-level assignment
	cmp_LT r0, r1 => r3	// 
	cbr r3 -> L0, L1	// 
L1:	nop			// bottom of while loop
