/*
 * @File:   p9.c
 *
 * Sinopsis: Laboratorio 9
 *
 * Programa que dada una entrada de datos desde un fichero crea una matriz 3x3
 * y la suma y multiplica con otra introducida por teclado, dejan los resultados en ficheros
 * separados.
 *
 * @author: Santiago Hoyos Zea
 *
 * fecha: 09/04/2017
 *
 * @version 0.1 - Entrega 1
 */

#include <stdio.h>
#include <stdlib.h>

#define NOMBRE_FICHERO_MATRIZ "numeros.txt"
#define NOMBRE_FICHERO_SALIDA_SUMA "suma.txt"
#define NOMBRE_FICHERO_SALIDA_PRODUCTO "producto.txt"

FILE *abreFichero(const char *nombre, const char *modo);

_Bool cierraFichero(FILE *fichero);

void sumaMatrices(int filas, int columnas, int matrizA[filas][columnas], int matrizB[filas][columnas],
                  int matrizResultante[filas][columnas]);

void multiplicaMatrices(int filas, int columnas, int matrizA[filas][columnas], int matrizB[filas][columnas],
                        int matrizResultante[filas][columnas]);

void leeMatrizDesdeFichero(FILE *fichero, int filas, int columnas, int matrizSalida[filas][columnas]);

void escribeMatrizASalida(FILE *salida, int filas, int columnas, int matriz[filas][columnas]);

void pideMatriz(int filas, int columnas, int matrizSalida[filas][columnas]);

/**
 * Funcion principal.
 * @return estado de salida del programa.
 */
int main() {

    /* Declaramos el total de filas y columnas como constantes, no lo llevamos a #define  porque limitariamos
     * el programa a tener que recompilar para trabajar con matrices mas grandes. Asi dejamos la puerta abierta
     * a introducir un menu que pida el tamaño de la matriz.
     */
    const int filas = 3, columnas = 3;

    int matrizA[filas][columnas], matrizB[filas][columnas],
            matrizSumada[filas][columnas], matrizProducto[filas][columnas];

    FILE *ficheroMatriz = abreFichero(NOMBRE_FICHERO_MATRIZ, "r");
    FILE *ficheroSuma = abreFichero(NOMBRE_FICHERO_SALIDA_SUMA, "w");
    FILE *ficheroProduc = abreFichero(NOMBRE_FICHERO_SALIDA_PRODUCTO, "w");

    if (ficheroMatriz != NULL) {

        leeMatrizDesdeFichero(ficheroMatriz, filas, columnas, matrizA);

        cierraFichero(ficheroMatriz);

        pideMatriz(filas, columnas, matrizB);

        printf("Matriz A:\n");
        escribeMatrizASalida(stdout, filas, columnas, matrizA);

        printf("\nMatriz B:\n");
        escribeMatrizASalida(stdout, filas, columnas, matrizB);

        //Suma de las matrices
        sumaMatrices(filas, columnas, matrizA, matrizB, matrizSumada);
        printf("\nMatriz A+B: \n");
        escribeMatrizASalida(stdout, filas, columnas, matrizSumada);
        escribeMatrizASalida(ficheroSuma, filas, columnas, matrizSumada);
        cierraFichero(ficheroSuma);

        //Producto de las matrices
        multiplicaMatrices(filas, columnas, matrizA, matrizB, matrizProducto);
        printf("\nMatriz AxB: \n");
        escribeMatrizASalida(stdout, filas, columnas, matrizProducto);
        escribeMatrizASalida(ficheroProduc, filas, columnas, matrizProducto);
        cierraFichero(ficheroProduc);

        return EXIT_SUCCESS;

    } else {
        printf("Problema al leer fichero" NOMBRE_FICHERO_MATRIZ);
        return EXIT_FAILURE;
    }

}

/**
 * Pide una patriz al usuario de la dimension deseada.
 * @param filas /E filas deseadas
 * @param columnas /E columnas deseadas
 * @param matrizSalida /S Array de 2 dimesiones filas x columnas
 */
void pideMatriz(int filas, int columnas, int matrizSalida[filas][columnas]) {

    for (int k = 0; k < filas; ++k) {
        printf("Introducazca %d numeros separados por espacio para la fila %d: ", columnas, k);
        for (int i = 0; i < columnas; ++i) {
            scanf("%d", &matrizSalida[k][i]);
        }
    }
}

/**
 * Abre el fichero indicado
 * @param nombre /E ruta del fichero.
 * @return fichero FILE abierto modo escritura.
 */
FILE *abreFichero(const char *nombre, const char *modo) {

    FILE *fichero = fopen(nombre, modo);
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
 * Suma dos matrices.
 * @param matrizA /E matriz A
 * @param matrizB /E matriz B
 * @param matrizResultante /S referencia a la matriz de salida matrizA+B
 */
void sumaMatrices(int filas, int columnas, int matrizA[filas][columnas], int matrizB[filas][columnas],
                  int matrizResultante[filas][columnas]) {

    for (int i = 0; i < filas; i++) {
        for (int j = 0; j < columnas; j++) {
            matrizResultante[i][j] = (matrizA[i][j] + matrizB[i][j]);
        }
    }
}

/**
 * Dadas dos matrices cuadradas las multiplica de la misma dimension.
 * @param filas total filas de las matrices
 * @param columnas total columnas de las matrices
 * @param matrizA /E matriz A
 * @param matrizB /E matriz B
 * @param matrizResultante /S referencia a la matriz de salida matrizA*B
 */
void multiplicaMatrices(int filas, int columnas, int matrizA[filas][columnas], int matrizB[filas][columnas],
                        int matrizResultante[filas][columnas]) {

    for (int i = 0; i < filas; i++) {
        for (int j = 0; j < columnas; j++) {
            matrizResultante[i][j] = 0;
            for (int k = 0; k < columnas; k++) {
                matrizResultante[i][j] += (matrizA[i][k] * matrizB[k][j]);
            }
        }
    }
}

/**
 * Lee del fichero indicado la lista de numeros separadas por espacios.
 * @param fichero /E fichero que contiene los numeros.
 * @param filas /E total filas
 * @param columnas /E total columnas
 * @param matrizSalida /S array con el total de filas y columnas indicado y rellenado con los nuemros del fichero.
 */
void leeMatrizDesdeFichero(FILE *fichero, int filas, int columnas, int matrizSalida[filas][columnas]) {

    for (int i = 0; i < filas; i++) {
        for (int j = 0; j < columnas; j++) {
            fscanf(fichero, "%d", &matrizSalida[i][j]);
        }
    }
}

/**
 * Escribe en la salida indicada una matriz dada que debe coincidir en dimensiones con filas X columnas
 * @param ficheroSalida /E fichero de salida, puesde ser las salidas estandar
 * @param filas /E filas de la matriz a pintar
 * @param columnas /E columnas de la matriz a pintar
 * @param matriz /E matriz a pintar.
 */
void escribeMatrizASalida(FILE *salida, int filas, int columnas, int matriz[filas][columnas]) {

    for (int i = 0; i < filas; i++) {

        for (int j = 0; j < columnas; j++) {
            fprintf(salida, "%d\t", matriz[i][j]);
        }

        fputc('\n', salida);
    }
}