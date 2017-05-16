/*
 * @File:   lab_b.c
 *
 * Sinopsis: Laboratorio B
 *
 * Programa que responde a las funcionalidades planteadas en el laboratorio B de programación.
 *
 * @author: Santiago Hoyos Zea
 *
 * fecha: 16/05/2017
 *
 * @version 0.1 - Entrega 1
 */

#include <stdio.h>

#define n  5

void getns(char *cadena);

void scanfns(char *);

void pideNombreArchivo(char *);

void muestraFichero24(FILE *);

/**
 * Funcion programa principal.
 * @return estado de salida.
 */
int main() {

    FILE *fichero;
    char nombreFichero[n];

    pideNombreArchivo(nombreFichero);
    fichero = fopen(nombreFichero, "r");

    if (fichero != NULL) {

        muestraFichero24(fichero);
        fclose(fichero);

    } else {
        printf("Error no se ha podido abrir el fichero.");
    }

    return 0;
}

/**
 * Lee una cadena de la entrada estandar y la devuelve, pitando por cada carater de más
 * leido superior a n.
 * @param cadena /E/S cadena leida
 */
void getns(char *cadena) {

    char tmp;
    int contador = 0; //<-- primera asignación

    while (scanf("%c", &tmp) > 0 && tmp != '\n') { //<-- cada comprobacion de bucle son 1 asignacion y 2 comparaciones

        if (contador < n - 1) {     //<-- otra comparación
            cadena[contador] = tmp; //<-- asignación++
        } else {
            printf("\a");
        }
        contador++; // <-- entendemos esto como un contador = contador +1; por tanto una asignación más.
    }

    cadena[n - 1] = '\0'; //<-- asignación++;

    /*
     *  (al pasar la referencia a tmp se le asigna valor dentro de la funnción scanf lo cuento como un =)
     *  para la primera letra dentro del rango son 4 asignaciones y 3 comparaciones
     *  para una letra distinta de la primera dentro del rango son 3 asignaciones y 3 comparaciones
     *  para una letra distinta de la primera fuera del rango son 2 asignaciones y 3 comparaciones.
     *  para el salto de linea son 2 asignaciones y 2 comparaciones
     *  -------------------------------------------------------------------------
     *  |   n               teclado                  asigna  compara   pitidos  |
     *  |   5   <enter>                             |   3       2         0     |
     *  |   5   a<enter>                            |   6       5         0     |
     *  |   5   hola<enter>                         |  15      14         0     |
     *  |   5   adios<enter>                        |  17      17         1     |
     *  |   5   Barcelona 1 - Real Madrid 1<enter>  |  61      83        23     |
     *  -------------------------------------------------------------------------
     */
}

/**
 * Lee una cadena hasta tabulador, espacio, o salto de linea y pita por cada
 * caracter de más leido.
 * @param cadena
 */
void scanfns(char *cadena) {

    char tmp;
    int contador = 0;

    while (scanf("%c", &tmp) > 0 && tmp != ' ' && tmp != '\t' && tmp != '\n') {

        if (contador < n - 1) {
            cadena[contador] = tmp;
        } else {
            printf("\a");
        }
        contador++;
    }

    cadena[n - 1] = '\0';
}

/**
 * Pide el nombre del archivo. Lee hasta un salto de linea.
 * @param nombreArchivo /E/S nombre del archivo leido de n-1 caracteres.
 * Pita por los caracteres sobreante mayores que N-1
 */
void pideNombreArchivo(char *nombreArchivo) {

    printf("Introduce el nombre del archivo: ");
    getns(nombreArchivo);
}

/**
 * Muestra un fichero abierto paginado a 24 lineas por página.
 * @param ficheroAbierto fichero ABIERTO.
 */
void muestraFichero24(FILE *ficheroAbierto) {

    char siguiente = NULL;
    char tmp[n] = "";
    int leidos = 0;

    do {

        for (int i = 0; i < 24 && tmp != NULL; ++i) {

            if (fgets(tmp, n, ficheroAbierto) != NULL) {
                printf(tmp);
            }
        }

        printf("mostrar siguiente página(s) salir(otro): ");

        leidos = scanf("%c", &siguiente);
        getchar();

    } while (leidos > 0 && siguiente == 's');

}