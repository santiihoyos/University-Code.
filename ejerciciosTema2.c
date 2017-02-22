/*
 * @File:   EjerciciosTema2.c - Ejercicio i+j+k
 *
 * Sinopsis: ejercicios propuestos del tema 2.
 *
 * El programa realiza una petición al usuario para que introduzca una cantidad de
 * segundos, posteirormente se le muestra esa cantidad y su equivalente en
 * horas, minutos y lo que sobra en segundos.
 *
 * @author: Santiago Hoyos Zea
 *
 * fecha: 22/02/2017
 *
 * @version 0.6 - Entrega 6
 */

#include <stdio.h>

//Constante numérica
const int SEGUNDOS_MINUTO = 60;
const int MINUTOS_HORA = 60;
const int HORAS_DIA = 24;

/**
 * Funcion principal.
 * @return resultado de salida.
 */
int main() {

    //Declaramos un long para que no nos quedemos cortos.
    long segundosRecogidos, segundosSalida, minutos, minutosMenosHoras, horas, horasMenosDias, dias;

    //Recogida de datos
    printf("Escribe una cantidad de segundos: ");
    scanf("%ld", &segundosRecogidos);

    segundosSalida = segundosRecogidos % SEGUNDOS_MINUTO;
    minutos = segundosRecogidos / SEGUNDOS_MINUTO;
    horas = minutos / MINUTOS_HORA;
    dias = horas / HORAS_DIA;

    minutosMenosHoras = minutos - (horas * MINUTOS_HORA);
    horasMenosDias = horas - (dias * HORAS_DIA);

    printf("%ld segundos son: %ld dias %ld horas %ld minutos %ld segundos, o bien,"
                   " %ld horas %ld minutos %ld segundos, o también, %ld minutos y %ld segundos",
           segundosRecogidos, dias, horasMenosDias, minutosMenosHoras, segundosSalida, horas, minutosMenosHoras,
           segundosSalida, minutos, segundosSalida);

    //Acabamos el programa sin errres
    return 0;
}
