%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <math.h>
#include "y.tab.h"


struct struct_tablaSimbolos{
	char nombre[100];
	char tipo[100];
	char valor[50];
	char longitud[100];
};
char buffer[30];
FILE *yyin;
int puntero_array = 0;
struct struct_tablaSimbolos tablaSimbolos[1000];


int yyerror(void);
void validar_rango_entero(char*);
void validar_rango_real(char*);
void controlar_cant_caracteres(char*);
void validar_declaracion(int, int);

int guardar_TS(char*, char*);
int escribir_TS();
%}
%option noyywrap  
%option yylineno 

DIGITO			[0-9]
LETRA			[a-zA-Z]
ID			{LETRA}({LETRA}|{DIGITO})*
CTE_ENTERA                            -?{DIGITO}+
CTE_REAL                                 ({DIGITO})*"."({DIGITO})*
COMILLAS                                 "\""
COM_INI                                          "\*/" 
COM_FIN                                        "\/*"
CARACTERES	                 ({LETRA}|\$|\%|\&|\/|\(|\)|\=|\\|\?)
ESPACIO		                 " "
CTE_STRING                       {COMILLAS}({CARACTERES}|{DIGITO}|{ESPACIO})+{COMILLAS}
COMENTARIO                     {COM_INI}({CARACTERES}|{DIGITO}|{ESPACIO})+{COM_FIN}
COMENTARIOS	           {COM_INI}({CARACTERES}|{DIGITO}|{ESPACIO}|{COMENTARIO})+{COM_FIN}



%%
"program"		                   {return PROGRAM;}
"end"                                             { if(escribir_TS() == 0) printf("Error al crear el archivo de tabla de simbolos\n"); printf("Palabra reservada END: %s\n",yytext); return END;}
"if"                                                  { printf("Palabra Reservada IF:  %s\n",yytext); return IF; }
"then"                                            {  printf("Palabra Reservada THEN:  %s\n",yytext); return THEN;}
"endif"                                          {  printf("Palabra Reservada ENDIF:  %s\n",yytext); return ENDIF;}
"while"                                          {  printf("Palabra Reservada WHILE:  %s\n",yytext); return WHILE; }
"else"                                           {  printf("Palabra Reservada ELSE:  %s\n",yytext); return ELSE; }
"display"                                       {  printf("Palabra Reservada DISPLAY:  %s\n",yytext); return DISPLAY; }
"get"                                             {  printf("Palabra Reservada GET:  %s\n",yytext); return GET; }
"dim"                                            {  printf("Palabra Reservada DIM:  %s\n",yytext); return DIM; } 
"as"                                              {  printf("Palabra Reservada AS:  %s\n",yytext); return AS; }
"=="                                             {  printf("Comparador  IGUAL:  %s\n",yytext); return COMP_IGUAL; }
">"                                               {  printf("Comparador MAYOR:  %s\n",yytext); return COMP_MAYOR; }
"<"                                              {  printf("Comparador  MENOR:  %s\n",yytext); return COMP_MENOR; }
">="                                           {  printf("Comparador MAYOR IGUAL:  %s\n",yytext); return COMP_MAYOR_IGUAL; } 
"<="                                          {  printf("Comparador MENOR IGUAL:  %s\n",yytext); return COMP_MENOR_IGUAL; }
"!="                                          {  printf("Comparador DISTINTO:  %s\n",yytext); return COMP_DISTINTO;}
":="                                          {  printf("ASIGNACION:  %s\n",yytext); return OP_ASIG;}
"int"                                         {  printf("Palabra Reservada INT:  %s\n",yytext); return TIPO_INT;} 
"float"                                     {  printf(" Palabra Reservada FLOAT  %s\n",yytext); return TIPO_FLOAT; } 
"string"                                  {  printf("Palabra Reservada STRING:  %s\n",yytext); return TIPO_STRING; }
{CTE_ENTERA}                  { validar_rango_entero(yytext); guardar_TS("CTE",yytext); yylval.num = strdup(yytext); printf("Cte. Entera:  %s\n",yytext); return CTE_ENTERA;}
{CTE_REAL}                        { validar_rango_real(yytext); guardar_TS("CTE",yytext); yylval.real = strdup(yytext); printf("Cte. Real:  %s\n",yytext); return CTE_REAL; }
{CTE_STRING}                    { controlar_cant_caracteres(yytext); guardar_TS("CTE",yytext); yylval.real = strdup(yytext); printf("Cte. String:  %s\n",yytext); return CTE_STRING; }

