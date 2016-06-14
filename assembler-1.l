%{
	#include<stdio.h>
	#include<fcntl.h>
	#include<unistd.h>
	#include<stdlib.h>
	#include"y.tab.h"
	#include"data_structures.h"
	struct  tablemem a,b;
	int lineNum,strtF,incr,endF,symVal, val, disp,charval,l,i,j;
	char char_arr[10];
	char buff[50];
	char *ptr, *ptr1,*ptr2, *ptr3;
	extern FILE *datafile;
	int base=0, count=0, count1=0, count2=0;

%}
OPR ("ADDR"|"SUBR"|"DIVR"|"MULR"|"COMPR"|"RMO"|"CLEAR"|"TIXR")
REG ("A"|"B"|"X"|"PC"|"SW"|"S"|"T"|"F")
ARI("ADD"|"ADDF"|"AND"|"COMP"|"COMPF"|"DIV"|"DIVF"|"J"|"JEQ"|"JGT"|"JLT"|"JSUB"|"LDA"|"LDB"|"LDF"|"LDL"|"LDS"|"LDX"|"LPS"|"MUL"|"MULF"|"OR"|"RD"|"STA"|"STB"|"STL"|"STS"|"STSW"|"STT"|"STX"|"TD"|"TIX"|"WD"|"SUB")
TYPE1 ("FIX"|"FLOAT"|"HIO"|"NORM"|"SIO"|"TIO")
%%
[a-zA-Z]+[ ]+"START"[ ][0-9]+	{ 
					write(fileno(yyout),yytext[6],yyleng);
					ptr = strchr(yytext,' ');
					ptr1= strchr( ptr+1, ' ');
					LOCCTR= atoi(ptr1);
					STARTADDR =LOCCTR;
					PROG=LOCCTR;
					strncpy(progName,yytext,(ptr-yytext));
					fprintf(datafile,"H^");
					fprintf(datafile,"%6s",progName	);
					fprintf(datafile, "^%6ld^      ", STARTADDR);
					count2+=22;
					return STR;
				 }

"BYTE C""\'"[A-Za-z0-9]+"\'" { 			     	 
				if(count==0 || count==30 || count1==10 || (count+yyleng-8)>30)
				{
					fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
				        fprintf( datafile, "%2x", count);
					fseek ( datafile , (count*2+count1) , SEEK_CUR);						
					fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
					count=0;
					count1=0;
					count2+=12; 
				}
				fprintf(datafile, "^");count2++;
				for(i=7;i<yyleng-1;i++)
				{ fprintf(datafile,"%x",yytext[i]);
					LOCCTR++;count++; count2++;
				}
				PROG=LOCCTR;
				count1++;
				return BYTE;
				}


"BYTE X""\'"[0-9]+"\'" {              
				if(count==0 || count==30 || count1==10)
				{
			 		fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
					fprintf( datafile, "%2x", count);
			fseek(datafile, (count*2+count1),SEEK_CUR);									
					fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
					count=0;
					count1=0;
					count2+=12; 
				}
				fprintf(datafile, "^"); count2++;
				for(i=7;i<yyleng-1;i++){ fprintf(datafile,"%x",(yytext[i]-48));LOCCTR++;
					}
				PROG=LOCCTR;
				incr=yyleng-8;
				if(incr%2==0)
				{
					count+=incr/2;

					count2+=incr/2;
					
				}
				else { count+=incr/2 +1; 
					count2+=incr/2 +1;}
				count1++;
				return BYTE;
			}

{TYPE1} 		{ 			
				a=searchOpTab(yytext);		
				PROG++;
				val=0;
				val=a.symbdata.val;
                                if(count==0 || count==30 || count1==10)						
				{
					fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
					fprintf( datafile, "%2x", count);
				fseek ( datafile , (count*2+count1) , SEEK_CUR);							
					fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
					count=0;
					count1=0; 
				}
				count++;
				count1++;					
				fprintf(datafile, "^%x",val); 
				LOCCTR++;
				return TYPE;
			}
					

"+"{ARI}[ ][a-zA-Z]+ 	{  
				PROG+=4;                   	
				ptr = strchr(yytext,' ');
	                        for(i=1;yytext[i]!=32;i++)
					ptr1[i-1]=yytext[i];
				ptr1[i-1]='\0';
 			        if(count==0 || count==30 || count1==10|| count+4>30)
				{
					 fseek ( datafile , -(count*2+count1+2) , SEEK_CUR );
					 fprintf( datafile, "%2x", count);
					fseek ( datafile , (count*2+count1) , SEEK_CUR );				
					fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
					count=0;
					count1=0; 
				}
				a=searchOpTab(ptr1);
				val=0;	
				val=a.symbdata.val;
				ptr++;
           			if((symVal = searchSymTab(ptr))==-1)
           			{  
					insrtSymTab(ptr);
					return LB;
		                }
		                else
	        		{
			                 sprintf(char_arr,"%d",symVal);
			                 write(fileno(yyout),char_arr,strlen(char_arr));	               
					 disp = symVal; 		 
		  			 val= val & 0xFC;
					 val=val << 24;
		    			 val =val | 0x03100000 ;
			                 disp= disp & 0x000FFFFF;
		    			 val = val | disp;
		              	         fprintf( datafile, "^%x", val);
			         	            
				}
				LOCCTR +=4; 
				count+=4;
				count1++;
				return OPF;
			}

