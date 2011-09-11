%{
#include "config.h"
#include "system.h"
#include "ansidecl.h"
#include "coretypes.h"
#include "opts.h"
#include "tree.h"
#include "gimple.h"
#include "tree-iterator.h"
#include "tree-pass.h"
#include "toplev.h"
#include "debug.h"
#include "options.h"
#include "flags.h"
#include "convert.h"
#include "diagnostic-core.h"
#include "langhooks.h"
#include "langhooks-def.h"
#include "target.h"
#include "cgraph.h"

#include <gmp.h>
#include <mpfr.h>

#include "vec.h"
#include "hashtab.h"

#include "js-lang.h"
#include "js-op.h"

#define TODO() error("TODO");
extern int js_lex (void);
int js_error(const char *str);
%}

%union
{
  VEC(tree,gc) * vec;
  tree token;
  JSOperator op;
}

%error-verbose
//%start declaration
%debug

/* Locations will be added later to add debugging information */
%locations


%start Program
%token CAMMA
%token COLON
%token SEMICOLON
%token LBRACE RBRACE   /* { } */
%token LCBRACE RCBRACE /* ( ) */
%token LPARENTHESIS RPARENTHESIS /* [ ] */
%token Var
%token If Else 
%token Do While 
%token For 
%token In 
%token Switch Case Break Default 
%token Delete
%token Continue
%token Function Return 
%token This
%token Try CATCH FINALLY Throw 
%token Typeof Instanceof
%token With 
%token New
%token Void
%token Debugger
%token T_NULL T_TRUE T_FALSE
%token IdentifierName
%token HexIntegerLiteral IntegerLiteral FloatLiteral StringLiteral RegexLiteral
%token PLUSPLUS MINUSMINUS
%token EQ_LET                   /* = */
%token MUL_LET DIV_LET REM_LET  /* *= /= %= */
%token ADD_LET SUB_LET          /* += -= */
%token LSHIFT_LET RSHIFT_LET    /* <<= >>= */
%token SHIFT_LET                /* >>>= */
%token AND_LET OR_LET XOR_LET   /* &= |= ^=*/
%token DOT QUESTION             /* . ? */
%token AND AND2 OR OR2 XOR      /* & && | || ^ */
%token ADD SUB MUL DIV REM      /* + - * / % */
%token INV NOT LT LTE GT GTE    /* ~ ! < <= > >= */
%token LSHIFT RSHIFT SHIFT      /* << >> >>> */
%token EQEQ NEQ STREQ STRNEQ    /* == != === !== */

%nonassoc IF_WITHOUT_ELSE
%nonassoc ELSE

%type <token> Statement StatementList Program SourceElement SourceElements
%type <token> Literal ArrayLiteral
%type <token> Expression VariableStatement
%type <token> AssignmentExpression AssignmentExpressionNoIn
%type <token> VariableDeclaration VariableDeclarationNoIn
%type <token> Initialiser InitialiserNoIn
%type <token> VariableDeclarationList VariableDeclarationListNoIn
%type <token> IterationStatement ReturnStatement
%type <token> ContinueStatement BreakStatement
%type <token> WithStatement LabelledStatement SwitchStatement
%type <token> ThrowStatement TryStatement DebuggerStatement
%type <token> FunctionDeclaration FunctionBody

%type <token> ExpressionNoInopt Expressionopt
%type <token> AdditiveExpression MultiplicativeExpression
%type <token> LeftHandSideExpression Block NewExpression
%type <token> PrimaryExpression IfStatement
%type <token> NullLiteral BooleanLiteral NumericLiteral
%type <token> IntegerLiteral HexIntegerLiteral
%type <token> StringLiteral  FloatLiteral Identifier
%type <token> CallExpression MemberExpression FunctionExpression 
%type <token> PostfixExpression ExpressionStatement
%type <token> UnaryExpression ShiftExpression
%type <token> RelationalExpression RelationalExpressionNoIn
%type <token> EqualityExpression EqualityExpressionNoIn
%type <token> BitwiseANDExpression BitwiseANDExpressionNoIn
%type <token> BitwiseORExpression BitwiseORExpressionNoIn
%type <token> BitwiseXORExpression BitwiseXORExpressionNoIn