"+"                                         {  printf("OP_MAS:  %s\n",yytext); return OP_MAS;  }  
"-"                                         {  printf("OP_MENOS:  %s\n",yytext); return OP_MENOS; }
"*"                                        {  printf("OP_MULT:  %s\n",yytext); return OP_MULT; }
"/"                                        {  printf("OP_DIV:  %s\n",yytext); return OP_DIV; }
"and"                                  { printf("OP_LOG_AND:  %s\n",yytext); return OP_LOG_AND; }
"or"                                      { printf("OP_LOG_OR:  %s\n",yytext); return OP_LOG_OR; }
"not"                                     {printf("OP_LOG_NOT:  %s\n",yytext); return OP_LOG_NOT; } 
":"                                         { printf("DOS_PUNTOS:  %s\n",yytext); return DP; }
";"		         { printf("PUNTO_Y_COMA:  %s\n",yytext); return PYC; }
","		         { printf("COMA:  %s\n",yytext); return COMA; }
{ID}                                       { controlar_cant_caracteres(yytext); guardar_TS("ID",yytext); yylval.strid = strdup(yytext); printf(" ID: %s\n",yytext); return ID; }
"("                                          {printf(" P_A: %s\n",yytext); return P_A;}
")"                                          { printf(" P_C: %s\n",yytext); return P_C; }
"{"                                          { printf(" LL_A: %s\n",yytext); return LL_A; }
"}"                                          { printf(" LL_C: %s\n",yytext); return LL_C; }
"["		           { printf(" C_A: %s\n",yytext); return C_A; }
"]"	                              { printf(" C_C: %s\n",yytext); return C_C; }	
{COMENTARIO}                   {printf("Es un comentario:  %s\n",yytext);}

"\n"
"\t"
" "
.                                                            yyerror();
%%

void validar_rango_entero(char* str)
{
 int num = atoi(str);
 if(num<=-32768|| num>=32767)
  {
      printf("Entero fuera de rango\n");
  }
}


void validar_rango_real(char* str)
{
	float num = atof(str);
                  if((num< pow(3.40282,-38)) || (num > pow(3.40282,38))) {
	    printf("Real fuera de rango\n");  
	} 
}

void validar_declaracion(int cantTipos, int cantVariables)
{
  if(cantTipos != cantVariables)
  {
      printf("\n Error en la declaracion de variables, cantidad de tipos no coincide con cantidad de variables\n");
     system("Pause");
     exit(1);
  }
}

void controlar_cant_caracteres(char* str)
{
  if(strlen(str)>30)
  {
      printf("\n Error.  El string tiene más de 30 caracteres\n");
     system("Pause");
     exit(1);
  }
}

int guardar_TS(char* tipo, char* nombre){
	
	char longi_str_cte[10];
	int i;
	int retornar;
	char lexema[50]; 
	lexema[0]='_';
	lexema[1]='\0';
	strcat(lexema,nombre);//Armamos el lexema agregandole el guion bajo al principio. 
	
	for(i = 0; i < puntero_array; i++){
		if(strcmp(tablaSimbolos[i].nombre, lexema) == 0){
	
			return i; //Si el lexema ya existe en la ts, entonces return su posicion.
		}
	}

                 if(strcmp(tipo,"CTE")==0)// Si el lexema es una constante, entonces tambien seteo el  campo "valor" en la ts.
	strcpy(tablaSimbolos[puntero_array].valor, nombre);
		else
			tablaSimbolos[puntero_array].valor[0]='\0';
		

	strcpy(tablaSimbolos[puntero_array].nombre, lexema ); //Se setea el campo "nombre" en la ts en todos los casos.

	tablaSimbolos[puntero_array].tipo[0]='\0';
	
		  if(tablaSimbolos[i].valor[0] == '\"')//Si se trata de una constante string, entonces contar las cantidad de caracteres y set en ts.
		  {
			  itoa(strlen(nombre),longi_str_cte,10);
			  strcpy(tablaSimbolos[i].longitud,longi_str_cte);
		  } else
	          tablaSimbolos[puntero_array].longitud[0]='\0';
	
	retornar = puntero_array;
	puntero_array++;
	
	return retornar; //Si el lexema no existe en la ts, entonces se agrega al final de la ts y se devuelve su posicion.
}

int escribir_TS(){
	FILE *pf; 
	int i;
	pf = fopen("ts.txt","w"); 

	if (!pf)
	{
		printf("Error al crear el archivo de tabla de simbolos\n");
		return 0;
	}

	fprintf(pf, "Nombre\t\t\tTipo\t\t\tValor\t\t\tLongitud\n");
	for (i = 0; i < puntero_array; i++)
		fprintf(pf,"%s\t\t\t%s\t\t\t%s\t\t\t%s\n", tablaSimbolos[i].nombre,tablaSimbolos[i].tipo,tablaSimbolos[i].valor,tablaSimbolos[i].longitud);
		
	
	fclose(pf); 

	return 1;
}

int yyerror(void)
{
       printf("Syntax Error error\n");
	 system ("Pause");
	 exit (1);
}




