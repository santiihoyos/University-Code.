/*
 * @File:   EjerciciosTema2.c - Ejercicio i+j
 *
 * Sinopsis: ejercicios propuestos del tema 2.
 *
 * El programa realiza una petición al usuario para que introduzca una cantidad de
 * segundos, posteirormente se le muestra esa cantidad y su equivalente en
 * horas, minutos y lo que sobra en segundos.
 *
 * @author: Santiago Hoyos Zea
 *
 * fecha: 15/02/2017 19:36
 *
 * @version 0.3 - Entrega 3
 */

#include <stdio.h>

//Textos que el precompilador cambiará en código por el valor antes de compilar
#define HORAS_LITERAL "horas"
#define MINUTOS_LITERAL "minutos"
#define SEGUNDOS_LITERAL "segundos"

/**
 * Funcion principal.
 * @return resultado de salida.
 */
int main() {

    //Constantes numéricas
    const int SEGUNDOS_MINUTO = 60;
    const int SEGUNDOS_HORA = SEGUNDOS_MINUTO * 60;

    //Declaramos un long para que no nos quedemos cortos.
    long segundos, minutos, horas;

    //Recogida de datos
    printf("Escribe una cantidad de segundos: ");
    scanf("%ld", &segundos);

    //Operaciones
    horas = segundos / SEGUNDOS_HORA;
    minutos = (segundos % SEGUNDOS_HORA) / SEGUNDOS_MINUTO;
    segundos = (segundos % SEGUNDOS_HORA) % SEGUNDOS_MINUTO;

    printf("%ld %s ... %ld %s ... %ld %s.", horas, HORAS_LITERAL, minutos, MINUTOS_LITERAL, segundos, SEGUNDOS_LITERAL);

    //Acabamos el programa sin errres
    return 0;
}
