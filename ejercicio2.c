/*
 * @File:   Ejercicio2.c - Ejercicio j
 *
 * Sinopsis: Segundo ejercicio propuesto del tema 2.
 *
 * El progrma realiza una petición al usuario para que introduzca una cantidad de
 * segundos, posteirormente se le muestra esa cantidad y su equivalente en
 * horas, minutos y lo que sobra en segundos.
 *
 * @author: Santiago Hoyos Zea
 *
 * fecha: 15/02/2017 19:36
 *
 * @version 0.1
 */

#include <stdio.h>

#define HORAS_LITERAL "horas"
#define MINUTOS_LITERAL "minutos"
#define SEGUNDOS_LITERAL "segundos"

/**
 * Funcion principal.
 * @return resultado de salida.
 */
int main() {

    //Declaramos un long para que no nos quedemos cortos.
    long segundos, minutos, horas;

    //Recogida de datos
    printf("Escribe una cantidad de segundos: ");
    scanf("%ld", &segundos);

    //Operaciones
    horas = segundos / 3600;
    minutos = (segundos % 3600) / 60;
    segundos = (segundos % 3600) % 60;

    printf("%ld %s ... %ld %s ... %ld %s.", horas, HORAS_LITERAL, minutos, MINUTOS_LITERAL, segundos, SEGUNDOS_LITERAL);

    //Acabamos el programa sin errres
    return 0;
}
