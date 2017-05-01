/*
 *  LabA
 *
 *  Programa para LAB-A tema ficheros binarios.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MENU \
"------------------------MENU--------------------------\n"\
"1- Mostrar todos los datos del fichero\n" \
"2- Añadir dato al final del fichero\n" \
"3- Leer dato X del fichero\n" \
"4- Cambiar último dato mostrado o escrito por otro\n" \
"0- Salir del programa\n" \
"------------------------------------------------------\n"

#define RUTA_FICHERO "datos.dat"

char muestraMenu();

FILE *abreFichero(const char *ruta, const char *modo);

_Bool cierraFichero(FILE *ficheroParaCerrar);

void imprimeDatosFichero(FILE *ficheroDatos);

void escribeAlFinal(int dato, FILE *fichero);

int pideDato(const char *texto);

_Bool muestraDatoEnPosicion(int posicion, FILE *fichero);

_Bool sobrescribePosicion(int posicion, int dato, const char *rutaFichero);

/**
 * Funcion principal del programa.s
 * @return estado de salida.
 */
int main() {

    FILE *ficheroDatos;
    int posUltimaAccion = -1; //<-- -1 significa que la ultima posicion se realizó en el final.
    _Bool todoOk = true;
    char op = muestraMenu();

    while (op != '0') {
        switch (op) {
            case '1':

                ficheroDatos = abreFichero(RUTA_FICHERO, "a+");

                if (ficheroDatos != NULL) {
                    imprimeDatosFichero(ficheroDatos);
                    posUltimaAccion = -1;
                    todoOk = todoOk && cierraFichero(ficheroDatos);
                } else {
                    todoOk = false;
                }

                break;

            case '2':

                ficheroDatos = abreFichero(RUTA_FICHERO, "a+");

                if (ficheroDatos != NULL) {
                    escribeAlFinal(pideDato("\nEscribe un número: "), ficheroDatos);
                    posUltimaAccion = -1;
                    todoOk = todoOk && cierraFichero(ficheroDatos);
                } else {
                    todoOk = false;
                }

                break;

            case '3':

                ficheroDatos = abreFichero(RUTA_FICHERO, "r+");
                int pos = pideDato("\nPosción deseada?: ");

                //Si no se lee nada en esa posición la ignoramos y seguimos con la última válida
                if (muestraDatoEnPosicion(pos, ficheroDatos)) {
                    posUltimaAccion = pos;
                }

                cierraFichero(ficheroDatos);
                break;

            case '4':

                sobrescribePosicion(posUltimaAccion, pideDato("\nEscribe un número: "), RUTA_FICHERO);
                break;

            default:
                printf("¡Opción invalida!\\n");
        }

        op = muestraMenu();
    }

    return todoOk ? EXIT_SUCCESS : EXIT_FAILURE;
}

/**
 * Muestra el menú y devuelve la opción seleccionada.
 * @return int con número de opción del menú seleccionada.
 */
char muestraMenu() {

    char respuesta;

    printf(MENU);

    do {
        scanf("%c", &respuesta);
    } while (respuesta == ' ' || respuesta == '\n');

    getchar(); //<-- limpiamos el buffer (último salto de linea -.-! )

    return respuesta;
}

/**
 * Abre un fichero en la ruta especifiada en modo binario, si no existe lo crea.
 * el flujo se situa al principio del fichero.
 * @param ruta /E rua del fichero
 * @return puntero al fichero abierto para lectura y escritura.
 */
FILE *abreFichero(const char *ruta, const char *modo) {
    return fopen(ruta, modo);
}

/**
 * Cierra el fichero indicado.
 * @param ficheroParaCerrar fichero que se desea cerrar.
 * @return true si se ha cerrado correctamente, false si algo falló.
 */
_Bool cierraFichero(FILE *ficheroParaCerrar) {
    return fclose(ficheroParaCerrar) != EOF ? true : false;
}

/**
 * Imprime por la salida estandar todos los datos del fichero.
 * @param ficheroDatos fichero con los datos.
 */
void imprimeDatosFichero(FILE *ficheroDatos) {

    rewind(ficheroDatos);

    int temp, contador = 0;
    int tamanioDato = sizeof(int);

    while (fread(&temp, tamanioDato, 1, ficheroDatos) != 0) {
        printf("dato[%d]=%d\n", contador + 1, temp);
        contador++;
    }
}

/**
 * Escribe al final del fichero un dato entero.
 * @param dato dato que se desea escribir.
 * @param fichero destino del dato.
 */
void escribeAlFinal(int dato, FILE *fichero) {
    fseek(fichero, 0, SEEK_END);
    fwrite(&dato, sizeof(dato), 1, fichero);
    fflush(fichero);
}

/**
 * Escribe un dato entero en un fichero dado.
 * @param posicion posicion donde se desa escribir, -1 si si se queire la última posición.
 * o el numero de la ultima posicion si se conoce.
 * @param fichero fichero contenedor
 */
_Bool sobrescribePosicion(int posicion, int dato, const char *rutaFichero) {

    _Bool hecho = false;
    FILE *fichero = abreFichero(rutaFichero, "a+");

    //Calculamos el total de datos y lo copiamos en un array temporal
    fseek(fichero, 0L, SEEK_END);

    int sz = ftell(fichero) / sizeof(int);
    int datos[sz];

    rewind(fichero);
    fread(datos, sizeof(int), sz, fichero);

    if (posicion == -1) {
        posicion = sz;
    }

    //remplazo de la posición
    datos[posicion - 1] = dato;

    if (cierraFichero(fichero)) {

        fichero = abreFichero(rutaFichero, "w");
        fwrite(datos, sizeof(datos), 1, fichero);
        hecho = cierraFichero(fichero);

    } else {
        printf("Algo ha ido mal en sobrescribePosicion");
    }

    return hecho;
}

/**
 * Pide un dato al usuario y lo lee de la entrada estandar
 * @return
 */
int pideDato(const char *texto) {

    printf(texto);

    int dato;
    scanf("%d", &dato);
    return dato;
}

/**
 * Muestra el dato que esta en la posicion indicada.
 * @param posicion posicion del dato que se desea leer.
 * @param fichero fichero con los datos.
 * @return true si se ha ledio algo, false de lo contrario.
 */
_Bool muestraDatoEnPosicion(int posicion, FILE *fichero) {

    fseek(fichero, sizeof(int) * (posicion - 1), SEEK_SET);

    int dato;
    int leidos = fread(&dato, sizeof(int), 1, fichero);

    if (leidos == 1) {
        printf("Dato[%d]= %d", posicion, dato);
    } else {
        printf("Nada que leer en esa posición!\n");
    }

    return leidos > 0;
}