%type <token> IdentifierName

%type <vec> ArgumentList Arguments
%type <vec> FormalParameterListopt FormalParameterList
%type <vec> ElementList
%type <op> AssignmentOperator

%%
Literal 
    : NullLiteral
    | BooleanLiteral
    | NumericLiteral
    | StringLiteral
    | RegexLiteral
    ;

NullLiteral 
    : T_NULL {}
    ;

BooleanLiteral 
    : T_TRUE  {}
    | T_FALSE {}
    ;

/* DecimalLiteral */
NumericLiteral 
    : IntegerLiteral
    | FloatLiteral 
    | HexIntegerLiteral;

Expression 
    : AssignmentExpression 
    | Expression CAMMA AssignmentExpression ;

Expressionopt
    : {}
    | Expression {}
    ;

ExpressionNoIn
    : AssignmentExpressionNoIn
    | ExpressionNoIn CAMMA AssignmentExpressionNoIn
    ;

ExpressionNoInopt
    : {}
    | ExpressionNoIn {}
    ;

Statement
    : Block
    | VariableStatement
    | EmptyStatement {}
    | ExpressionStatement
    | IfStatement
    | IterationStatement
    | ContinueStatement
    | BreakStatement
    | ReturnStatement 
    | WithStatement
    | LabelledStatement
    | SwitchStatement
    | ThrowStatement
    | TryStatement
    | DebuggerStatement
    ;

Block 
    : LBRACE RBRACE {
        //$$ = poplevel(js__block_level+1, NULL_TREE);
    }
    | LBRACE StatementList RBRACE {
        //$$ = poplevel(js__block_level+1, $2);
    }
    ;

StatementList 
    : Statement {
        //$$ = APPEND_STMTLIST($1, (alloc_stmt_list()));
    }
    | StatementList Statement {
        //$$ = APPEND_STMTLIST($2, ($1));
    }
    ;

VariableStatement 
    : Var VariableDeclarationList SEMICOLON {
        //$$ = $2;
    }
    ;

VariableDeclarationList 
    : VariableDeclaration {
        //$$ = APPEND_STMTLIST($1, (alloc_stmt_list()));
    }
    | VariableDeclarationList CAMMA VariableDeclaration {
        //$$ = APPEND_STMTLIST($3, ($1));
    }
    ;

VariableDeclaration 
    : Identifier {
        //$$ = js_build_let_expr(OpEQLET, $1, js_get_default_value(TREE_TYPE($1)));
    }
    | Identifier Initialiser {
        //$$ = js_build_let_expr(OpEQLET, $1, $2);
    }
    ;

VariableDeclarationListNoIn 
    : VariableDeclarationNoIn {
        //$$ = APPEND_STMTLIST($1, (alloc_stmt_list()));
    }
    | VariableDeclarationListNoIn CAMMA VariableDeclarationNoIn {
        //$$ = APPEND_STMTLIST($3, ($1));
    }
    ;

VariableDeclarationNoIn
    : Identifier {
        //$$ = js_build_let_expr(OpEQLET, $1, js_get_default_value(TREE_TYPE($1)));
    }
    | Identifier InitialiserNoIn {
        //$$ = js_build_let_expr(OpEQLET, $1, $2);
    }
    ;

Initialiser 
    : EQ_LET AssignmentExpression {
        //$$ = $2;
    }
    ;

InitialiserNoIn 
    : EQ_LET AssignmentExpressionNoIn {
        //$$ = $2;
    }
    ;

AssignmentExpression 
    : ConditionalExpression {}
    | LeftHandSideExpression AssignmentOperator AssignmentExpression {
        //$$ = js_build_let_expr($2, $1, $3);
    }
    ;

