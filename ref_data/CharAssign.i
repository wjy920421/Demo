	loadI 97 => r3		// int load of char literal
	i2c r3 => r0		// source-level assignment
	loadI 98 => r4		// int load of char literal
	i2c r4 => r1		// source-level assignment
	loadI 99 => r5		// int load of char literal
	i2c r5 => r2		// source-level assignment
	cwrite r0	
	cwrite r1	
	cwrite r2	
