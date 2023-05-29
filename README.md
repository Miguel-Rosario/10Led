# Practica3 10Led
EL objetivo de esta practica es controlar el encendido de 10 LED mediante un par de push button que serviran como contador, El primer Boton A aumentara uno al contador y el segundo Boton B disminuira en 1, Al oprimir los dos botones juntos el contador regresara a 0

## Funcion de configuracion de puertos (setup)
La funcion setup se encarga de inicializar la configuracion de los perifericos que vamos a usar pero es importante primero habiliatar la señal de reloj 
```asm
        // Habilitar señal de reloj para los puertos A y B.
        ldr     r0, =RCC_APB2ENR
        ldr     r3, =0x0000000c
        str     r3, [r0]
```
Configuramos los puertos de entrada., en este caso de los puertos B usaremos 2 como puertos de entrada.

```asm
        ldr     r0, =GPIOB_CRL  // Se la direccion base de los registros B
        ldr     r3, =0x44444488  // Configuramos los puertos de entrada B0 y B1
        str     r3, [r0]
```

Esta funcion se ejecuta solo una vez.

## Funcion principal (loop)
La funcion loop invoca a las funciones read_button, que se encarga de leer los botones.
Manda a llamar a las funciones disminuir o aumentar segun sea el caso, ademas en esta funcion resetea el contador sí los dos botones estan presionados.

```asm
        // decrementa
        ldr     r3, [r7] // Se carga counter
        mov     r0, r3
        sub     r0, r0, #1
        bl      disminuye
        ldr     r3, [r7]
```
En este fragmento de se manda a llamar la funcion disminuye y para mandar a llamar una funcion se tiene que calcular el argumento, mandar a llamar a la funcion y almacenar el valor de retorno en un argumento 


## Funcion  Aumenta en 1 al contador (aumentar) y disminuye en 1 al contador (disminuir)
Son funciones diferentes que hacen una funcion similar, en estas funciones se configuran los puertos de salida (leds) dependiendo del valor del contador 