AssignmentExpressionNoIn
    : ConditionalExpressionNoIn {}
    | LeftHandSideExpression AssignmentOperator AssignmentExpressionNoIn {
        //$$ = js_build_let_expr($2, $1, $3);
    }
    ;

AssignmentOperator
    : EQ_LET     /*    = */ { $$ = OpEQLET; }
    | MUL_LET    /*   *= */ { $$ = OpMULLET; }
    | DIV_LET    /*   /= */ { $$ = OpDIVLET; }
    | REM_LET    /*   %= */ { $$ = OpMODLET; }
    | ADD_LET    /*   += */ { $$ = OpADDLET; }
    | SUB_LET    /*   -= */ { $$ = OpSUBLET; }
    | LSHIFT_LET /*  <<= */ { $$ = OpLSFTLET; }
    | RSHIFT_LET /*  >>= */ { $$ = OpRSFTLET; }
    | SHIFT_LET  /* >>>= */ { $$ = OpSHFTLET; }
    | AND_LET    /*   &= */ { $$ = OpANDLET; }
    | XOR_LET    /*   ^= */ { $$ = OpXORLET; }
    | OR_LET     /*   |= */ { $$ = OpORLET; }
    ;

ConditionalExpression 
    : LogicalORExpression
    | LogicalORExpression QUESTION AssignmentExpression COLON AssignmentExpression
    ;

ConditionalExpressionNoIn 
    : LogicalORExpressionNoIn
    | LogicalORExpressionNoIn QUESTION AssignmentExpressionNoIn COLON AssignmentExpressionNoIn
    ;

EmptyStatement 
    : SEMICOLON {}
    ;

ExpressionStatement 
    : Expression SEMICOLON 
    ;

IfStatement 
    : If LCBRACE Expression RCBRACE Statement %prec IF_WITHOUT_ELSE {
        debug("IfStatement1");
        //$$ = js_build_if_expr($3, $5, NULL_TREE);
    }
    | If LCBRACE Expression RCBRACE Statement Else Statement {
        debug("IfStatement2");
        //$$ = js_build_if_expr($3, $5, $7);
    }
;

IterationStatement
    : Do Statement While LCBRACE Expression RCBRACE SEMICOLON {
        /*debug("While1");*/
        //$$ = js_build_while_expr($5, $2, true/*isDoWhile*/);
    }
    | While LCBRACE Expression RCBRACE Statement {
        /*debug("While2");*/
        //$$ = js_build_while_expr($3, $5, false);
    }
    | For LCBRACE ExpressionNoInopt SEMICOLON Expressionopt SEMICOLON Expressionopt RCBRACE Statement {
        /*debug("for1");*/
        //$$ = js_build_for_expr($3/*init*/ , $5/*cond*/, $7/*inc*/, $9/*body*/);
    }

    | For LCBRACE Var VariableDeclarationListNoIn SEMICOLON Expressionopt SEMICOLON Expressionopt RCBRACE Statement {
        /*debug("for2");*/
        //$$ = js_build_for_expr($4/*init*/ , $6/*cond*/, $8/*inc*/, $10/*body*/);
    }

    | For LCBRACE LeftHandSideExpression In Expression RCBRACE Statement {
        TODO();
    }
    | For LCBRACE Var VariableDeclarationNoIn In Expression RCBRACE Statement {
        TODO();
    }
;

ContinueStatement 
    : Continue SEMICOLON {
        TODO();
    }
    | Continue Identifier SEMICOLON {
        TODO();
    }
;

BreakStatement 
    : Break SEMICOLON {
        TODO();
    }
    | Break Identifier SEMICOLON {
        TODO();
    }
;

ReturnStatement 
    : Return SEMICOLON {
        //$$ = js_build_return_stmt(NULL_TREE);
    }
    | Return Expression SEMICOLON {
        //$$ = js_build_return_stmt($2);
    }
;

WithStatement 
    : With LCBRACE Expression RCBRACE Statement {
        TODO();
    }
;

