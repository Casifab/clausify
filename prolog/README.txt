807398 Fabio Casiraghi
808865 Alessandro Guidi
807592 Mattia Amico

-------------------------------------<informazioni-progetto>-------------------------------------------

-> as_cnf/2: questo predicato,dato in input una formula ben formata(FBF),risolve le clausole/regole 
	     trasformando la FBF in un linguaggio logico del primo ordine in forma normale cogiunta
	     (cnf). Richiama diverse funzioni,ognuna corrisponde ad una regola.

-> is_horn/1: questo predicato,dato in input una formula ben formata(FBF),richiama la as_cnf per 
	      renderla una CNF e controlla se è una clausola di horn,ovvero se c'è al massimo un 
	      predicato positivo.   

-> rule_implications/3: questo predicato,dato in input:una lista di termini e una lista di appoggio
			risolve la regola delle FBF dell'implicazione. Utilizza diverse funzioni di 
			appoggio.
-> rule_not/3: questo predicato,dato in input una lista di termini e una lista di appoggio, scorre
	       l'array di termini e risolve con le regole del not con altri operatori.

-> rules_or_and: questo predicato,dato in input una lista di termini e una lista di appoggio, scorre
		 l'array di termini e controlla se vi sono espressioni con un operatore AND 
		 all'interno di un operatore OR,in questo caso applica la regola convertendolo.

-> rules_quantified1/3: questo predicato prende in input una FBF, aggiunge in una lista le variabili
			presenti nella FBF, risolve le regole degli operatori EVERY e EXIST ed infine 
			richiama remove_every/3.

-> rules_quantified/4: questo predicato, dato in input: una FBF, una lista di appoggio, la lista 
		       delle variabili nella FBF, risolve le regole dei quantificatori "esiste" e 
		       "per ogni".
-> semplification/3: questo predicato,dato in input una FBF,come lista di termini, e una lista di
		     appoggio, semplifica la FBF nel caso in cui ci siano più predicati che possono
		     essere visti all'interno della stessa WFF.
		     un esempio: or(p,or(a,b)) ---diventa--> or(p,a,b) 
		     la stessa cosa avviene se l'operatore è un AND.
  
-------------------------------------------UTILIZZATI DA IS_HORN---------------------------------
-> control_not/2: questo predicato,dato in input una CNF e un contatore, controlla il primo predicato
		  o la prima wff dell'input passato. Funzione richiamata da is_horn/1

-> control_not1/2: questo predicato,controlla i predicati interni della CNF passata da control_not/1
		   

-------------------------------------UTILIZZATI DA RULES_IMPLICATION-------------------------------
-> parse_p/2: questo predicato,richiamato da rule_implies e dato in input un parametro,che può essere
	      sia un operatore che un predicato. aggiunge un not all'espressione.

-> parse_q/2: questo predicato,richiamato da rule_implies e dato in input un parametro, controlla solo
	      che non ci siano altre implies.

-> parse_impl/3: questo predicato,dato in input 2 parametri, unisce i due parametri e ci concatena 
		 l'or della implicazione.

-------------------------------UTILIZZATI DA RULES_NOT----------------------------------------------
-> parse_NOT_AND/3: questo predicato,dato in input 2 espressioni, parsa i parametri passati secondo
		    la regola not-and delle FBF,infine aggiunge alle due espressioni concatenare 
		    l'operatore OR.
-> parse_NOT_OR/3:  questo predicato,dato in input 2 espressioni, parsa i parametri passati secondo
		    la regola not-or delle FBF,infine aggiunge alle due espressioni concatenare 
		    l'operatore AND.

-> parse_NOT_EXIST/3: questo predicato,dato in input 2 espressioni, controlla che il primo parametro
		      sia una variabile, parsa la proposizione che segue la variabile,ed aggiunge 
		      l'operatore EVERY all'inizio.

-> parse_NOT_EVERY/3: questo predicato,dato in input 2 espressioni, controlla che il primo parametro
		     sia una variabile, parsa la proposizione che segue la variabile,ed aggiunge 
		     l'operatore EXIST all'inizio.

----------------------------UTILIZZATI DA RULES_OR_AND------------------------------------------
-> check_and/1: questo predicato,dato in input una lista, controlla se il primo elemento della lista
		sia uguale all'operatore AND.

-> parse_OR_AND/3: questo predicato,dato in input una lista di termini e un predicato(letterale), 
		   richiama sulla lista check_and/1, controlla che il letterale sia un predicato;
		   una volta verificate prende le proposizione dell'espressione AND e applica la 
		   regola OR_AND.
------------------------------UTILIZZATI DA RULES_QUANTIFIED-------------------------------------
-> prendi_predicate/3: questo predicato,dato in input una FBF che ha come operatore EVERY o EXIST
		       prende qualsiasi proposizione\wff ci sia dopo la variabile.

-> skolem_variable/2: questo predicato,dato in input unva variabile,viene richiamato quando si 
		      incontra un operatore EXIST !NON! preceduto da every; associa alla variabile 
		      dell'operatore un parametro.

-> skolem_function/2: questo predicato,dato in input una lista di argomenti\variabili, crea una 
		      parametro\funzione che ha come argomenti gli argomenti\variabili.  

-> remove_every/3: questo predicato,dato in input una lista di termini(una FBF) e una lista di 
		   appoggio, elimina dalla FBF tutti gli operatori EVERY e le variabili ad essa
		   associata.
-----------------------------UTILIZZATI DA SEMPLIFICATION-------------------------------------------
-> semplification_1/3: questo predicato,dato in input un'espressione e un operatore, controlla se 
		       l'operatore più interno è uguale a quello esterno, in questo caso mette tutto
		       all'interno di un nuovo operatore
-> check_not_number/1: questo predicato, dato in input una lista di termini, controlla che il primo 
		       elemento non sia un numero, lo converte in codice e lo confronta con il range 
		       dell'alfabeto(minuscole)
-------------------------------------ALTRE FUNZIONI-------------------------------------------------
-> prendi_p_q/3: questo predicato,data in input una lista di termini,prende i "parametri" di una wff

-> check_predicate/1: questo predicato,dato in input un termine, controlla se il parametro passato è
		      un predicato(letterale) o una funzione,ovvero non un operatore WFF

-> check_wff/1: questo predicato,dato in input un termine, controlla se l'input è un atomo e se 
		corrisponde ad un operatore

-> primo_elemento/2: questo predicato,dato in input una lista, restituisce il primo elemento.

-> parse_pro/2: questo predicato,dato in input una espressione, controlla se l'input passato 
		è un atomo,in questo caso richiama check_predicate/1,altrimenti controlla se al 
		suo interno ci siano altre regole not da applicare.  
