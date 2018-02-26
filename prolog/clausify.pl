%%%% -*- Mode: Prolog -*-
%%%% 807398 Casiraghi Fabio
%%%% 808865 Guidi Alessandro
%%%% 807592 Amico Mattia

as_cnf(FBF, CNFFBF):-
    atom(FBF),
    copy_term(FBF, CNFFBF),!.

as_cnf(FBF, CNFFBF):-
    FBF =.. FBFList,
    rule_implications(FBFList, [], NI),
    rules_not(NI, [], NN),
    rules_or_and(NN, [], NOA),
    rules_quantified1(NOA, NEE),
    semplification(NEE, [], CNF),
    CNFFBF =.. CNF,!.

%una clausola di Horn è una disgiunzione di letterali in cui
%al massimo uno dei letterali è positivo.
is_horn(FBF):-
    as_cnf(FBF, CNF),
    CNF =.. CNF1,
    control_not(CNF1, 0),!.

%trovo la wff rimasta diversa da not,come prima cosa
control_not([X|CNF], Count):-
    Count <2,
    atom(X),
    check_wff(X),
    X \= not,
    control_not1(CNF, Count),!.

%trovo una not con una funzione dentro,come prima cosa
control_not([X|CNF], Count):-
    Count <2,
    atom(X),
    X == not,
    primo_elemento(CNF, First),
    compound(First),
    control_not1(CNF, Count),!.

%trovo una not con un atomo dentro,come prima cosa
control_not([X|CNF], Count):-
    Count <2,
    atom(X),
    X == not,
    primo_elemento(CNF, First),
    atom(First),
    check_predicate([First]),
    control_not1(CNF, Count),!.

%trovo una funzione come prima cosa
control_not([X|_CNF], _Count):-
    atom(X),
    check_predicate([X]),!.

%Caso base
control_not1([], Count):-
    Count <2,!.
%entro in profondità e trovo un predicato\termine
control_not1([X|CNF], Count):-
    atom(X),
    check_predicate([X]),
    plus(Count, 1, Count1),
    control_not1(CNF, Count1).

%entro in profondità e trovo un compound con il not
control_not1([X|CNF], Count):-
    Count <2,
    compound(X),
    X =.. X1,
    primo_elemento(X1, First),
    First == not,
    control_not1(CNF, Count),!.
%entro in profondità e trovo un compound senza il not,quindi +1
control_not1([X|CNF], Count):-
    Count <2,
    compound(X),
    X =.. X1,
    primo_elemento(X1, First),
    First \= not,
    plus(Count, 1, Count1),
    control_not1(CNF, Count1),!.

%funzioni per rule(6) implica
rule_implications([], F, F):-!.

rule_implications([X|FBF], Support, F):-
    X == implies,
    Support == [],
    prendi_p_q(FBF, P, Q),
    parse_p(P, P1),
    primo_elemento(Q, First),
    parse_q(First, Q1),
    parse_impl([P1], [Q1], F),!.


rule_implications([X|FBF], Support, F):-
    X == implies,
    Support \= [],
    prendi_p_q(FBF, P, Q),
    parse_p(P, P1),
    parse_q(Q, Q1),
    parse_impl([P1], [Q1], F),!.

rule_implications([X|FBF], Support, F):-
    atom(X),
    append(Support, [X], S1),
    rule_implications(FBF, S1, F),!.

rule_implications([X|FBF], Support, F):-
    var(X),
    append(Support, [X], S1),
    rule_implications(FBF, S1, F),!.

rule_implications([X|FBF], Support, F):-
    compound(X),
    X =.. X1,
    rule_implications(X1, [], X2),
    X3 =.. X2,
    append(Support, [X3], S1),
    rule_implications(FBF, S1, F),!.

prendi_p_q([X|FBF], X, FBF).

parse_p(P, F):-
    P =.. P1,
    rule_implications(P1, [], P2),
    P3 =.. P2,
    append([not], [P3], F1),
    F =.. F1.

parse_q(Q, F):-
    Q =.. Q1,
    rule_implications(Q1, [], F1),
    F =.. F1.

