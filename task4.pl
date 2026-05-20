% Task 4 (Variant 3) / Задача 4 (варіант 3)
% Detect left-recursive non-terminals and eliminate left recursion
% Виявити ліво-рекурсивні нетермінали та виконати усунення
% (both direct and indirect) — Aho-Sethi-Ullman algorithm.
% (як пряму, так і непряму) — алгоритм Ахо-Сеті-Ульмана.

:- set_prolog_flag(encoding, utf8).
:- catch(set_stream(user_input, encoding(utf8)), _, true).
:- catch(set_stream(user_output, encoding(utf8)), _, true).
:- catch(set_stream(user_error, encoding(utf8)), _, true).
:- initialization(main, main).
:- use_module(library(lists)).
:- use_module(library(yall)).

% --- Grammar representation / Опис граматики ---
%   Grammar is a list of rule(NonTerm, RHS).
%   RHS is a list of symbols where a symbol is t(Term) or nt(NT).
%   Empty RHS  []  denotes an epsilon production.

% --- Preset grammars / Готові граматики ---

grammar_preset(g1, ['E', 'T', 'F'], [
    rule('E', [nt('E'), t(+), nt('T')]),
    rule('E', [nt('T')]),
    rule('T', [nt('T'), t(*), nt('F')]),
    rule('T', [nt('F')]),
    rule('F', [t('('), nt('E'), t(')')]),
    rule('F', [t(id)])
]).

grammar_preset(g2, ['A', 'B'], [
    rule('A', [nt('B'), t(a)]),
    rule('A', [t(c)]),
    rule('B', [nt('A'), t(b)]),
    rule('B', [t(d)])
]).

grammar_preset(g3, ['S'], [
    rule('S', [t(a), nt('S')]),
    rule('S', [t(b)])
]).

% --- Detection of left recursion ---

direct_lr(G, A) :-
    member(rule(A, [nt(A) | _]), G).

left_recursive(G, A) :-
    left_reach(G, A, A, [A]).

left_reach(G, From, To, _) :-
    member(rule(From, [nt(To) | _]), G).
left_reach(G, From, To, Visited) :-
    member(rule(From, [nt(C) | _]), G),
    C \== To,
    \+ member(C, Visited),
    left_reach(G, C, To, [C | Visited]).

% --- Direct left-recursion elimination for one non-terminal ---

eliminate_direct_lr(A, G, NewG) :-
    findall(Alpha,  member(rule(A, [nt(A) | Alpha]), G), Alphas),
    findall(Beta,
            ( member(rule(A, Beta), G),
              \+ Beta = [nt(A) | _] ),
            Betas),
    (   Alphas == []
    ->  NewG = G
    ;   ( Betas == []
        ->  format("WARNING: ~w має лише ліво-рекурсивні правила — мова порожня.~n", [A]),
            NewG = G
        ;   fresh_name(A, APrime),
            exclude([R]>>(R = rule(A, _)), G, GWithoutA),
            findall(rule(A, NewBeta),
                    ( member(Beta, Betas),
                      append(Beta, [nt(APrime)], NewBeta) ),
                    NewARules),
            findall(rule(APrime, NewAlpha),
                    ( member(Alpha, Alphas),
                      append(Alpha, [nt(APrime)], NewAlpha) ),
                    NewAPrimeRules),
            append([GWithoutA, NewARules, NewAPrimeRules, [rule(APrime, [])]],
                   NewG)
        )
    ).

fresh_name(A, APrime) :- atom_concat(A, '_p', APrime).

replace_first(G, Ai, Aj, NewG) :-
    partition(
        [R]>>(R = rule(Ai, [nt(Aj) | _])),
        G, ToReplace, Untouched),
    findall(rule(Ai, NewRHS),
            ( member(rule(Ai, [nt(Aj) | Gamma]), ToReplace),
              member(rule(Aj, Delta), G),
              append(Delta, Gamma, NewRHS) ),
            ExpandedRules),
    append(Untouched, ExpandedRules, NewG).

eliminate_lr(NTs, G, NewG) :-
    eliminate_lr_loop(NTs, [], G, NewG).

eliminate_lr_loop([], _, G, G).
eliminate_lr_loop([Ai | Rest], Done, G, NewG) :-
    substitute_done(Done, Ai, G, G1),
    eliminate_direct_lr(Ai, G1, G2),
    eliminate_lr_loop(Rest, [Ai | Done], G2, NewG).

substitute_done([], _, G, G).
substitute_done([Aj | Rest], Ai, G, NewG) :-
    replace_first(G, Ai, Aj, G1),
    substitute_done(Rest, Ai, G1, NewG).

