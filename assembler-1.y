%{
	#include<stdio.h>
        #include<stdlib.h>
	extern int yylex();
	extern FILE *yyin;
	extern FILE *yyout;
	FILE *datafile;
%}
%token LB STR RES NUM WS NL OP END SLB REG OPR OPI BYTE OPF TYPE IM OPR1 TY
%%
STMT:  X  	{printf("\n\nValid\n\n");}
	    ;
S : STR 
    |
    ;
B : LB WS OP WS LB
 | LB WS OP WS NUM
 | OP
 | LB TYPE
 | SLB TYPE
 | TYPE 
 | OPR
 | SLB OPR
 | LB OPR
 | LB WS RES
 | SLB WS RES
 | OPR1 
 | TY
 | LB WS OPI WS SLB
 | SLB WS OPI WS SLB
 
 | LB WS OPI WS IM 
 | SLB WS OPI WS IM
 | OPI WS IM
 | SLB WS OPF
 | LB WS OPF
 | OPF
 | OPI WS SLB
 | OP WS LB
 | OP WS NUM
 | LB WS OP WS SLB
 | OP WS SLB
 | END WS LB
 | END
 | END WS SLB
 | LB WS BYTE
 | SLB WS BYTE
 | 
 ;
X: S NL X
 | B NL X
 
 | 
;
%%



int main(){
FILE *myfile = fopen("in.txt","r");
FILE *outfile = fopen("out.txt","w");
datafile = fopen("data.dat","w");
yyin = myfile;
yyout = outfile;
yyparse();
}
int yyerror(){
printf("error.\n");
}