SwitchStatement 
    : Switch LCBRACE Expression RCBRACE CaseBlock {
        TODO();
    }
;

CaseBlock 
    : LBRACE CaseClausesopt RBRACE {
        TODO();
    }
    | LBRACE CaseClausesopt DefaultClause CaseClausesopt RBRACE {
        TODO();
    }
    ;

CaseClausesopt 
    :
    | CaseClause
;

CaseClause 
    : Case Expression COLON 
    | Case Expression COLON StatementList
;

DefaultClause
    : Default COLON
    | Default COLON StatementList
;

LabelledStatement 
    : Identifier COLON Statement
    ;

ThrowStatement 
    : Throw Expression {
        //$$ = js_build_throw_expr($2);
    }
    ;

TryStatement 
    : Try Block Catch {
        TODO();
    }
    | Try Block Finally {
        TODO();
    }
    | Try Block Catch Finally {
        TODO();
    }
    ;

Catch
    : CATCH LCBRACE Identifier RCBRACE Block
    ;

Finally
    : FINALLY Block
    ;

DebuggerStatement 
    : Debugger SEMICOLON {
        TODO();
    }
    ;

Program 
    : /* not in spec */ {}
    | SourceElements {
        //write_global_script($1);
        //$$ = NULL_TREE;
    }
;

FunctionDeclaration
    : Function Identifier LCBRACE FormalParameterListopt RCBRACE LBRACE FunctionBody RBRACE {
        debug("FunctionDeclaration");
        //js_build_function_decl($2, $7, true);
        //$$ = NULL_TREE;
    }
    ;

FunctionExpression
    :Function LCBRACE FormalParameterListopt RCBRACE LBRACE FunctionBody RBRACE {
        debug("FunctionExpression1");
        //$$ = js_build_function_object(NULL_TREE, $6);
    }
    |Function Identifier LCBRACE FormalParameterListopt RCBRACE LBRACE FunctionBody RBRACE {
        debug("FunctionExpression2");
        //$$ = js_build_function_object($2, $7);
    }
    ;

FormalParameterListopt
    : {
        //js_append_to_current_args(NULL_TREE, js__block_level);
    }
    | FormalParameterList
    ;

FormalParameterList
    : Identifier {
        //js_append_to_current_args($1, js__block_level);
    }
    | FormalParameterList CAMMA Identifier {
        //js_append_to_current_args($3, js__block_level);
    }

FunctionBody 
    : {
        debug("FunctionBody1");
        //$$ = alloc_stmt_list();
    }
    |SourceElements {
        debug("FunctionBody2");
    }
    ;

SourceElements
    : SourceElement {
        //$$ = APPEND_STMTLIST($1, (alloc_stmt_list()));
    }
    | SourceElements SourceElement {
        //$$ = APPEND_STMTLIST($2, ($1));
    }
;

SourceElement 
    : Statement
    | FunctionDeclaration
;

PrimaryExpression 
    : This {
        //$$ = js_build_this_expr();
    }
    | Identifier {}
    | Literal {}
    | ArrayLiteral {
        debug("PrimaryExpression4");
    }
    | ObjectLiteral {
        /*debug("PrimaryExpression5");*/
    }
    | LCBRACE Expression RCBRACE {
        //$$ = $2;
    }
    ;

ArrayLiteral 
    : LPARENTHESIS RPARENTHESIS {
        /* [] */
        debug("ArrayLiteral1");
        //VEC(tree,gc) *elem = VEC_alloc(tree,gc, 0);
        //$$ = js_build_array_literal(elem);
    }
    | LPARENTHESIS Elision RPARENTHESIS {
        /* [,] [a,] */
        debug("ArrayLiteral2");
        //VEC(tree,gc) *elem = VEC_alloc(tree,gc, 0);
        //$$ = js_build_array_literal(elem);
    }
    | LPARENTHESIS ElementList RPARENTHESIS {
        /* [a=1, v=3] */
        debug("ArrayLiteral3");
        //VEC(tree,gc) *elem = $2;
        //$$ = js_build_array_literal(elem);
    }
    | LPARENTHESIS ElementList CAMMA Elisionopt RPARENTHESIS {
        /* [a, b, c] */
        debug("ArrayLiteral4");
        //$$ = js_build_array_literal($2);
    }
