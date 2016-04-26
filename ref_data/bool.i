	loadI 1 => r0		// source-level assignment
	loadI 0 => r1		// source-level assignment
	// 'OR' case
	or r1, r1 => r3	// 
	cbr r3 -> L0, L1	// if-then or if-then-else
L0:	nop			// then part
	write r0	
	br -> L2		// branch to exit label
L1:	nop			// else part
	write r1	
	br -> L2		// no fall-through in iloc
L2:	nop			// exit label for if-then-else
	// 'OR' case
	or r0, r1 => r4	// 
	cbr r4 -> L3, L4	// if-then or if-then-else
L3:	nop			// then part
	write r0	
	br -> L5		// branch to exit label
L4:	nop			// else part
	write r1	
	br -> L5		// no fall-through in iloc
L5:	nop			// exit label for if-then-else
	// 'OR' case
	or r1, r0 => r5	// 
	cbr r5 -> L6, L7	// if-then or if-then-else
L6:	nop			// then part
	write r0	
	br -> L8		// branch to exit label
L7:	nop			// else part
	write r1	
	br -> L8		// no fall-through in iloc
L8:	nop			// exit label for if-then-else
	// 'OR' case
	or r0, r0 => r6	// 
	cbr r6 -> L9, L10	// if-then or if-then-else
L9:	nop			// then part
	write r0	
	br -> L11		// branch to exit label
L10:	nop			// else part
	write r1	
	br -> L11		// no fall-through in iloc
L11:	nop			// exit label for if-then-else
	// 'AND' case
	and r1, r1 => r7	// 
	cbr r7 -> L12, L13	// if-then or if-then-else
L12:	nop			// then part
	write r0	
	br -> L14		// branch to exit label
L13:	nop			// else part
	write r1	
	br -> L14		// no fall-through in iloc
L14:	nop			// exit label for if-then-else
	// 'AND' case
	and r0, r1 => r8	// 
	cbr r8 -> L15, L16	// if-then or if-then-else
L15:	nop			// then part
	write r0	
	br -> L17		// branch to exit label
L16:	nop			// else part
	write r1	
	br -> L17		// no fall-through in iloc
L17:	nop			// exit label for if-then-else
	// 'AND' case
	and r1, r0 => r9	// 
	cbr r9 -> L18, L19	// if-then or if-then-else
L18:	nop			// then part
	write r0	
	br -> L20		// branch to exit label
L19:	nop			// else part
	write r1	
	br -> L20		// no fall-through in iloc
L20:	nop			// exit label for if-then-else
	// 'AND' case
	and r0, r0 => r10	// 
	cbr r10 -> L21, L22	// if-then or if-then-else
L21:	nop			// then part
	write r0	
	br -> L23		// branch to exit label
L22:	nop			// else part
	write r1	
	br -> L23		// no fall-through in iloc
L23:	nop			// exit label for if-then-else
	// 'NOT' case
	not r1 => r11		// 
	cbr r11 -> L24, L25	// if-then or if-then-else
L24:	nop			// then part
	write r0	
	br -> L26		// branch to exit label
L25:	nop			// else part
	write r1	
	br -> L26		// no fall-through in iloc
L26:	nop			// exit label for if-then-else
	// 'NOT' case
	not r0 => r12		// 
	cbr r12 -> L27, L28	// if-then or if-then-else
L27:	nop			// then part
	write r1	
	br -> L29		// branch to exit label
L28:	nop			// else part
	write r0	
	br -> L29		// no fall-through in iloc
L29:	nop			// exit label for if-then-else
