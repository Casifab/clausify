%%%% -*- Mode: Prolog -*-

%% Funzioni fornite dal progetto

skolem_variable(V, SK) :- var(V), gensym(skv, SK).

skolem_function([], SF) :- skolem_variable(_, SF).

skolem_function([A | ARGS], SF) :-
    gensym(skf, SF_op),
    SF =.. [SF_op, A | ARGS].

%% Regole

term(X) :- atomic(X).
term(X) :- var(X).

wff(pred).
wff(not).
wff(and).
wff(or).
wff(implies).
wff(every).
wff(exist).
wff(X) :- compound(X).
	  
pred(X) :- atom(X).
pred(X) :- compound(X),
	   X = .. [Y | Ys],
	   atomic(Y),
	   is-wff(Ys).

