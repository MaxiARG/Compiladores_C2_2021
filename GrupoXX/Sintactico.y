%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"


struct struct_tablaSimbolos
{
	char nombre[100];
	char tipo[100];
	char valor[50];
	char longitud[100];
};

int yystopparser=0;
FILE  *yyin;


extern struct struct_tablaSimbolos tablaSimbolos[1000]; 
extern int puntero_array;
/**Variabales para asignacion de tipos a los id**/
 int contadorTipos = 0;
 char* aux_tipo_dato;
 char tablaTipos[100][10];
char tablaVar[100][10];
 int contadorId = 0;
 int agregar_TipoEn_TS(char* nombre, int contadorId); // funcion para completar el campo tipo en ts.

%}

%token PROGRAM
%token END
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DISPLAY
%token GET
%token DIM
%token AS
%token COMP_IGUAL
%token COMP_MAYOR
%token COMP_MENOR
%token COMP_MAYOR_IGUAL
%token COMP_MENOR_IGUAL
%token COMP_DISTINTO
%token OP_ASIG
%token TIPO_INT
%token TIPO_FLOAT
%token TIPO_STRING
%token <num>CTE_ENTERA
%token <real>CTE_REAL
%token <str>CTE_STRING
%token OP_MAS 
%token OP_MENOS
%token OP_MULT
%token OP_DIV
%token OP_LOG_AND
%token OP_LOG_OR
%token OP_LOG_NOT
%token DP
%token PYC
%token COMA
%token <strid>ID
%token P_A
%token P_C
%token LL_A
%token LL_C
%token C_A
%token C_C

%union{
char * strid;
char * num;
char * real; 
char * str;
}

%%
programa:
                  PROGRAM {printf(" Inicio del Compilador\n");} zona_declaracion algoritmo  {printf("FIN COMPILADOR OK\n");};
                 
zona_declaracion:
                               declaraciones;

declaraciones:
                         declaracion
                         |declaraciones declaracion;

declaracion:
					DIM C_A lista_var C_C  AS C_A  lista_tipo C_C{validar_declaracion(contadorTipos,contadorId);};


lista_var:
               ID {strcpy(tablaVar[contadorId],yylval.strid) ;  contadorId++; }
              | lista_var COMA  ID {strcpy(tablaVar[contadorId],yylval.strid) ; contadorId++;};

 
lista_tipo:
                lista_tipo COMA  TIPO_INT { aux_tipo_dato="int"; strcpy(tablaTipos[contadorTipos],aux_tipo_dato);  agregar_TipoEn_TS(tablaVar[contadorTipos],contadorTipos); contadorTipos++; }
               | lista_tipo COMA  TIPO_FLOAT { aux_tipo_dato="float"; strcpy(tablaTipos[contadorTipos],aux_tipo_dato); agregar_TipoEn_TS(tablaVar[contadorTipos],contadorTipos); contadorTipos++; }
               |lista_tipo COMA  TIPO_STRING { aux_tipo_dato="string"; strcpy(tablaTipos[contadorTipos],aux_tipo_dato); agregar_TipoEn_TS(tablaVar[contadorTipos],contadorTipos); contadorTipos++; }
               | TIPO_INT { aux_tipo_dato="int"; strcpy(tablaTipos[contadorTipos],aux_tipo_dato); agregar_TipoEn_TS(tablaVar[contadorTipos],contadorTipos); contadorTipos++;}
               |TIPO_FLOAT {  aux_tipo_dato="float"; strcpy(tablaTipos[contadorTipos],aux_tipo_dato); agregar_TipoEn_TS(tablaVar[contadorTipos],contadorTipos); contadorTipos++; }
              |TIPO_STRING { aux_tipo_dato="string"; strcpy(tablaTipos[contadorTipos],aux_tipo_dato); agregar_TipoEn_TS(tablaVar[contadorTipos],contadorTipos); contadorTipos++ ;};
              

algoritmo:
                 bloque END{printf("Fin de bloque\n");};

bloque:
            sentencia
           |bloque sentencia;

sentencia:
                  asignacion
                  |seleccion
                  |ciclo
                  |entrada
                  |salida;

ciclo:
         WHILE { printf("ciclo  WHILE\n");} P_A condicion P_C LL_A bloque LL_C;
       
asignacion:
                    ID OP_ASIG expresion {printf(" ASIGNACION\n");};
                  
          
seleccion: 
    	 IF  condicion THEN bloque ENDIF{printf("     IF\n");}
	| IF  condicion THEN bloque ELSE bloque ENDIF {printf("     IF con ELSE\n");};

condicion:
         comparacion 
         |comparacion OP_LOG_AND comparacion
         |comparacion OP_LOG_OR comparacion	
         |comparacion OP_LOG_NOT comparacion; 

comparacion:
	   expresion COMP_IGUAL expresion
                    |expresion COMP_MAYOR expresion	
                    |expresion COMP_MENOR expresion
                    |expresion COMP_MAYOR_IGUAL expresion  
                    |expresion COMP_MENOR_IGUAL expresion 
                    |expresion COMP_DISTINTO expresion


expresion:
                  expresion OP_MAS termino
                  |expresion OP_MENOS termino
                  |termino;

termino:
             termino OP_MULT factor
             |termino OP_DIV factor
             |factor;
                         

factor:
           ID {printf("Factor es ID\n");}
           |CTE_ENTERA {printf("Factor es CTE_ENTERA\n");}
           |CTE_REAL {printf("Factor es CTE_REAL\n");}
           |CTE_STRING {printf("Factor es CTE_STRING\n");}
           |P_A expresion P_C;
 
entrada: 
              GET{printf("\tGET\n");} ID;

salida:
           DISPLAY{printf("\tDISPLAY\n");} CTE_STRING | DISPLAY{printf("\tDISPLAY\n");} ID;
          
          
%%
 
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  return 0;
}

int agregar_TipoEn_TS(char* nombre, int contadorTipos)
{     
                            
                  if(contadorTipos>contadorId)
		return 0; 
                 else
                {
	int i;          
                  char lexema[50]; 
	lexema[0]='_';
	lexema[1]='\0';
	strcat(lexema,nombre);//Armo el lexema agregandole el guion bajo al principio. 
                 
                    for(i = 0; i < puntero_array; i++)
                   {
	       if(strcmp(tablaSimbolos[i].nombre, lexema) == 0)
                         {
	         if(tablaSimbolos[i].tipo[0] == '\0')
		      strcpy(tablaSimbolos[i].tipo,tablaTipos[contadorTipos]);
		  
	
		   return 1; 
	    }
                 }
                   	               
              }
	
 return 0;
	
}


