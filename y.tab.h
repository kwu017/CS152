/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SUB = 258,
     ADD = 259,
     MULT = 260,
     DIV = 261,
     MOD = 262,
     L_PAREN = 263,
     R_PAREN = 264,
     L_SQUARE_BRACKET = 265,
     R_SQUARE_BRACKET = 266,
     GT = 267,
     GTE = 268,
     LT = 269,
     LTE = 270,
     EQ = 271,
     NEQ = 272,
     SEMICOLON = 273,
     COLON = 274,
     COMMA = 275,
     ASSIGN = 276,
     FUNCTION = 277,
     BEGIN_PARAMS = 278,
     END_PARAMS = 279,
     BEGIN_LOCALS = 280,
     END_LOCALS = 281,
     BEGIN_BODY = 282,
     END_BODY = 283,
     INTEGER = 284,
     ARRAY = 285,
     OF = 286,
     IF = 287,
     THEN = 288,
     ENDIF = 289,
     ELSE = 290,
     WHILE = 291,
     DO = 292,
     FOREACH = 293,
     IN = 294,
     BEGINLOOP = 295,
     ENDLOOP = 296,
     CONTINUE = 297,
     READ = 298,
     WRITE = 299,
     AND = 300,
     OR = 301,
     NOT = 302,
     TRUE = 303,
     FALSE = 304,
     RETURN = 305,
     NUMBER = 306,
     CHARACTER = 307,
     UMINUS = 308
   };
#endif
/* Tokens.  */
#define SUB 258
#define ADD 259
#define MULT 260
#define DIV 261
#define MOD 262
#define L_PAREN 263
#define R_PAREN 264
#define L_SQUARE_BRACKET 265
#define R_SQUARE_BRACKET 266
#define GT 267
#define GTE 268
#define LT 269
#define LTE 270
#define EQ 271
#define NEQ 272
#define SEMICOLON 273
#define COLON 274
#define COMMA 275
#define ASSIGN 276
#define FUNCTION 277
#define BEGIN_PARAMS 278
#define END_PARAMS 279
#define BEGIN_LOCALS 280
#define END_LOCALS 281
#define BEGIN_BODY 282
#define END_BODY 283
#define INTEGER 284
#define ARRAY 285
#define OF 286
#define IF 287
#define THEN 288
#define ENDIF 289
#define ELSE 290
#define WHILE 291
#define DO 292
#define FOREACH 293
#define IN 294
#define BEGINLOOP 295
#define ENDLOOP 296
#define CONTINUE 297
#define READ 298
#define WRITE 299
#define AND 300
#define OR 301
#define NOT 302
#define TRUE 303
#define FALSE 304
#define RETURN 305
#define NUMBER 306
#define CHARACTER 307
#define UMINUS 308




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 11 "mini_l.y"
{
  double dval;
  int ival;
  char* cval;
}
/* Line 1529 of yacc.c.  */
#line 161 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

