/* Lab5   */

.include "gpio.inc" @ Includes definitions from gpio.inc file

.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "nvic.inc"


delay:
        // Prologue
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        // Body function
        mov     r0, #1023 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
// for (i = 0; i < ms; i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       F3
// for (j = 0; j < tick; j++)
F4:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       F5
F6:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
F5:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     F6
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
F3:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     F4
        // Epilogue
        adds    r7, r7, #28
        mov	    sp, r7
        pop	    {r7}
        bx	    lr
.size	delay, .-delay


read_button:
        /*Creacion del prologo */
        push    {r7, lr}
        sub     sp, sp, #20
        adds    r7, sp, #0
        str     r0, [r7, #4]
        // lee boton de entrada
        ldr     r0, =GPIOB_IDR
        ldr     r0, [r0]
        ldr    r3, [r7, #4]
        and     r3, r0, r3
        lsrs    r0, r3, #0
	
        cmp     r0, 0x0
        bne     J1
        //  falso
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #20
        mov     sp, r7
        pop     {r7, lr}
        bx      lr
J1:
        // counter = 0
        mov     r3, #0
        str     r3, [r7, #12]
        // Se brinca al ciclo for
        // i = 0
        mov     r3, #0
        str     r3, [r7, #8]
        b       F
F_1:  
        mov     r0, #20
        bl      delay
        // lee boton 
        ldr     r0, =GPIOB_IDR
        ldr     r0, [r0]
        ldr    r1, [r7, #4]
        and     r1, r0, r1
        lsrs    r0, r1, #0

        cmp     r0, 0x0
        bne     J2

        ldr     r2, [r7, #12]
        mov     r2, #0
        str     r2, [r7, #12]
        b       J3
J2:
        // counter+1
        ldr     r3, [r7, #12]
        adds    r3, r3, #1
        str     r3, [r7, #12]
        // if (counter >= 4)
        ldr     r0, [r7, #12]
        cmp     r0, 0x4
        blt     J3
        // return true
        mov     r3, #1
        mov     r0, r3
        adds    r7, r7, #20
        mov     sp, r7
        pop     {r7, lr}
        bx      lr
J3:
        ldr     r3, [r7, #8]
        adds    r3, r3, #1
        str     r3, [r7, #8]
F:     
        ldr     r3, [r7, #8]
        mov     r0, #10
        cmp     r3, r0
        blt     F_1
        /*epilogo*/
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #20
        mov     sp, r7
        pop     {r7, lr}
        bx      lr
.size	read_button, .-read_button

disminuye:
        /*Prologo*/
        push    {r7}
        sub     sp, sp, #28
        add     r7, sp, #0

        /*Se respalda el argumento*/
        str     r0, [r7, #24]
        ldr     r4, =0x44444444
        ldr     r0, =GPIOA_CRH//alto
        str     r4, [r0]
        ldr     r4, =0x44444444
        ldr     r0, =GPIOA_CRL//bajo
        str     r4, [r0]
        // int i = n
        ldr     r0, [r7, #24]
        mov     r3, r0
        str     r3, [r7]
        // if (n < 0)
        ldr     r3, [r7]
        cmp     r3, 0x0
        bgt     E1
        mov     r3, #1023
        str     r3, [r7]

E1:
        /*Cargamos el valor actual de i*/
        // int j = 0
        mov     r3, #0
        str     r3, [r7, #4]
        b       FOR3
L7:    

        mov     r3, #0
        str     r3, [r7, #4]

        ldr     r4, =0x44444444
        str     r4, [r7, #16]

        ldr     r4, =0x44444444
        str     r4, [r7, #20]
        b       FOR4
L8:

//         # Cargar i
         ldr     r3, [r7]
//         # Cargar j
         ldr     r2, [r7, #4]
//         # Se realiza (i >> j)
         lsr     r3, r3, r2
         mov     r2, #1
         and     r3, r3, r2
         mov     r2, #1
         cmp     r3, r2
         bne     L9
        // Se carga j (j << 2)
        ldr     r3, [r7, #4]
        lsls    r4, r3, #2
        // (0x7 << (i << 2))
        mov     r3, #7
        lsl     r3, r3, r4
        // Se carga 0x44444444 y se aplica la mascara
        ldr     r4, [r7, #16]
        eor     r4, r4, r3
        str     r4, [r7, #16]
        ldr     r3, [r7, #24]
        ldr     r0, [r7]
        cmp     r0, r3
        bne     B2
        ldr     r4, [r7, #16]
        ldr     r5, =GPIOA_CRL
        str     r4, [r5]
        // SE carga j
        ldr     r4, [r7, #4]
        mov     r2, #0
        // calcula la direccion a encender
        lsl     r3, r2, r4
        ldr     r0, =GPIOA_ODR
        str     r3, [r0]

B2:
        // Se carga j
        ldr     r4, [r7, #4]
        // Se carga 7
        mov     r3, #8

        // if(j >= 8)
        cmp     r4, r3
        blt     L9 // L10
        // Se carga j (j << 2)
        // j - 8
        sub     r3, r4, r3
        lsls    r4, r3, #2
        // (0x7 << (i << 2))
        mov     r3, #7
        lsl     r3, r3, r4
        ldr     r4, [r7, #20]
        eor     r4, r4, r3
        str     r4, [r7, #20]
        ldr     r3, [r7, #24]
        ldr     r0, [r7]
        cmp     r0, r3
        bne     L9
        ldr     r4, [r7, #20]
        ldr     r5, =GPIOA_CRH
        str     r4, [r5]

        // SE carga j
        ldr     r4, [r7, #4]
        mov     r2, #0
        // Se calcula la direccion a encender
        lsl     r3, r2, r4
        ldr     r0, =GPIOA_ODR
        str     r3, [r0]

L9:        
        ldr     r3, [r7, #4]
        adds    r3, r3, #1
        str     r3, [r7, #4]
FOR4:   // Cargar j
        ldr     r3, [r7, #4]
        mov     r2, #10
        cmp     r3, r2
        blt     L8
        // i--
        ldr     r3, [r7]
        subs    r3, r3, #1
        str     r3, [r7]
FOR3:   // Cargar i
        // i >= 0
        ldr     r3, [r7]
        cmp     r3, 0x1
        bge     L7

        /*Epilogo*/
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #28
        mov     sp, r7
        pop     {r7}
        bx      lr
.size	disminuye, .-disminuye


aumenta:
        /*Prologo*/
        push    {r7}
        sub     sp, sp, #28
        add     r7, sp, #0

        /*Se respalda el argumento n*/
        str     r0, [r7, #24]
        //str     r1, [r7, #28]

        ldr     r4, =0x44444444
        ldr     r0, =GPIOA_CRH
        str     r4, [r0]

        ldr     r4, =0x44444444
        ldr     r0, =GPIOA_CRL
        str     r4, [r0]

        // int i = n - 1
        ldr     r3, [r7, #24]
        //	subs    r3, r3, #1
        str     r3, [r7]
        // 	int j = 0
        mov     r3, #0
        str     r3, [r7, #4]
        // 	Salta al bucle externo:
        b       FOR1
 L1:    // Salta al for interno:
        //		 j = 0
        mov     r3, #0
        str     r3, [r7, #4]

        // Direccion de registros bajos
        ldr     r4, =0x44444444
        str     r4, [r7, #16]
        // Direccion de registros altos
        ldr     r4, =0x44444444
        str     r4, [r7, #20]
        b       FOR2
L2:
        // if (((i >> j) & 1) == 1)
//         # Cargar i
         ldr     r3, [r7]
//         # Cargar j
         ldr     r2, [r7, #4]
//         # Se realiza (i >> j)
         lsr     r3, r3, r2
         // Se realiza (i >> j) & 1
         mov     r2, #1
         and     r3, r3, r2
         // (((i >> j) & 1) == 1)?
         mov     r2, #1
         cmp     r3, r2
         bne     B1
        // Se carga j (j << 2)
        ldr     r3, [r7, #4]
        lsls    r4, r3, #2
        // (0x7 << (i << 2))
        mov     r3, #7
        lsl     r3, r3, r4
        
        ldr     r4, [r7, #16]
        eor     r4, r4, r3
        str     r4, [r7, #16]

        // if(i == n ) <- n es un argumento, i es contador
        // se carga n
        ldr     r3, [r7, #24]
        // se carga i
        ldr     r0, [r7]
        cmp     r0, r3
        bne     B0

        ldr     r4, [r7, #16]
        ldr     r5, =GPIOA_CRL
        str     r4, [r5]
        // SE carga j
        ldr     r4, [r7, #4]
        mov     r2, #0
        // Se calcula la direccion a encender
        lsl     r3, r2, r4
        ldr     r0, =GPIOA_ODR
        str     r3, [r0]
B0:

        // Se carga j
        ldr     r4, [r7, #4]
        // Se carga 7
        mov     r3, #8

        // if(j >= 8)
        cmp     r4, r3
        blt     B1
        // Se carga j (j << 2)
        // j - 8
        sub     r3, r4, r3
        lsls    r4, r3, #2
        // (0x7 << (i << 2))
        mov     r3, #7
        lsl     r3, r3, r4

        ldr     r4, [r7, #20]
        eor     r4, r4, r3
        str     r4, [r7, #20]

        ldr     r3, [r7, #24]
        ldr     r0, [r7]
        cmp     r0, r3
        bne     B1

        ldr     r4, [r7, #20]
        ldr     r5, =GPIOA_CRH
        str     r4, [r5]
        ldr     r4, [r7, #4]
        mov     r2, #0
        // Se calcula la direccion a encender
        lsl     r3, r2, r4
        ldr     r0, =GPIOA_ODR
        str     r3, [r0]

      // Aqui se apagan los leds
B1:

        // j++
        ldr     r1, [r7, #4]
        adds    r1, r1, #1
        str     r1, [r7, #4]

FOR2:   // Cargar j
        ldr     r3, [r7, #4]
        mov     r2, #10
        cmp     r3, r2
        blt     L2
        // if(input == 1)
        // i++ / i--
        ldr     r3, [r7]
        subs    r3, r3, #1
        str     r3, [r7]
FOR1:   // Cargar i
        ldr     r3, [r7]
        // Cargar n
        ldr     r2, [r7, #24]
        // i < n / i >= n
        cmp     r3, r2
        bge     L1 //mayor o igual, salta

        /*Epilogo*/
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #28
        mov     sp, r7
        pop     {r7}
        bx      lr
.size	aumenta, .-aumenta


setup:
        push    {r7, lr}
        sub     sp, sp, #20
        add     r7, sp, #0
        // Habilitar señal de reloj para los puertos A y B.
        ldr     r0, =RCC_APB2ENR
        ldr     r3, =0x0000000c
        str     r3, [r0]

        /*Configuramos los puertos de entrada*/
        ldr     r0, =GPIOB_CRL  // Se la direccion base de los registros B
        ldr     r2, =0x44444488  // Configuramos los puertos de entrada B0 y B1
        str     r2, [r0]

        /* int counter = 0*/
        mov     r2, #1024
        str     r2, [r7]


        /* buttonA */
        mov     r2, #0
        str     r2, [r7, #4]

        /* buttonB */
        mov     r2, #0
        str     r2, [r7, #8]

        /*press_btn_A*/
        mov     r2, #0
        str     r2, [r7, #12]

        /*press_btn_B*/
        mov     r2, #0
        str     r2, [r7, #16]

loop:
        // read button A
        mov     r0, #1
        bl      read_button
        str     r0, [r7, #4]


        // lee button B
        mov     r0, #2
        bl      read_button
        str     r0, [r7, #8]
        mov     r0, #20
        bl      delay
        ldr     r3, [r7, #4]
        cmp     r3, 0x0
        bne     L12
        // presiona boton_A = 0
        mov     r3, #0
        str     r3, [r7, #12]
L12:

        // if (buttonB == 0)
        ldr     r3, [r7, #8]
        cmp     r3, 0x0
        bne     L13
        // press_btn_B = 0
        mov     r3, #0
        str     r3, [r7, #16]
L13://if botonA = 0 && botonB =0
        ldr     r3, [r7, #4]
        cmp     r3, 0x0
        bne     X1
        ldr     r3, [r7, #12]
        cmp     r3, 0x0
        bne     X1
        // press_btn_A = 1
        mov     r3, #1
        str     r3, [r7, #12]
        // increment
        ldr     r3, [r7]
        mov     r0, r3
        bl      aumenta
        // counter++
        ldr     r3, [r7]
        adds    r3, r3, #1
        str     r3, [r7]

X1:     // if (buttonB == 0)
        ldr     r3, [r7, #8]
        cmp     r3, 0x0
        bne     X2
        ldr     r3, [r7, #16]
        cmp     r3, 0x0
        bne     X2
        mov     r3, #1
        str     r3, [r7, #16]
        // decrementa
        ldr     r3, [r7] // Se carga counter
        mov     r0, r3
        sub     r0, r0, #1
        bl      disminuye
        // counter--
        ldr     r3, [r7]
        subs    r3, r3, #1
        str     r3, [r7]

X2:     // else: reset
        ldr     r0, [r7, #4]
        ldr     r3, [r7, #16]
        cmp     r0, r3
        bne     X3
        ldr     r0, [r7, #8]
        ldr     r3, [r7, #12]
        cmp     r0, r3
        bne     X3
        mov     r3, #1024
        mov     r0, r3
        bl      aumenta
        mov     r3, #1024
        mov     r0, r3
        bl      disminuye
        mov     r3, #1024
        str     r3, [r7]
X3:
        b       loop