% --- Pretty printing / Друк граматики ---

show_grammar(Title, G) :-
    format("~n~w~n", [Title]),
    forall(member(rule(NT, RHS), G),
           ( rhs_atom(RHS, R),
             format("  ~w -> ~w~n", [NT, R]) )).

rhs_atom([], 'epsilon').
rhs_atom(RHS, Atom) :-
    RHS \= [],
    maplist(sym_atom, RHS, Atoms),
    atomic_list_concat(Atoms, ' ', Atom).

sym_atom(t(T),  T).
sym_atom(nt(N), N).

% --- Reading helpers / Допоміжне читання ---

read_tokens(Tokens) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " \t", " \t", Parts),
    exclude(=(""), Parts, Tokens).

read_atoms(Atoms) :-
    read_tokens(Parts),
    maplist(atom_string, Atoms, Parts).

% Read rules until empty line.
% Format: "LHS sym sym ..."  (sym is non-terminal if in NTs, else terminal)
% "epsilon" or "eps" as the sole RHS token denotes empty RHS.
read_rules(NTs, Rules) :-
    read_line_to_string(user_input, Line),
    (   Line == ""
    ->  Rules = []
    ;   split_string(Line, " \t", " \t", Parts0),
        exclude(=(""), Parts0, Parts),
        maplist(atom_string, Tokens, Parts),
        (   Tokens = [LHS | RHSToks],
            member(LHS, NTs)
        ->  (   RHSToks = [Eps], (Eps == epsilon ; Eps == eps)
            ->  RHS = []
            ;   maplist(to_sym(NTs), RHSToks, RHS)
            ),
            read_rules(NTs, Rest),
            Rules = [rule(LHS, RHS) | Rest]
        ;   format("  (LHS не з нетерміналів або порожньо) пропущено~n"),
            read_rules(NTs, Rules)
        )
    ).

to_sym(NTs, Tok, nt(Tok)) :- member(Tok, NTs), !.
to_sym(_,   Tok, t(Tok)).

% --- Grammar acquisition ---

get_grammar(NTs, G) :-
    nl,
    format("Режим:~n"),
    format("  1 — preset (g1: арифм. вираз; g2: непряма ЛР; g3: без ЛР)~n"),
    format("  2 — ручний ввід граматики~n"),
    format("Вибір [1/2]: "),
    read_line_to_string(user_input, Mode),
    (   Mode == "1"
    ->  format("Назва preset (g1/g2/g3): "),
        read_line_to_string(user_input, NameStr),
        atom_string(Name, NameStr),
        (   grammar_preset(Name, NTs, G)
        ->  true
        ;   format("Невідома назва.~n"), fail
        )
    ;   Mode == "2"
    ->  format("Нетермінали в порядку для алгоритму (через пробіл): "),
        read_atoms(NTs),
        (   NTs = []
        ->  format("Треба щонайменше один нетермінал.~n"), fail
        ;   true
        ),
        format("Правила, по одному на рядок:~n"),
        format("  LHS sym sym ...   (LHS з нетерміналів; sym, що є серед нетерміналів, — нетермінал; інакше термінал)~n"),
        format("  Для ε-правила: \"LHS epsilon\"~n"),
        format("  Порожній рядок — завершити.~n"),
        read_rules(NTs, G)
    ;   format("Невідомий режим.~n"), fail
    ).

% --- Main ---

main :-
    format("Task 4 (Variant 3): виявлення і усунення лівої рекурсії~n"),
    format("~`-t~65|~n"),
    (   get_grammar(NTs, G)
    ->  show_grammar("Вхідна граматика:", G),

        findall(A, (member(A, NTs), left_recursive(G, A)),       LRs),
        findall(A, (member(A, NTs), direct_lr(G, A)),            DLRs),
        findall(A, (member(A, NTs), left_recursive(G, A),
                                    \+ direct_lr(G, A)),         ILRs),
        format("~nЛіво-рекурсивні нетермінали (будь-які):  ~w~n", [LRs]),
        format("  лише пряма:    ~w~n", [DLRs]),
        format("  лише непряма:  ~w~n", [ILRs]),

        eliminate_lr(NTs, G, NewG),
        show_grammar("Після усунення лівої рекурсії:", NewG),

        findall(A, (member(rule(A, _), NewG), left_recursive(NewG, A)),
                AfterLRs),
        sort(AfterLRs, AfterLRsSorted),
        format("~nПеревірка: ліво-рекурсивні у результаті: ~w~n", [AfterLRsSorted])
    ;   true
    ).
