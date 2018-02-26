# Clausify Common Lisp Library

Convention for the representation of the WFFs:

term = <constant> \| <variable> \| <function>

constant = <number> \| <id>

variable = <symbol beginning with the character #\?>

function = '(' <id>  <term>+ ')'

wff = <predicate> </br>
	\| <negation> \| <conj> \| <disj> \| <implication> </br>
	\| <universal> \| <existential> </br>
	
predicate = <id> \| '(' <id> <term>+ ')'

negation = '(' not <wff> ')'

conj = '(' and <wff> <wff> ')'

disj = '(' or <wff> <wff> ')'

implication = '(' implies <wff> <wff> ')'

universal = '(' every <variable> <wff> ')'

existential = '(' exist <variable> <wff> ')'

id = <symbol beginning with a letter>

The two most important functions to use are **as-cnf** and **is-horn**:

* **as-cnf** takes as argument a WFF and rewrite it into his CNF form
* **is-horn** takes as argument a WFF and verify if his CNF's conversion is a conjunction of Horn clauses

## Algorithm

The trad-alg function, called by both as-cnf and is-horn, applies the following steps:

1. Remove implications using rule: </br>
   * (implies p q) = (or (not p) q)

2. Reduce all negations to negative literals only such as (not <predicate>) using rules: </br>
   * (not (not p)) = p </br>
   * (not (and p q)) = (or (not p) (not q)) </br>
   * (not (or p q)) = (and (not p) (not q)) </br>
   * (not (every ?x (p ?x))) = (exist ?x (not (p ?x))) </br>
   * (not (exist ?x (p ?x))) = (every ?x (not (p ?x))) </br>

3. “Skolemize” existential variables using rules: </br>
   * (exist ?x (p ?x)) = (p sk00042) </br>
   * (every ?y (exist ?x (p ?x ?y))) = (every ?y (p (sf666 ?y) ?y)) </br>
	
4. Simplify the universal by removing the quantifier and the variable.
	
5. Distribute the or until we get a conjunction of disjunctions and/or positive and/or negative literals.
	
### Examples:

**(as-cnf ’p)** </br>
P

**(as-cnf ’(implies (not (bar 42)) qwe))** </br>
(OR (BAR 42) QWE)

**(as-cnf ’(and (or p q) (not r)))** </br>
(AND (OR P Q) (NOT R)))

**(as-cnf ’(and (implies p q) (or w (or f (foo 42)))))** </br>
(AND (OR (NOT P) Q) (OR W F (FOO 42)))

**(as-cnf ’(every ?y (exist ?x (or (p ?x ?y) (and foo (bar ?y)))))** </br>
(AND (OR (P (SF-123 ?Y) ?Y) FOO) (OR (P (SF-123 ?Y) ?Y) (BAR ?Y)))

**(is-horn ’(implies p (or q w)))** </br>
NIL

**(is-horn ’(implies (and p q) r))** </br>
T

**(is-horn ’(implies p (not q))** </br>
T
