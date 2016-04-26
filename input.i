        loadI 1 => r1
        loadI 2 => r7
        cmp_LE r1, r7 => r6
        cbr r6 -> L000, L001
L000:   nop
        loadI 3 => r2
        loadI 6 => r9
        cmp_LE r2, r9 => r8
        cbr r8 -> L002, L003
L002:   nop
        cread => r10
        loadI 0 => r11
        subI r1, 1 => r12
        add r11, r12 => r11
        multI r11, 4 => r11
        subI r2, 3 => r13
        add r11, r13 => r11
        addI r11, 46 => r11
        cstore r10 => r11
        addI r2, 1 => r2
        loadI 6 => r15
        cmp_LE r2, r15 => r14
        cbr r14 -> L002, L003
L003:   nop
        addI r1, 1 => r1
        loadI 2 => r17
        cmp_LE r1, r17 => r16
        cbr r16 -> L000, L001
L001:   nop
        loadI 1 => r1
        loadI 2 => r19
        cmp_LE r1, r19 => r18
        cbr r18 -> L004, L005
L004:   nop
        loadI 3 => r2
        loadI 6 => r21
        cmp_LE r2, r21 => r20
        cbr r20 -> L006, L007
L006:   nop
        loadI 0 => r22
        subI r1, 1 => r23
        add r22, r23 => r22
        multI r22, 4 => r22
        subI r2, 3 => r24
        add r22, r24 => r22
        addI r22, 46 => r22
        cload r22 => r25
        cwrite r25
        addI r2, 1 => r2
        loadI 6 => r27
        cmp_LE r2, r27 => r26
        cbr r26 -> L006, L007
L007:   nop
        addI r1, 1 => r1
        loadI 2 => r29
        cmp_LE r1, r29 => r28
        cbr r28 -> L004, L005
L005:   nop
