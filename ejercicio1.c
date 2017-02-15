/*
 * @File:   Ejercicio1.c - Ejercicio i
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
 * @version 0.2
 */

#include <stdio.h>

#define MINUTOS_LITERAL "minutos"
#define SEGUNDOS_LITERAL "segundos"

/**
 * Funcion principal.
 * @return resultado de salida.
 */
int main() {

    //Declaramos un long para que no nos quedemos cortos.
    long segundos, minutos;

    //Recogida de datos
    printf("Escribe una cantidad de segundos: ");
    scanf("%ld", &segundos);

    //Operaciones
    minutos = segundos / 60;
    segundos = segundos % 60;

    printf("%ld %s ... %ld %s.", minutos, MINUTOS_LITERAL, segundos, SEGUNDOS_LITERAL);

    //Acabamos el programa sin errres
    return 0;
}