parse_impl(P, Q, F):-
    append(P, Q, Impl),
    append([or], Impl, F).

%rules not (1-5)
rules_not([], F, F).

%rules not_not
rules_not([X|F], Support, F):-
    X == not,
    Support == [not],
    primo_elemento(F,First),
    atom(First),
    check_predicate(F),!.
%rules not_not
rules_not([X|FBF], Support, F):-
    X == not,
    Support == [not],
    rules_not(FBF, [], F),!.
%rules not_and
rules_not([X|FBF], Support, F):-
    X == and,
    Support == [not],
    prendi_p_q(FBF, P, Q),
    primo_elemento(Q, Q1),
    parse_NOT_AND(P, Q1, F1),
    rules_not(F1, [], F),!.
%rules not_or
rules_not([X|FBF], Support, F):-
    X == or,
    Support == [not],
    prendi_p_q(FBF, P, Q),
    parse_NOT_OR(P, Q, F1),
    rules_not(F1, [], F),!.
%rules not_exist
rules_not([X|FBF], Support, F):-
    X == exist,
    Support == [not],
    prendi_p_q(FBF, P, Q),
    parse_NOT_EXIST(P, Q, F1),
    rules_not(F1, [], F),!.
%rules not_every
rules_not([X|FBF], Support, F):-
    X == every,
    Support == [not],
    prendi_p_q(FBF, P, Q),
    parse_NOT_EVERY(P, Q, F1),
    rules_not(F1, [], F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    X \= not,
    atom(X),
    Support \= [not],
    check_wff(X),
    append(Support, [X], S1),
    rules_not(FBF, S1, F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    X \= not,
    atom(X),
    Support == [not],
    check_wff(X),
    append([X], [], [X]),
    rules_not(FBF, [X], F1),
    F2 =.. F1,
    append(Support, [F2], F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    X \= not,
    atom(X),
    Support == [],
    check_not_number(X),
    rules_not(FBF, [X], F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    atom(X),
    check_wff(X),
    Support == [],
    rules_not(FBF , [X], F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    atom(X),
    Support \= [],
    check_predicate([X]),
    append(Support, [X], S1),
    rules_not(FBF, S1, F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    compound(X),
    Support \= [],
    Support \= [not],
    X =.. X1,
    rules_not(X1, [], F1),
    F2 =.. F1,
    append(Support, [F2], S1),
    rules_not(FBF, S1, F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    compound(X),
    Support == [not],
    FBF == [],
    X =.. X1,
    primo_elemento(X1, First),
    check_wff(First),
    rules_not(X1, Support, F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    compound(X),
    Support == [not],
    FBF == [],
    X =.. X1,
    primo_elemento(X1, First),
    check_predicate(First),
    rules_not(X1, [], F1),
    F2 =.. F1,
    append(Support, [F2], F),!.
%per tutte le rules
rules_not([X|[]], Support, F):-
    compound(X),
    Support == [],
    X =.. X1,
    rules_not(X1, [], F),!.
%per tutte le rules
rules_not([X|FBF], Support, F):-
    var(X),
    append(Support, [X], F1),
    rules_not(FBF, F1, F),!.

%controlla che sia un predicato e non una WFF
check_predicate(FBF):-
    atom(FBF),
    FBF \= not,
    FBF \= and,
    FBF \= or,
    FBF \= exist,
    FBF \= every,!.

check_predicate(FBF):-
    compound(FBF),
    is_list(FBF),
    primo_elemento(FBF,X),
    compound(X),
    X =.. WFF,
    primo_elemento(WFF, First),
    check_predicate(First),!.

check_predicate(FBF):-
    compound(FBF),
    is_list(FBF),
    primo_elemento(FBF,X),
    atomic(X),
    WFF =.. [X],
    check_predicate(WFF),!.

check_predicate(FBF):-
    compound(FBF),
    FBF =.. [WFF|_FBF1],
    WFF \= '[|]',
    check_predicate(WFF),!.

check_wff(X):-
    atom(X),
    member(X,[and,not,or,every,exist]).

primo_elemento([F|_FBF],F).

%parsa i paramentri nella regola not-and
parse_NOT_AND(P, Q, F):-
    parse_pro(P, P1),
    parse_pro(Q, Q1),
    append([not], P1, P2),
    P3 =.. P2,
    append([not], Q1, Q2),
    Q3 =.. Q2,
    append([P3], [Q3], F1),
    append([or], F1, F).
%parsa i parametri nella regola not-or
parse_NOT_OR(P, Q, F):-
    parse_pro(P, P1),
    parse_pro(Q, Q1),
    append([not], P1, P2),
    P3 =.. P2,
    append([not], Q1, Q2),
    Q3 =.. Q2,
    append([P3], [Q3], F1),
    append([and], F1, F).

%parsa i parametri nella regola not-exist
parse_NOT_EXIST(P, Q, F):-
    var(P),
    parse_pro(Q, Q1),
    append([P], Q1, F1),
    append([every], F1, F),!.
%parsa i parametri nella regola not-every
parse_NOT_EVERY(P, Q, F):-
    var(P),
    parse_pro(Q, Q1),
    append([P], Q1, F1),
    append([exist], F1, F),!.

parse_pro(F, [F]):-
    atom(F),
    check_predicate([F]),!.

parse_pro(P, [F]):-
    compound(P),
    P =.. P1,
    rules_not(P1, [], F1),
    F =.. F1,!.

%rules or_and(7)
rules_or_and([], F, F).

rules_or_and([X|FBF], Support, F):-
    atom(X),
    check_wff(X),
    Support == [],
    rules_or_and(FBF, [X], F),!.

%parsa or_and WFF-P
rules_or_and([X|FBF], Support, F):-
    compound(X),
    Support == [or],
    X =.. X1,
    check_and(X1),
    rules_or_and(X1, [], X2),
    check_predicate(FBF),
    parse_OR_AND(X2, FBF, F),!.
%parsa or_and P-WFF
rules_or_and([X|FBF], Support, F):-
    atom(X),
    Support == [or],
    check_predicate([X]),
    primo_elemento(FBF, WFF),
    WFF =.. WFF1,
    check_and(WFF1),
    rules_or_and(WFF1, [], WFF2),
    parse_OR_AND(WFF2, X, F),!.

rules_or_and([X|FBF], Support, F):-
    compound(X),
    Support \= [or],
    X =.. X1,
    rules_or_and(X1, [], F1),
    F2 =.. F1,
    append(Support, [F2], F3),
    rules_or_and(FBF, F3, F),!.

rules_or_and([X|FBF], Support, F):-
    compound(X),
    Support == [or],
    X =.. X1,
    rules_or_and(X1, [], X2),
    F1 =.. X2,
    append(Support, [F1], F2),
    rules_or_and(FBF, F2, F),!.

rules_or_and([X|FBF], Support, F):-
    atom(X),
    check_predicate([X]),
    append(Support, [X], F1),
    rules_or_and(FBF, F1, F),!.

rules_or_and([X|FBF], Support, F):-
    var(X),
    append(Support, [X], S1),
    rules_or_and(FBF, S1, F),!.

check_and(FBF):-
    primo_elemento(FBF, First),
    First == and.

parse_OR_AND([X|WFF], Pred, F):-
    check_and([X]),
    prendi_p_q(WFF, P, Q),
    is_list(Pred),
    append(Pred, [P], P1),
    append([or], P1, P2),
    rules_or_and(P2, [], P3),
    Part1 =.. P3,
    append(Pred, Q, Q1),
    append([or], Q1, Q2),
    rules_or_and(Q2, [], Q3),
    Part2 =.. Q3,
    append([and], [Part1], F1),
    append(F1, [Part2], F).

parse_OR_AND([X|WFF], Pred, F):-
    check_and([X]),
    prendi_p_q(WFF, P, Q),
    append([Pred], [P], P1),
    append([or], P1, P2),
    rules_or_and(P2, [], P3),
    Part1 =.. P3,
    append([Pred], Q, Q1),
    append([or], Q1, Q2),
    rules_or_and(Q2, [], Q3),
    Part2 =.. Q3,
    append([and], [Part1], F1),
    append(F1, [Part2], F).

%rules every and exist (8-9)
rules_quantified1(FBF, F):-
    term_variables(FBF, Vars),
    rules_quantified(FBF, [], Vars, F1),
    remove_every(F1, [], F).

rules_quantified([], F, _Vars, F):-!.

%parsare exist_1
rules_quantified([X|FBF], Support, [P1|Vars], F):-
    X == exist,
    Support == [],
    prendi_p_q(FBF, P, Q),
    skolem_variable(P, P1),
    rules_quantified(Q, [], Vars, F),
    !.
%parsare exist_2
rules_quantified([X|FBF], Support, [P1|Vars], F):-
    X == exist,
    Support \= [],
    primo_elemento(Support, S1),
    S1 \= every,
    prendi_p_q(FBF, P, Q),
    skolem_variable(P, P1),
    rules_quantified(Q, [], Vars,F1),
    F2 =.. F1,
    append(Support, [F2], F),!.
%dovrebbe essere il primo every che trovo
rules_quantified([X|FBF], Support, [P1|Vars], F):-
    X == every,
    Support == [],
    prendi_p_q(FBF, P, Q),
    var(P),
    P == P1,
    append([every], [P], S1),
    rules_quantified(Q, S1, Vars, F),
    !.

rules_quantified([X|FBF], Support, [P1|Vars], F):-
    X == every,
    primo_elemento(Support, S1),
    S1 == every,
    prendi_p_q(FBF, P, Q),
    var(P),
    P == P1,
    append(Support, [P], S2),
    rules_quantified(Q, S2, Vars, F1),
    Part2 =.. F1,
    append([X], [P], Part1),
    append(Part1, [Part2], F),!.

rules_quantified([X|FBF], [Y|Support], [P1|Vars], F):-
    X == exist,
    Y == every,
    prendi_p_q(FBF, P, Q),
    P == P1,
    skolem_function(Support, P1),
    rules_quantified(Q, [], Vars, F),!.


rules_quantified([X|FBF], Support, _Vars, F):-
    atom(X),
    check_predicate([X]),
    primo_elemento(Support, S1),
    S1 == every,
    prendi_predicate([X|FBF], [], F),
    !.
rules_quantified([X|FBF], Support, Vars, F):-
    atom(X),
    check_predicate([X]),
    append(Support, [X], S1),
    rules_quantified(FBF, S1, Vars, F),
    !.

%entra solo se X e' diverso da every o exist,
%dato che accetta le condizioni sopra
rules_quantified([X|FBF], Support, Vars, F):-
    atom(X),
    check_wff(X),
    append(Support, [X], S1),
    rules_quantified(FBF, S1, Vars, F),!.

rules_quantified([X|FBF], Support, Vars, F):-
    var(X),
    append(Support, [X], F1),
    rules_quantified(FBF, F1, Vars, F),!.

rules_quantified([X|FBF], Support, Vars,F):-
    compound(X),
    primo_elemento(Support, S1),
    S1 \= every,
    X =.. X1,
    rules_quantified(X1, [], Vars, F1),
    F2 =.. F1,
    append(Support, [F2], F3),
    rules_quantified(FBF, F3, Vars, F),!.

rules_quantified([X|FBF], Support, Vars, F):-
    compound(X),
    primo_elemento(Support, S1),
    S1 == every,
    X =.. X1,
    rules_quantified(X1, Support, Vars, F1),
    rules_quantified(FBF, F1, Vars, F),
    !.

rules_quantified([X|FBF], Support, Vars, F):-
    compound(X),
    Support == [],
    X =.. X1,
    rules_quantified(X1, [], Vars, F1),
    rules_quantified(FBF, F1, Vars, F),!.

prendi_predicate([], F, F):-!.
prendi_predicate([X|FBF], Support, F):-
    var(X),
    append(Support, [X], F1),
    prendi_predicate(FBF, F1, F),!.

prendi_predicate([X|FBF], Support, F):-
    atom(X),
    append(Support, [X], F1),
    prendi_predicate(FBF, F1, F),!.

skolem_variable(V, SK) :- var(V), gensym(skv, SK).

skolem_function([], SF) :- skolem_variable(_, SF).

skolem_function([A | ARGS], SF) :-
gensym(skf, SF_op),
SF =.. [SF_op, A | ARGS].

%elimina le proposizioni every e la variabile ad essa associata
remove_every([], F, F):-!.

remove_every([X|FBF], Support, F):-
    X == every,
    Support == [],
    prendi_p_q(FBF, P, Q),
    var(P),
    remove_every(Q, [], F),!.

remove_every([X|FBF], Support, F):-
    X == every,
    Support \= [],
    prendi_p_q(FBF, P, Q),
    var(P),
    remove_every(Q, [], F1),
    F2 =.. F1,
    append(Support, [F2], F),!.

remove_every([X|FBF], Support, F):-
    atom(X),
    append(Support, [X], S1),
    remove_every(FBF, S1, F),!.

remove_every([X|FBF], Support, F):-
    var(X),
    append(Support, [X], S1),
    remove_every(FBF, S1, F),!.

remove_every([X|FBF], Support, F):-
    compound(X),
    Support \= [],
    X =.. X1,
    remove_every(X1, [], F1),
    F2 =.. F1,
    append(Support, [F2], S1),
    remove_every(FBF, S1, F),!.

remove_every([X|FBF], Support, F):-
    compound(X),
    Support == [],
    X =.. X1,
    remove_every(X1, [], S1),
    remove_every(FBF, S1, F),!.

%semplification conj\disj
semplification([], F, F):-!.

%quando sono Atom e Comp
semplification([X|FBF], Support, F):-
    member(X,[and,or]),
    prendi_p_q(FBF, P, Q),
    atom(P),
    check_predicate([P]),
    compound(Q),
    semplification_1(Q, X, Q1),
    append([X], [P], Part1),
    append(Part1, Q1, F1),
    append(Support, F1, F),!.
%quando sono Comp e Atom
semplification([X|FBF], Support, F):-
    member(X,[and,or]),
    prendi_p_q(FBF, P, Q),
    compound(P),
    atom(Q),
    check_predicate([Q]),
    semplification_1([P], X, P1),
    append([X], P1, Part1),
    append(Part1, [Q], F1),
    append(Support, F1, F),!.
%quando sono Comp e comp
semplification([X|FBF], Support, F):-
    member(X,[and,or]),
    prendi_p_q(FBF, P, Q),
    compound(P),
    compound(Q),
    semplification_1([P], X, P1),
    semplification_1(Q, X, Q1),
    append([X], P1, Part1),
    append(Part1, Q1, F1),
    append(Support, F1, F),!.

semplification([X|FBF], Support, F):-
    atom(X),
    append(Support, [X], S1),
    semplification(FBF, S1, F),!.

semplification([X|FBF], Support, F):-
    var(X),
    append(Support, [X], S1),
    semplification(FBF, S1, F),!.

semplification([X|FBF], Support, F):-
    compound(X),
    Support \= [],
    X =.. X1,
    primo_elemento(X1, First),
    First \= or,
    First \= and,
    semplification(X1, [], X2),
    X3 =.. X2,
    append(Support, [X3], S1),
    semplification(FBF, S1, F),!.

semplification([X|FBF], Support, [F]):-
    compound(X),
    Support == [],
    X =.. X1,
    primo_elemento(X1, First),
    First \= or,
    First \= and,
    semplification(X1, [], X2),
    X3 =.. X2,
    semplification(FBF, X3, F),!.

semplification_1(C, X, F):-
    primo_elemento(C, C1),
    C1 =.. C2,
    primo_elemento(C2, First),
    First == X,
    append([First], Current, C2),
    prendi_p_q(Current, P, Q),
    semplification([P], [], P1),
    semplification(Q, [], Q2),
    append(P1, Q2, F),!.

semplification_1(C, X, [F]):-
    primo_elemento(C, C1),
    C1 =.. C2,
    primo_elemento(C2, First),
    X \= First,
    semplification(C2, [], F1),
    F =.. F1,!.
%controlla che sia una lettera
check_not_number(N):-
    name(N, [F|_N1]),
    F >= 97,
    F =< 122.