;

ElementList 
    : Elisionopt AssignmentExpression {
        //VEC(tree,gc) *elem = VEC_alloc(tree,gc, 0);
        //VEC_safe_push(tree, gc, elem, $2);
        //$$ = elem;
    }
    | ElementList CAMMA Elisionopt AssignmentExpression {
        //VEC(tree, gc) *elem = $1;
        //VEC_safe_push(tree, gc, elem, $4);
        //$$ = elem;
    }
    ;

Elisionopt
    :
    | Elision
    ;

Elision 
    : CAMMA
    | Elision CAMMA
    ;

ObjectLiteral 
    : LBRACE RBRACE
    | LBRACE PropertyNameAndValueList RBRACE
    | LBRACE PropertyNameAndValueList CAMMA RBRACE
    ;

PropertyNameAndValueList 
    : PropertyAssignment
    | PropertyNameAndValueList CAMMA PropertyAssignment
    ;

PropertyAssignment 
    : PropertyName COLON AssignmentExpression
    | "get" PropertyName LCBRACE RCBRACE LBRACE FunctionBody RBRACE
    | "set" PropertyName LCBRACE PropertySetParameterList RCBRACE LBRACE FunctionBody RBRACE
    ;

PropertyName 
    : IdentifierName
    | StringLiteral
    | NumericLiteral
    ;

PropertySetParameterList 
    : Identifier
    ;

Identifier 
    : IdentifierName {
    }
    ;

MemberExpression 
    : PrimaryExpression {
        /*debug("MemberExpression1");*/
    }
    | FunctionExpression {
        //debug("MemberExpression2");
    }
    | MemberExpression LPARENTHESIS Expression RPARENTHESIS {
        //debug("MemberExpression3");
        //tree expr = js_build_array_expr($1, $3);
        //$$ = expr;
    }
    | MemberExpression DOT IdentifierName {
        //debug("MemberExpression4");
        //$$ = js_build_propaty_expr($1, $3);
    }
    | New MemberExpression Arguments {
        /*debug("MemberExpression5");*/
        //$$ = js_build_new_expr($2, $3);
    }
    ;

NewExpression 
    : MemberExpression {
        /*debug("NewExpression1");*/
    }
    | New NewExpression {
        debug("NewExpression2");
        /*$$ = js_build_new_expr($2, NULL);*/
    }
    ;

CallExpression 
    : MemberExpression Arguments {
        debug("CallExpression1");
        //$$ = js_build_call_expr($1, $2, true);
    }
    | CallExpression Arguments {
        /*debug("CallExpression2");*/
        //$$ = js_build_call_expr($1, $2, true);
    }
    | CallExpression LPARENTHESIS Expression RPARENTHESIS {
        /*debug("CallExpression3");*/
    }
    | CallExpression DOT IdentifierName {
        /*debug("CallExpression4");*/
    }
    ;

Arguments 
    : LCBRACE RCBRACE {
        /*debug("Arguments1");*/
        //$$ = VEC_alloc(tree,gc,0);
    }
    | LCBRACE ArgumentList RCBRACE {
        /*debug("Arguments2");*/
        //$$ = $2;
    }
    ;

ArgumentList 
    : AssignmentExpression {
        //VEC(tree,gc) *args_list = VEC_alloc(tree,gc, 0);
        //tree elem = $1;
        //VEC_safe_push (tree, gc, args_list, elem);
        //$$ = args_list;
    }
    | ArgumentList CAMMA AssignmentExpression {
        //VEC(tree,gc) *args_list = $1;
        //tree elem = $3;
        //VEC_safe_push(tree, gc, args_list,elem);
        //$$ = args_list;
    }
    ;

