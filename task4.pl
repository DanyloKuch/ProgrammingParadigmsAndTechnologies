% Task 4 (Variant 3) / Задача 4 (варіант 3)
% Detect left-recursive non-terminals and eliminate left recursion
% Виявити ліво-рекурсивні нетермінали та виконати усунення
% (both direct and indirect).
% лівої рекурсії (як пряму, так і непряму).
%
% Algorithm (Aho-Sethi-Ullman) / Алгоритм (Ахо-Сеті-Ульман):
%   Fix some order of non-terminals  A1, A2, ..., An.
%   Зафіксуємо порядок нетерміналів A1, A2, ..., An.
%   For i = 1..n:
%     For j = 1..i-1:
%       For every production  Ai -> Aj γ  in the grammar:
%         remove it; for every  Aj -> δ  add  Ai -> δ γ.
%     Eliminate direct left recursion in Ai by the standard
%     Усунути пряму ліву рекурсію в Ai стандартним перетворенням:
%     transformation:
%       Ai  -> Ai α1 | ... | Ai αm | β1 | ... | βp
%       ===>
%       Ai  -> β1 Ai'    | ... | βp Ai'
%       Ai' -> α1 Ai'    | ... | αm Ai' | ε
%   After processing Ai, every production whose first non-terminal is
%   Після обробки Ai кожне правило, перший нетермінал якого
%   one of A1..Ai-1 has been eliminated; the direct LR step removes
%   є серед A1..Ai-1, вже усунено; крок прямої LR прибирає Ai → Ai α.
%   Ai → Ai α.

:- initialization(main, main).
:- use_module(library(lists)).
:- use_module(library(yall)).

% --- Grammar representation / Опис граматики ---
%   Grammar is a list of terms  rule(NonTerm, RHS).
%   Граматика — список термів  rule(Нетермінал, ПраваЧастина).
%   RHS is a list of symbols where a symbol is either:
%     t(Term)   — terminal,
%     nt(NT)    — non-terminal.
%   An empty RHS  []  denotes an epsilon production / ε-правило.

% --- Example grammars / Приклади граматик ---

% G1: only direct left recursion / тільки пряма ліва рекурсія
%   E -> E + T | T
%   T -> T * F | F
%   F -> ( E ) | id
grammar(g1, ['E', 'T', 'F'], [
    rule('E', [nt('E'), t(+), nt('T')]),
    rule('E', [nt('T')]),
    rule('T', [nt('T'), t(*), nt('F')]),
    rule('T', [nt('F')]),
    rule('F', [t('('), nt('E'), t(')')]),
    rule('F', [t(id)])
]).

% G2: indirect left recursion / непряма ліва рекурсія
%   A -> B a | c
%   B -> A b | d
grammar(g2, ['A', 'B'], [
    rule('A', [nt('B'), t(a)]),
    rule('A', [t(c)]),
    rule('B', [nt('A'), t(b)]),
    rule('B', [t(d)])
]).

% G3: no left recursion at all / зовсім без лівої рекурсії
%   S -> a S | b
grammar(g3, ['S'], [
    rule('S', [t(a), nt('S')]),
    rule('S', [t(b)])
]).

% --- Detection of left recursion / Виявлення лівої рекурсії ---
%
% direct_lr(+G, ?A): A has a rule  A -> A γ.
% A має правило вигляду  A -> A γ.
direct_lr(G, A) :-
    member(rule(A, [nt(A) | _]), G).

% left_recursive(+G, ?A): A =>+ A γ for some γ
% A =>+ A γ для деякого γ (пряма або непряма ліва рекурсія).
left_recursive(G, A) :-
    left_reach(G, A, A, [A]).

% left_reach(+G, +From, ?To, +Visited)
left_reach(G, From, To, _) :-
    member(rule(From, [nt(To) | _]), G).
left_reach(G, From, To, Visited) :-
    member(rule(From, [nt(C) | _]), G),
    C \== To,
    \+ member(C, Visited),
    left_reach(G, C, To, [C | Visited]).

% --- Direct left-recursion elimination for one non-terminal ---
% --- Усунення прямої лівої рекурсії для одного нетермінала ---

eliminate_direct_lr(A, G, NewG) :-
    findall(Alpha,  member(rule(A, [nt(A) | Alpha]), G), Alphas),
    findall(Beta,
            ( member(rule(A, Beta), G),
              \+ Beta = [nt(A) | _] ),
            Betas),
    (   Alphas == []
    ->  NewG = G            % no direct LR — leave grammar untouched
    ;   ( Betas == []
        ->  format("WARNING: ~w has only left-recursive rules — grammar generates nothing.~n", [A]),
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

% --- Substituting expansions of Aj into  Ai -> Aj γ  ---
% replace_first(+G, +Ai, +Aj, -NewG)
% For every rule  Ai -> Aj γ:  remove it; for every  Aj -> δ
% add  Ai -> δ γ.  All other rules untouched.
% Для кожного правила  Ai -> Aj γ:  видалити; для кожного  Aj -> δ
% додати  Ai -> δ γ.

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

% --- Full elimination algorithm / Повний алгоритм усунення ---
% eliminate_lr(+OrderedNTs, +Grammar, -NewGrammar)

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

% --- One full report for a grammar / Повний звіт по граматиці ---

report(Name) :-
    grammar(Name, NTs, G),
    format("~n========== Grammar ~w ==========~n", [Name]),
    show_grammar("Original grammar:", G),

    findall(A, (member(A, NTs), left_recursive(G, A)),       LRs),
    findall(A, (member(A, NTs), direct_lr(G, A)),            DLRs),
    findall(A, (member(A, NTs), left_recursive(G, A),
                                \+ direct_lr(G, A)),         ILRs),
    format("~nLeft-recursive non-terminals (any):  ~w~n", [LRs]),
    format("  direct only:    ~w~n", [DLRs]),
    format("  indirect only:  ~w~n", [ILRs]),

    eliminate_lr(NTs, G, NewG),
    show_grammar("After elimination of left recursion:", NewG),

    % verify: no rule has left recursion in the resulting grammar
    findall(A, (member(rule(A, _), NewG), left_recursive(NewG, A)), AfterLRs),
    sort(AfterLRs, AfterLRsSorted),
    format("~nVerification: left-recursive in result: ~w~n", [AfterLRsSorted]).

% --- Main ---

main :-
    format("Task 4 (Variant 3): detect and eliminate left recursion~n"),
    format("~`-t~65|~n"),
    report(g1),
    report(g2),
    report(g3).
