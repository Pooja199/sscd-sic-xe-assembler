# sscd-sic-xe-assembler
Implementation of single pass assembler for SIC/XE

Instructions for execution

$ lex Assembler.l
$ yacc -d Assembler.y
$ cc lex.yy.c y.tab.c -o run
$ ./a.out