LeftHandSideExpression 
    : NewExpression {
        /*debug("LeftHandSideExpression1");*/
        /*$$ = js_build_propaty_expr($1);*/
    }
    | CallExpression {
        /*debug("LeftHandSideExpression2");*/
    }
    ;

PostfixExpression
    : LeftHandSideExpression {}
    | LeftHandSideExpression PLUSPLUS {
        //$$ = js_build_op1_expr(OpPOST_INC, $1);
    }
    | LeftHandSideExpression MINUSMINUS {
        //$$ = js_build_op1_expr(OpPOST_INC, $1);
    }
    ;

UnaryExpression 
    : PostfixExpression {}
    | Delete UnaryExpression {
        debug("delete");
    }
    | Void UnaryExpression {
        debug("void");
    }
    | Typeof UnaryExpression {
        //$$ = js_build_typeof_expr($2);
    }
    | PLUSPLUS   UnaryExpression {
        debug("++ UnaryExpression");
        //$$ = js_build_op1_expr(OpPRED_INC, $2);
    }
    | MINUSMINUS UnaryExpression {
        debug("-- UnaryExpression");
        //$$ = js_build_op1_expr(OpPRED_DEC, $2);
    }
    | ADD  UnaryExpression {
        debug("+ val");
    }
    | SUB  UnaryExpression {
        debug("- val");
    }
    | INV  UnaryExpression {
        debug("INV val");
    }
    | NOT  UnaryExpression {
        debug("NOT UnaryExpression");
        //$$ = js_build_op1_expr(OpNot, $2);
    }
    ;

MultiplicativeExpression
    : UnaryExpression
    | MultiplicativeExpression MUL UnaryExpression {
        debug("MultiplicativeExpression1");
        //$$ = js_build_op2_expr(OpMul, $1, $3);
    }
    | MultiplicativeExpression DIV UnaryExpression {
        debug0("MultiplicativeExpression2");
        //$$ = js_build_op2_expr(OpDiv, $1, $3);
    }
    | MultiplicativeExpression REM UnaryExpression {
        debug0("MultiplicativeExpression3");
        //$$ = js_build_op2_expr(OpMod, $1, $3);
    }
    ;

AdditiveExpression
    : MultiplicativeExpression
    | AdditiveExpression ADD MultiplicativeExpression {
        debug0("AdditiveExpression1");
        //$$ = js_build_op2_expr(OpPlus, $1, $3);
    }
    | AdditiveExpression SUB MultiplicativeExpression {
        debug0("AdditiveExpression2");
        //$$ = js_build_op2_expr(OpMinus, $1, $3);
    }
    ;

ShiftExpression 
    : AdditiveExpression
    | ShiftExpression LSHIFT AdditiveExpression {
        debug("ShiftExpression");
        //$$ = js_build_op2_expr(OpLshift, $1, $3);
    }
    | ShiftExpression RSHIFT AdditiveExpression {
        //$$ = js_build_op2_expr(OpRshift, $1, $3);
    }
    | ShiftExpression SHIFT  AdditiveExpression {
        TODO();
    }
    ;

RelationalExpression 
    : ShiftExpression
    | RelationalExpression LT  ShiftExpression {
        //$$ = js_build_op2_expr(OpLT, $1, $3);
    }
    | RelationalExpression GT  ShiftExpression {
        //$$ = js_build_op2_expr(OpGT, $1, $3);
    }
    | RelationalExpression LTE ShiftExpression {
        //$$ = js_build_op2_expr(OpLE, $1, $3);
    }
    | RelationalExpression GTE ShiftExpression {
        //$$ = js_build_op2_expr(OpGE, $1, $3);
    }
    | RelationalExpression Instanceof ShiftExpression
    | RelationalExpression In ShiftExpression
    ;

