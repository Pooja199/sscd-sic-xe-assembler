#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define SYMBSIZE 10
#define SYMBLIMIT 200

int noOfInstructions = 0;
long int LOCCTR=0;
long int PROG=0;
long int STARTADDR;
long int progLength;
char progName[15];
/*==========================================OPTAB==============================================================*/
typedef struct tabinfo{
	int val;
	
	int info;
int type;
} tabdata;

struct tablemem{
	char *symbol;//CHANGED	
	tabdata symbdata;
};








/*=========================================FORWARD REFERENCES==================================================*/

struct symbol
{
//	int noOfLinks;
//	int used;
	char label[25];
	int prog;
	int count;
	struct symbol *link;
};

typedef struct symbol Symbol;

Symbol *head = NULL;
Symbol *search_symbol(char label[])
{
	if(head == NULL)
  		return NULL;
  
	Symbol *cur = head;
	while(cur&&strcmp(cur->label,label)!=0)
   		cur=cur->link;
  	
  	return cur;
}

void insert_symbol(char label[],int prog, int count)
{
	Symbol *temp;
  	temp=(Symbol *)malloc(sizeof(Symbol));
  	strcpy(temp->label,label);
  	temp->prog=prog;
  	//temp->noOfLinks = 0;
  	temp->link=head;
  	temp->count = count;
  	head = temp;
}




/*========================================OPTABLE======================================*/
struct tablemem opcodetab[] = {
	{"ADD"   ,0X18, 0, 3}, {"ADDR"  ,0X90, 0, 2}, {"AND"   ,0X40, 0, 3}, 
{"BASE"  ,0   ,20, 0}, {"BYTE"  ,0   , 1, 0}, 
{"CLEAR" ,0XB4, 0, 2}, {"COMP"  ,0X28, 0, 3}, {"COMPR" ,0XA0, 0, 2}, 
{"CSECT" ,0   ,50, 0},
{"DIV "   ,0X24, 0, 3}, {"DIVR"  ,0X9C, 0, 2},
{"END"   ,0   ,11, 0},
{"EQU"   ,0   ,80, 0}, {"EXTDEF",0   ,40, 0}, {"EXTREF",0   ,41, 0}, {"FIX", 0xC4, 0, 1},{"FLOAT", 0XC0, 0,1}, {"HIO", 0XF4, 0, 1},
{"J"     ,0X3C, 0, 3}, {"JEQ"   ,0X30, 0, 3}, {"JGT"   ,0X34, 0, 3},
{"JLT"   ,0X38, 0, 3}, {"JSUB"  ,0X48, 0, 3}, {"LDA"   ,0X00, 0, 3},
{"LDB"   ,0X68, 0, 3}, 
{"LDCH"  ,0X50, 0, 3}, {"LDL"   ,0X08, 0, 3},
{"LDS"   ,0X6C, 0, 3}, {"LDT"   ,0X74, 0, 3}, {"LDX"   ,0X04, 0, 3}, 
{"LTORG" ,0   ,30, 0}, 
{"MUL "   ,0X20, 0, 3}, {"MULR"  ,0X98, 0, 2}, 
{"NOBASE",0   ,21, 0}, {"NOP"   ,0   ,70, 0}, {"NORM", 0XC8, 0,1},
{"OR"    ,0X44, 0, 3},
{"ORG"   ,0   ,61, 0}, 
{"RD"    ,0XD8, 0, 3}, 
{"RESB"  ,0   , 2, 1}, {"RESW"  ,0   , 3, 3}, 
{"RMO"   ,0XAC, 0, 2}, {"RSUB"  ,0X4C, 0, 3}, 
{"SHIFTL",0XA4, 0, 2}, {"SHIFTR",0XA8, 0, 2}, {"SIO", 0XF0, 0, 1}, {"STA"   ,0X0C, 0, 3},
{"STB"   ,0X78, 0, 3}, {"STCH"  ,0X54, 0, 3}, {"STL"   ,0X14, 0, 3},
{"STS"   ,0X7C, 0, 3}, {"STT"   ,0X84, 0, 3}, {"STX"   ,0X10, 0, 3}, 
{"SUB"   ,0X1C, 0, 3}, {"SUBR"  ,0X94, 0, 2}, {"TD"    ,0XE0, 0, 3},{"TIO", 0XF8, 0, 1},
{"TIX"   ,0X2C, 0, 3}, {"TIXR"  ,0XB8, 0, 2}, 
{"USE"   ,0   ,60, 0}, 
{"WD"    ,0XDC, 0, 3}, 
{"WORD"  ,0   , 4, 3},
};

struct reg{
	char *symbol;	
	int val;
};
struct reg regtab[] = {
{"A", 0}, {"X", 1}, {"L", 1},
{"PC", 8}, {"SW", 9}, {"B", 3},
{"S", 4}, {"T", 5},{"F", 6}
};

int optabsize = sizeof(opcodetab)/sizeof(struct tablemem);

struct tablemem searchOpTab(char s[]){
int i;
struct tablemem a;
	for(i=0;i<62;i++){

		if(strcmp(s,opcodetab[i].symbol)==0)
			//return opcodetab[i].symbdata.info;
			return opcodetab[i];
	}
	
	return a;

}


int searchRegTab(char s[]){
int i;
	for(i=0;i<9;i++){

		if(strcmp(s,regtab[i].symbol)==0)
			//return opcodetab[i].symbdata.info;
			return regtab[i].val;
	}
	
	return -1;

}
/*=====================================SYMBTAB==========================================================*/
typedef struct{
	char symbol[SYMBSIZE];
	int value;
	//int casenmbr;
	//int otherinfo;
} tabletype;

tabletype symbtab[SYMBLIMIT];
static int symbIndex=0;
int searchSymTab(char s[]){
int i;
	for(i=0;i<symbIndex;i++)
		if(strcmp(symbtab[i].symbol,s)==0)
			return symbtab[i].value;

	return -1;

}
void insrtSymTab(char *s){

	strcpy(symbtab[symbIndex].symbol,s);
	symbtab[symbIndex].value = LOCCTR;
	symbIndex++;	

}

void insrtSymTab1(char *s, int x){

	strcpy(symbtab[symbIndex].symbol,s);
	symbtab[symbIndex].value = x;
	symbIndex++;	

}
void dispSymTab(){
int i;
	printf("The symbol table is:\n");
	for(i=0;i<symbIndex;i++)
		printf("%s %d\n",symbtab[i].symbol,symbtab[i].value);

}