"+"{ARI}[ ]"#"[0-9]+ {  PROG+=4;
			ptr = strchr(yytext,'#');
                         for(i=1;yytext[i]!=32;i++)
				ptr1[i-1]=yytext[i];
				ptr1[i-1]='\0';
 			        if(count==0 || count==30 || count1==10 || count+4>30)
				{
					fseek ( datafile , -(count*2+count1+2) , SEEK_CUR );
					 fprintf( datafile, "%2x", count);
					fseek ( datafile , (count*2+count1) , SEEK_CUR );	
						fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
						count=0;
						count1=0; 
				}			
					a=searchOpTab(ptr1);
		val=0;	
		val=a.symbdata.val;
//		printf("%x\n",val);
		ptr++;
	//	printf("%s", ptr);
		/* if((symVal = searchSymTab(ptr))==-1)
                {insrtSymTab(ptr);
                 return LB;
                }
                else */
        		
                 sprintf(char_arr,"%d",symVal);
                 write(fileno(yyout),char_arr,strlen(char_arr));
                 symVal = atoi(ptr);
		   disp=symVal; 		 
		   val=val & 0xFC;
		    val=val << 24;
		    val =val | 0x01100000 ;
                     disp= disp & 0x000FFFFF;
		    val = val | disp;
			fprintf( datafile, "^%08x", val);
		LOCCTR +=4;             
		                        count+=4;
			count1++;
		
		  return OPF;
		}	
				
"RESW "[0-9]+  { write(fileno(yyout),yytext,yyleng);
				ptr=strchr(yytext, ' ');
				ptr++;
               LOCCTR += 3*(atoi(ptr));
		PROG+=3*(atoi(ptr));
			//printf("%ld", LOCCTR);
		return RES;
		}
{REG} { incr=searchRegTab(yytext);
	fprintf(datafile,"%x", incr); 
	return REG; }


{OPR}[ ]{REG}","{REG} {
          
         	ptr=strchr(yytext,' ');
		  
     for(i=0;yytext[i]!=32;i++)
				ptr1[i]=yytext[i];
				ptr1[i]='\0';
		
     a=searchOpTab(ptr1);
	
	PROG+=a.symbdata.type;
	if(count==0 || count==30 || count1==10 || count+2>30)
	{
 				
				fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
				 fprintf( datafile, "%2x", count);
				fseek ( datafile , (count*2+count1) , SEEK_CUR);						
		fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
		count=0;
		count1=0; 
	}
	fprintf(datafile, "^%x", a.symbdata.val);
	LOCCTR+=a.symbdata.type;
	ptr++;
    for(i=0;ptr[i]!=44;i++)
		ptr1[i]=ptr[i];
		ptr1[i]='\0';
i++;
   incr=searchRegTab(ptr1);
	fprintf(datafile,"%x", incr);
     for(j=0;ptr[i]!='\0';i++, j++)
		ptr1[j]=ptr[i];
		ptr1[j]='\0';
		//printf("%s", ptr1);
    incr=searchRegTab(ptr1);
	fprintf(datafile,"%x", incr);
	
	//printf("%ld", LOCCTR);
	      count+=2; count1++;
		return OPR; }





{ARI}[ ][a-zA-Z] { 
			ptr1=strchr(yytext, ' ');
			for(i=0;yytext[i]!=32;i++)
				ptr[i]=yytext[i];
			ptr[i]='\0';
  			a=searchOpTab(ptr);
			PROG+=a.symbdata.type;

			val=a.symbdata.val;
			ptr1++;
			if((symVal = searchSymTab(ptr1))==-1)
                	{ 
				insrtSymTab1(ptr1, -1);
				insert_symbol(ptr1,PROG,  count2);
				val= val & 0xFC;
		    val=val << 16;
		    val =val | 0x032000 ;
			if(count==0 || count==30 || count1==10 || count+3>30)
			{
			fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
				 fprintf( datafile, "%2x", count);
				fseek ( datafile , (count*2+count1) , SEEK_CUR);				
		fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
		count=0;
		count1=0; 
	}		
		count2+=7; count+=3; count1++; 
		    fprintf( datafile, "^%06x", val);
		LOCCTR +=a.symbdata.type;    
                 return TY;
                }
                else
                {
                disp=0;
		sprintf(char_arr,"%d",symVal);
                 write(fileno(yyout),char_arr,strlen(char_arr));
                 disp=symVal-PROG;
		 if(disp>=-2048 && disp<2047)
		 {
		   val= val & 0xFC;
		    val=val << 16;
		    val =val | 0x032000 ;
             disp= disp & 0x00000FFF;
		    val = val | disp;

                  }
		else if( (disp=symVal-base)<4096)
		{
			 val= val & 0xFC;
		    val=val << 16;
		    val =val | 0x034000 ;
                     disp= disp & 0x000FFF;
		    val = val | disp;
		}
		else
		{ printf("error\n");
		  exit(0);
		}	
			if(count==0 || count==30 || count1==10 || count+3>30)
			{
			fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
				 fprintf( datafile, "%2x", count);
				fseek ( datafile , (count*2+count1) , SEEK_CUR);				
		fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
		count=0;
		count1=0; 
	}		
		count+=3; count1++; 
		    fprintf( datafile, "^%06x", val);
		LOCCTR +=a.symbdata.type;

                // return SLB;
              }  
	return TY;
       }
	
	

