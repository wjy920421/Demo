	loadI 99 => r2		// int load of char literal
	i2c r2 => r0		// source-level assignment
	loadI 100 => r3		// int load of char literal
	i2c r3 => r1		// source-level assignment
	cwrite r0	
	cwrite r1	
