/* 
 * @File:   Ejercicio1.c
 * 
 * Sinopsis: Primer ejercicio propuesto del tema 2.
 * 
 * El progrma realiza una petición al usuario para que introduzca una cantidad de
 * segundos, posteirormente se le muestra esa cantidad y su equivalente en
 * minutos y lo que sobra en segundos.
 * 
 * @author: Santiago Hoyos Zea
 *
 * fecha: 13/02/2017 19:02
 *
 * @version 0.1
 */

#include <stdio.h>

/**
 * Funcion principal.
 * @return resultado de salida.
 */
int main() {

    //Declaramos un long para que no nos quedemos cortos.
    long segundos;

    ///Recogida de datos
    printf("Escribe una cantidad de segundos: ");
    scanf("%ld", &segundos);

    printf("%ld minutos y %ld segundos.", (segundos / 60), (segundos % 60));

    //Acabamos el programa sin errres
    return 0;
}