"RESB "[0-9]+ {write(fileno(yyout),yytext,yyleng);
				ptr=strchr(yytext, ' ');
				ptr++;
               LOCCTR += (atoi(ptr));
		PROG+=(atoi(ptr));
              		return RES; }


"END" {
			 		fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
					fprintf( datafile, "%2x", count);
			fseek(datafile, (count*2+count1),SEEK_CUR);	
	 write(fileno(yyout),yytext,yyleng);
           progLength = LOCCTR-STARTADDR;
           //fprintf(datafile,"\n%ld",progLength);
          //fprintf(datafile,"%d",symbIndex);
//fwrite(&symbtab,sizeof(tabletype),symbIndex,datafile);
dispSymTab();
printf("The program size is :\t %ld\n",progLength);
fprintf(datafile, "\nE^%ld\n", STARTADDR);
fseek( datafile, 16, SEEK_SET);
fprintf(datafile, "%6ld", progLength);
fseek(datafile, 0, SEEK_END);
return END;   } 



"#"[0-9]+ {
		
		disp=atoi(yytext+1);
		 if(disp<4096)
		 {
		   val= val & 0xFC;
		    val=val << 16;
		    val =val | 0x010000 ;
             disp= disp & 0x00000FFF;
		    val = val | disp;

                  }
			if(count==0 || count==30 || count1==10 || count+3>30)
	{			
			 fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
				 fprintf( datafile, "%2x", count);
				fseek ( datafile , (count*2+count1) , SEEK_CUR);						
		fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
		count=0;
		count1=0; 
	}
		    fprintf( datafile, "^%06x", val);
		LOCCTR +=a.symbdata.type;
		count+=3;
		count1++;
		return IM;
		}

[a-zA-Z]+ {
		b=searchOpTab(yytext);
	//if( b == -1){
              if((symVal = searchSymTab(yytext))==-1)
                { insrtSymTab(yytext);
                 return LB;
                }
                else
                {
                disp=0;
		sprintf(char_arr,"%d",symVal);
                 write(fileno(yyout),char_arr,strlen(char_arr));
                 disp=symVal-PROG;
		 if(disp>=-2048 && disp<2047)
		 {
		   val= val & 0xFC;
		    val=val << 16;
		    val =val | 0x032000 ;
             disp= disp & 0x00000FFF;
		    val = val | disp;

                  }
		else if( (disp=symVal-base)<4096)
		{
			 val= val & 0xFC;
		    val=val << 16;
		    val =val | 0x034000 ;
                     disp= disp & 0x000FFF;
		    val = val | disp;
		}
		else
		{ printf("error\n");
		  exit(0);
		}	
			/*if(count==0 || count==30 || count1==10 || count+3>30)
			{
			fseek ( datafile , -((count*2)+count1+2) , SEEK_CUR );
				 fprintf( datafile, "%2x", count);
				fseek ( datafile , (count*2+count1) , SEEK_CUR);				
		fprintf(datafile, "\nT^%06ld^  ", LOCCTR);
		count=0;
		count1=0; 
	}*/		
		count+=3; count1++; 
		    fprintf( datafile, "^%06x", val);
		LOCCTR +=a.symbdata.type;

                 return SLB;
              }  
               //}
              //else
              //{
                // write(fileno(yyout),yytext,yyleng);
                 //LOCCTR += b.symbdata.type; return OP;
             // } 
              }
[ ] return WS;
\n { return NL;}
%%
int yywrap()
{
  return 1;
}
/*	int mod (int count, int divisor)
	{
		if((count % divisor)==0)
		  return 1;
		else return 0;
	}*/
/*{OPR}[ ]{REG} {
		ptr=strchr(yytext,' ');
		  count+=2;
		count1++;
     for(i=0;yytext[i]!=32;i++)
				ptr1[i]=yytext[i];
				ptr1[i]='\0';
		
     a=searchOpTab(ptr1);
	
	PROG+=a.symbdata.type;
	fprintf(datafile, "^%x", a.symbdata.val);
	LOCCTR+=a.symbdata.type;
	ptr++;
    for(i=0;ptr[i]!='\0';i++)
		ptr1[i]=ptr[i];
		ptr1[i]='\0';
		i++;
     incr=searchRegTab(ptr1);
	fprintf(datafile,"%x", incr);
	fprintf(datafile, "0" );
       return OPR1;
}*/
