/*
 * @File:   p8_data.c
 *
 * Sinopsis: Laboratorio 8
 *
 * Programa que dado una semilla y un numero de datos genera aleatorios
 * con la semilla tantos como datos se indiquen, y los guarda en un fichero.
 * llamadao datos.txt en la ruta dle ejecutable.
 *
 * @author: Santiago Hoyos Zea
 *
 * fecha: 08/04/2017
 *
 * @version 0.1 - Entrega 1
 */

#include <stdio.h>
#include <stdlib.h>

#define TEXTO_PETICION_SEMILLA "Introduce un número para al semilla: "
#define TEXTO_PETICION_NUMERO "Introduce el número de datos:"
#define NOMBRE_FICHERO_SALIDA "datos.txt"

void pideDatos(int *semilla, int *numDatos);

int generaAleatorio();

void escribeFichero(FILE *salida, int cantidadValores);

FILE *abreFichero(const char *nombre);

_Bool cierraFichero(FILE *fichero);

/**
 * Funcion principal
 *
 * @return estado de salida.
 */
int main() {

    FILE *fichero = NULL;
    int semilla = 1, numDatos = 1;

    pideDatos(&semilla, &numDatos);
    srand(semilla);

    fichero = abreFichero(NOMBRE_FICHERO_SALIDA);

    if (fichero != NULL) {

        escribeFichero(fichero, numDatos);

        if (!cierraFichero(fichero)) {
            printf("Error! al cerrar el fichero. " NOMBRE_FICHERO_SALIDA);
            exit(EXIT_FAILURE);
        }

    } else {
        printf("\nError al abrir el fichero. " NOMBRE_FICHERO_SALIDA);
        exit(EXIT_FAILURE);
    }

    return EXIT_SUCCESS;
}

/**
 * Pide los datos al usuario.
 * @param semilla /S referencia a la variable de semilla.
 * @param numDatos /S referencia a la variable de nuemero de datos.
 */
void pideDatos(int *semilla, int *numDatos) {

    printf(TEXTO_PETICION_SEMILLA);
    scanf("%d", semilla);

    printf(TEXTO_PETICION_NUMERO);
    scanf("%d", numDatos);
}

/**
 * Genera un aleatorio en un rango = [limiteInferior, limiteSuperior]
 * @param limiteInferior /E el aleatorio sera mayor que el limite inferior.
 * @param limiteSuperior /E el aleatorio sera menor que el limite superior.
 */
int generaAleatorio() {

    double num = (rand() / (1.0 + RAND_MAX));
    return (int) (num * 100) + 1;
}

/**
 * Abre el fichero indicado
 * @param nombre /E ruta del fichero.
 * @return fichero FILE abierto modo escritura.
 */
FILE *abreFichero(const char *nombre) {

    FILE *fichero = fopen(nombre, "w");
    return fichero;
}

/**
 * Cierra un fichero infdicado.
 * @param fichero /E fichero que se desea cerrar
 * @return _Bool /S true si se ha cerrado correctamente.
 */
_Bool cierraFichero(FILE *fichero) {
    return fclose(fichero) != EOF;
}

/**
 * Escribe al fichero indicado n valores aleatorios entre 1 y 100 en 5 columnas.
 * @param cantidadValores /E cantidad de calores a pintar.
 * @param salida /E/S fichero en elq eu se desea escribir la informacion.
 * @return
 */
void escribeFichero(FILE *salida, int cantidadValores) {

    const unsigned int TOTAL_COLUMNAS = 5;
    int contadorPintados = 0;

    while (contadorPintados < cantidadValores) {

        for (int i = 0; i < TOTAL_COLUMNAS; i++) {

            fprintf(salida, "%d\t", generaAleatorio());
            contadorPintados++;

        }

        fputc('\n', salida);
    }
}