## Clausify Common Lisp Library

Convention for the representation of the WFFs:

term ::= <constant> | <variable> | <function>
constant ::= <number> | <id>
variable ::= <symbol beginning with the character #\?>
function ::= '(' <id>  <term>+ ')'

wff ::= <predicate>
	| <negation> | <conj> | <disj> | <implication>
	| <universal> | <existential>
	
predicate ::= <id> | '(' <id> <term>+ ')'

negation ::= '(' not <wff> ')'
conj ::= '(' and <wff> <wff> ')'
disj ::= '(' or <wff> <wff> ')'
implication ::= '(' implies <wff> <wff> ')'
universal ::= '(' every <variable> <wff> ')'
existential ::= '(' exist <variable> <wff> ')'

id ::= <symbol beginning with a letter>

The two most important functions to use are **as-cnf** and **is-horn**:

* as-cnf takes as argument a WFF and rewrite it into his CNF form
* is-horn takes as argument a WFF and verify if his CNF's conversion is a conjunction of Horn clauses

The trad-alg function, called by both as-cnf and is-horn, applies the following steps:

1. Remove implications using rule:
(implies p q) = (or (not p) q)

2. Reduce all negations to negative literals only such as (not <predicate>) using rules:
(not (not p)) = p
(not (and p q)) = (or (not p) (not q))
(not (or p q)) = (and (not p) (not q))
(not (every ?x (p ?x))) = (exist ?x (not (p ?x)))
(not (exist ?x (p ?x))) = (every ?x (not (p ?x)))

3. “Skolemize” existential variables using rules:
(exist ?x (p ?x)) = (p sk00042)
(every ?y (exist ?x (p ?x ?y))) = (every ?y (p (sf666 ?y) ?y))
	
4. Simplify the universal by removing the quantifier and the variable.
	
5. Distribute the or until we get a conjunction of disjunctions and/or positive and/or negative literals.
	
##### Examples:

CL-USER> **(as-cnf ’p)**
P

CL-USER> **(as-cnf ’(implies (not (bar 42)) qwe))** </br>
(OR (BAR 42) QWE)

CL-USER> **(as-cnf ’(and (or p q) (not r)))** </br>
(AND (OR P Q) (NOT R)))

CL-USER> **(as-cnf ’(and (implies p q) (or w (or f (foo 42)))))**
(AND (OR (NOT P) Q) (OR W F (FOO 42)))

CL-USER> **(as-cnf ’(every ?y (exist ?x (or (p ?x ?y) (and foo (bar ?y)))))**
(AND (OR (P (SF-123 ?Y) ?Y) FOO) (OR (P (SF-123 ?Y) ?Y) (BAR ?Y)))

CL-USER> **(is-horn ’(implies p (or q w)))**
NIL

CL-USER> **(is-horn ’(implies (and p q) r))**
T

CL-USER> **(is-horn ’(implies p (not q))**
T
