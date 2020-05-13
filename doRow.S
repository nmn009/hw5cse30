	.arch armv6
	.global doRow
	
	.cpu cortex-a53
	.equ 	NUL, 0
	.equ 	FP_OFFSET, 32 //TODO: fill in with appropriate value -> (# of saved regs - 1) * 4
		
	.text


// TODO: Write doRow
doRow:
	// doRow's prolog
	push 	{r4-r10, fp, lr}		// using SP to save preserved regs that might be modified
	add	 fp, sp, #FP_OFFSET		// using SP to update FP to the new stackframe
	// assume R0 = dest, R1 = srcStart, R2 = srcEnd, R3 = cols
	mov r4, #0				// current = 0;
	add r2, r2, #1				// srcEnd = srcEnd + 1;
while:
	cmp r1,r2				// while ( srcStart != srcEnd +1){
 	beq done				// . 
	mov r5, #0				// int num_alive =0;
	add r7, r4, r3				// r7 = current + cols;
if1:						// . 
	add r8, r7, #1				// r8 = r7 + 1;
	ldrb r6, [r1, r8]			// r6 = r1[lower_right];
	cmp r6, #1				// if ( r1[lower_right] == 1);
	addeq r5, r5, #1			// num_alive++;
if2:						// .
	ldrb r6, [r1, -r8]			// r6 = r1[upper_left];
	cmp r6, #1				// if ( r1[upper_left] == 1)
	addeq r5, r5, #1			// num_alive++;
if3:						// .
	sub r8, r7, #1				// r8 = r7 - 1;
	ldrb r6, [r1, r8]			// r6 = r1[lower_left];
	cmp r6, #1				// if ( r1[lower_left] == 1)
	addeq r5, r5, #1			// num_alive++;
if4:						// .
	ldrb r6, [r1,-r8]			// r6 = r1[upper_right];
	cmp r6, #1				// if ( r1[upper_right] == 1)
	addeq r5, r5, #1			// num_alive++;
if5:	
	ldrb r6, [r1,r7]			// r6 = r1[down];
	cmp r6, #1				// if (r1[down] == 1)
	addeq r5, r5, #1			// num_alive++;
if6:
	ldrb r6, [r1, -r7]			// r6 = r1[up];
	cmp r6, #1				// if (r1[up] == 1);
	addeq r5, r5, #1			// num_alive++;
if7:
	add r8, r4, #1				// r8 = current + 1;
	ldrb r6, [r1, r8]			// r6 = r1[right];
	cmp r6, #1				// if( r1[right] == 1);
	addeq r5, r5, #1			// num_alive++;
if8:
	ldrb r6, [r1, -r8]			// r6 = r1[left];
	cmp r6, #1				// if( r1[left] == 1);
	addeq r5, r5, #1			// num_alive++;
	


	ldrb r9, [r1, r4]			// r9 = srcStart[i];
	cmp r9, #1				// if ( r9 == 1){
	beq live				// .
	cmp r5, #3				// 	if (num_alive == 3){
	beq will_live				// 		will_die;
	b   will_die				// } else { will_live;}
live:
	cmp r5, #2				// if (num_alive == 2 || num_alive == 3){
	beq will_live				// .
	cmp r5, #3				// will_live;
	beq will_live				// else { will_die }
	b   will_die				// }
will_live:
	mov r12, #1				// r12 = 1;
	strb r12, [r0, r4]			// dest[i] = r12 = 1;
	add r1, r1, #1				// *srcStart = *(srcStart +1);
	add r0, r0, #1				// *dest = *(dest+1);
	b while					// .
will_die:
	mov r12, #0				// r12 = 0;
	strb r12, [r0, r4]			// dest[i] = r12 = 0;
	add r0 , r0, #1				// *dest = *(dest+1);
	add r1, r1, #1				// *srcStart = *(strStart+1);
	b while					// .
done:	
	
	



	// doRow's epilog
	sub 	fp, sp, #FP_OFFSET		// using FP to restore SP to the old stackframe
	pop 	{r4-r10, fp, lr}		// using SP to restore regs saved in prolog
	bx 	lr				// using LR to update PC and thereby return
