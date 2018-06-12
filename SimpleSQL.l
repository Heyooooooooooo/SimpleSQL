%{
/****************************************************************************
mylexer.l
ParserWizard generated Lex file.

Date: 2018年4月23日
****************************************************************************/

#include "myparser.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
%}

/////////////////////////////////////////////////////////////////////////////
// declarations section
//实现大小写不敏感
CREATE			  [Cc][Rr][Ee][Aa][Tt][Ee]
USE			  [Uu][Ss][Ee]
SHOW			  [Ss][Hh][Oo][Ww]
INSERT			  [Ii][Nn][Ss][Ee][Rr][Tt]
SELECT			  [Ss][Ee][Ll][Ee][Cc][Tt]
UPDATE			  [Uu][Pp][Dd][Aa][Tt][Ee]
SET			  [Ss][Ee][Tt]
DELETE			  [Dd][Ee][Ll][Ee][Tt][Ee]
DROP			  [Dd][Rr][Oo][Pp]
AND			  [Aa][Nn][Dd]
WHERE			  [Ww][Hh][Ee][Rr][Ee]
OR			  [Oo][Rr]
FROM			  [Ff][Rr][Oo][Mm]
INTO		 	  [Ii][Nn][Tt][Oo]
VALUES			  [Vv][Aa][Ll][Uu][Ee][Ss]
EXIT			  [Ee][Xx][Ii][Tt]
DATABASE		  [Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]
DATABASES		  [Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee][Ss]
TABLE			  [Tt][Aa][Bb][Ll][Ee]
TABLES			  [Tt][Aa][Bb][Ll][Ee][Ss]
CHAR			  [Cc][Hh][Aa][Rr]
INT			  [Ii][Nn][Tt]
ID     	  		  [A-Za-z][A-Za-z0-9_]*
digit			  [0-9]
digits			  {digit}+
optional_fraction	  ("."{digits})?
optional_exponent	  (E[+-]?{digits})?

// place any declarations here

%%

/////////////////////////////////////////////////////////////////////////////
// rules section
[ ]+ ;//过滤空格
{CREATE}	    {return CREATE;}
{USE}		    {return USE;}
{SHOW}	  	    {return SHOW;}
{INSERT}  	    {return INSERT;}
{SELECT}	    {return SELECT;}
{UPDATE}	    {return UPDATE;}
{SET}		    {return SET;}
{DELETE}   	    {return DELETE;}
{DROP}	  	    {return DROP;}
{INTO}		    {return INTO;}
{VALUES}	    {return VALUES;}
{FROM}		    {return FROM;}
{WHERE}		    {return WHERE;}
{AND}	    	    {return AND;}
{OR}	    	    {return OR;}
{EXIT}		    {return EXIT;}
{TABLE}		    {return TABLE;}
{TABLES}	    {return TABLES;}
{DATABASE}	    {return DATABASE;}
{DATABASES}         {return DATABASES;}
{CHAR}		    {return CHAR;}
{INT}		    {return INT;}
{ID} {
	yylval.yych=(char *)malloc(strlen(yytext)+1); 
	strcpy(yylval.yych, yytext);
	return ID;
}
{digits}{optional_fraction}{optional_exponent} {
	yylval.yych=(char *)malloc(strlen(yytext)+1); 
	strcpy(yylval.yych, yytext);
	return NUMBER;
}
";"		{return ';';}
"("		{return '(';}
")"		{return ')';}
","		{return ',';}
"."		{return '.';}
"!"		{return '!';}
"="		{return '=';}
"<"		{return '<';}
">"		{return '>';}
"'"		{return QUOTE;}
"+"		{return '+';}
"-"		{return '-';}
"*"		{return '*';}
"/"		{return '/';}
"\n"	{return 0;}
// place your Lex rules here

%%