RelationalExpressionNoIn
    : ShiftExpression
    | RelationalExpression LT  ShiftExpression {
        //$$ = js_build_op2_expr(OpLT, $1, $3);
    }
    | RelationalExpression GT  ShiftExpression {
        //$$ = js_build_op2_expr(OpGT, $1, $3);
    }
    | RelationalExpression LTE ShiftExpression {
        //$$ = js_build_op2_expr(OpLE, $1, $3);
    }
    | RelationalExpression GTE ShiftExpression {
        //$$ = js_build_op2_expr(OpGE, $1, $3);
    }
    | RelationalExpression Instanceof ShiftExpression {
        TODO();
    }
    ;

EqualityExpression 
    : RelationalExpression
    | EqualityExpression EQEQ   RelationalExpression {
        //$$ = js_build_op2_expr(OpEQ, $1, $3);
    }
    | EqualityExpression NEQ    RelationalExpression {
        //$$ = js_build_op2_expr(OpNE, $1, $3);
    }
    | EqualityExpression STREQ  RelationalExpression {
        //$$ = js_build_op2_expr(OpSTREQ, $1, $3);
    }
    | EqualityExpression STRNEQ RelationalExpression {
        //$$ = js_build_op2_expr(OpSTRNE, $1, $3);
    }
    ;

EqualityExpressionNoIn
    : RelationalExpressionNoIn
    | EqualityExpressionNoIn EQEQ   RelationalExpressionNoIn {
        //$$ = js_build_op2_expr(OpEQ, $1, $3);
    }
    | EqualityExpressionNoIn NEQ    RelationalExpressionNoIn {
        //$$ = js_build_op2_expr(OpNE, $1, $3);
    }
    | EqualityExpressionNoIn STREQ  RelationalExpressionNoIn {
        TODO();
    }
    | EqualityExpressionNoIn STRNEQ RelationalExpressionNoIn {
        TODO();
    }
    ;

BitwiseANDExpression 
    : EqualityExpression
    | BitwiseANDExpression AND EqualityExpression {
        //$$ = js_build_op2_expr(OpAnd, $1, $3);
    }
    ;

BitwiseXORExpression 
    : BitwiseANDExpression
    | BitwiseXORExpression XOR BitwiseANDExpression {
        //$$ = js_build_op2_expr(OpXor, $1, $3);
    }
    ;

BitwiseORExpression 
    : BitwiseXORExpression
    | BitwiseORExpression OR BitwiseXORExpression {
        //$$ = js_build_op2_expr(OpOr, $1, $3);
    }
    ;

LogicalANDExpression 
    : BitwiseORExpression
    | LogicalANDExpression AND2 BitwiseORExpression
    ;

LogicalORExpression 
    : LogicalANDExpression
    | LogicalORExpression OR2 LogicalANDExpression
    ;

BitwiseANDExpressionNoIn
    : EqualityExpressionNoIn
    | BitwiseANDExpressionNoIn AND EqualityExpressionNoIn {
        //$$ = js_build_op2_expr(OpAnd, $1, $3);
    }
    ;

BitwiseXORExpressionNoIn
    : BitwiseANDExpressionNoIn
    | BitwiseXORExpressionNoIn XOR BitwiseANDExpressionNoIn {
        //$$ = js_build_op2_expr(OpXor, $1, $3);
    }
    ;

BitwiseORExpressionNoIn
    : BitwiseXORExpressionNoIn
    | BitwiseORExpressionNoIn OR BitwiseXORExpressionNoIn {
        //$$ = js_build_op2_expr(OpOr, $1, $3);
    }
    ;

LogicalANDExpressionNoIn
    : BitwiseORExpressionNoIn
    | LogicalANDExpressionNoIn AND2 BitwiseORExpressionNoIn
    ;

LogicalORExpressionNoIn
    : LogicalANDExpressionNoIn
    | LogicalORExpressionNoIn OR2 LogicalANDExpressionNoIn
    ;

%%
location_t CURRENT_LOCATION(void)
{
    location_t loc = ((location_t)js_lloc.first_line);
    linemap_line_start(line_table, loc, 0);
    return loc;
}
