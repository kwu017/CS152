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
     END = 263,
     L_PAREN = 264,
     R_PAREN = 265,
     L_SQUARE_BRACKET = 266,
     R_SQUARE_BRACKET = 267,
     GT = 268,
     GTE = 269,
     LT = 270,
     LTE = 271,
     EQ = 272,
     NEQ = 273,
     SEMICOLON = 274,
     COLON = 275,
     COMMA = 276,
     ASSIGN = 277,
     FUNCTION = 278,
     BEGIN_PARAMS = 279,
     END_PARAMS = 280,
     BEGIN_LOCALS = 281,
     END_LOCALS = 282,
     BEGIN_BODY = 283,
     END_BODY = 284,
     INTEGER = 285,
     ARRAY = 286,
     OF = 287,
     IF = 288,
     THEN = 289,
     ENDIF = 290,
     ELSE = 291,
     WHILE = 292,
     DO = 293,
     FOREACH = 294,
     IN = 295,
     BEGINLOOP = 296,
     ENDLOOP = 297,
     CONTINUE = 298,
     READ = 299,
     WRITE = 300,
     AND = 301,
     OR = 302,
     NOT = 303,
     TRUE = 304,
     FALSE = 305,
     RETURN = 306,
     NUMBER = 307,
     CHARACTER = 308,
     UMINUS = 309
   };
#endif
/* Tokens.  */
#define SUB 258
#define ADD 259
#define MULT 260
#define DIV 261
#define MOD 262
#define END 263
#define L_PAREN 264
#define R_PAREN 265
#define L_SQUARE_BRACKET 266
#define R_SQUARE_BRACKET 267
#define GT 268
#define GTE 269
#define LT 270
#define LTE 271
#define EQ 272
#define NEQ 273
#define SEMICOLON 274
#define COLON 275
#define COMMA 276
#define ASSIGN 277
#define FUNCTION 278
#define BEGIN_PARAMS 279
#define END_PARAMS 280
#define BEGIN_LOCALS 281
#define END_LOCALS 282
#define BEGIN_BODY 283
#define END_BODY 284
#define INTEGER 285
#define ARRAY 286
#define OF 287
#define IF 288
#define THEN 289
#define ENDIF 290
#define ELSE 291
#define WHILE 292
#define DO 293
#define FOREACH 294
#define IN 295
#define BEGINLOOP 296
#define ENDLOOP 297
#define CONTINUE 298
#define READ 299
#define WRITE 300
#define AND 301
#define OR 302
#define NOT 303
#define TRUE 304
#define FALSE 305
#define RETURN 306
#define NUMBER 307
#define CHARACTER 308
#define UMINUS 309




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 11 "mini_l.y"
{
  double dval;
  int ival;
  char* cval;
}
/* Line 1529 of yacc.c.  */
#line 163 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

