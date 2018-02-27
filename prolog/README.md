# Clausify SWI Prolog Library

Convention for the representation of the WFFs:

**term** = _constant_ | _variable_ | _function_

**constant** = _number_ | _id_

**variable** = _Prolog term satisfying var/1_

**function** = _id_'(' _term_[',' _term_]\* ')'

**wff** = _predicate_ | _negation_ | _conj_ | _disj_ | _implication_ | _universal_ | _existential_
	
**predicate** = _id_ |  _id_'(' _term_[',' _term_]\* ')'

**negation** = not'(' _wff_ ')'

**conj** = and'(' _wff_ ',' _wff_ ')'

**disj** = or'(' _wff_ ',' _wff_ ')'

**implication** = implies'(' _wff_ ',' _wff_ ')'

**universal** = every'(' _variable_ ',' _wff_ ')'

**existential** = exist'(' _variable_ ',' _wff_ ')'

**id** = _Prolog non numeric atom_

The two most important functions to use are **as-cnf** and **is-horn**:

* **as_cn/2** takes as argument a WFF and rewrite it into his CNF form
* **is_horn/1** takes as argument a WFF and verify if his CNF's conversion is a conjunction of Horn clauses

## Algorithm

The trad-alg function, called by both as-cnf and is-horn, applies the following steps:

1. Remove implications using rule: </br>
   * implies(p,q). --> or(not(p), q).

2. Reduce all negations to negative literals only such as (not <predicate>) using rules: </br>
   * not(not(p)). --> p. </br>
   * not(and(p,q)). --> or(not(p), not(q)). </br>
   * not(or(p,q)). --> and(not(p), not(q)). </br>
   * not(every(X,p(X))). --> not(p(X)). </br>
   * not(exist(X,p(X))). --> not(p(skv1)). </br>

3. “Skolemize” existential variables using rules: </br>
   * exist(X,p(X)). --> p(sk00042). </br>
   * every(X,exist(Y,p(X,Y))). --> every(Y,p(sf666,Y),Y). </br>
	
4. Simplify the universal by removing the quantifier and the variable.
	
5. Distribute the or until we get a conjunction of disjunctions and/or positive and/or negative literals.
	
### Examples:

**as_cnf(p, Q).** </br>
Q = p.

**as_cnf(exist(X, every(Y, foo(Y, X))), F).** </br>
X = skv6, </br>
F = foo(Y, skv6).

**as_cnf(every(X, exist(Y, foo(Y, X))), F).** </br>
Y = skf7(X), </br>
F = foo(skf7(X), X).

**as_cnf(implies(and(p, q), r), R).** </br>
R = or(not(p), not(q), r).

**as_cnf(exist(X, or(p(X), implies(q(X), zut))), R).** </br>
X = skv8, </br>
R = or(p(skv8), not(q(skv8)), zut).

**is_horn(implies(p, or(q, w))).** </br>
false

**is_horn(implies(and(p, q), w)).** </br>
true
