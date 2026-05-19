% Task 3 (Variant 3) / Задача 3 (варіант 3)
% Given a natural k, list all words of length at most k that are
% Для заданого натурального k знайти всі слова довжини не більше k,
% accepted by the DFA. Output them in lexicographic (shortlex) order.
% які допускаються автоматом. Вивести їх у лексикографічному порядку.
%
% Order: shortlex — shorter words first; among words of equal length —
% Порядок: shortlex — спочатку коротші слова; серед однакової довжини —
% lexicographically by the order of symbols in the alphabet.
% лексикографічно за порядком символів алфавіту.

:- initialization(main, main).

% --- DFA encoding / Опис автомата ---
% dfa(Name, States, Alphabet, Start, Accepts, Transitions)
% Transitions: list of (State, Symbol, NextState).

% M1: contains substring "aa" / містить підрядок "aa"
dfa(m1,
    [0, 1, 2], [a, b], 0, [2],
    [ (0,a,1), (0,b,0),
      (1,a,2), (1,b,0),
      (2,a,2), (2,b,2) ]).

% M2: even length / парна довжина (порожнє слово приймається)
dfa(m2,
    [0, 1], [a, b], 0, [0],
    [ (0,a,1), (0,b,1),
      (1,a,0), (1,b,0) ]).

% M3: ends with "ab" / закінчується на "ab"
dfa(m3,
    [0, 1, 2], [a, b], 0, [2],
    [ (0,a,1), (0,b,0),
      (1,a,1), (1,b,2),
      (2,a,1), (2,b,0) ]).

% --- DFA run / Прогін автомата ---

step(Trans, Q, A, Q1) :- member((Q, A, Q1), Trans).

run_from(_,     Q, [],     Q).
run_from(Trans, Q, [C|Cs], Final) :-
    step(Trans, Q, C, Q1),
    run_from(Trans, Q1, Cs, Final).

accepts_dfa(Name, Word) :-
    dfa(Name, _, _, Q0, Accepts, Trans),
    run_from(Trans, Q0, Word, QF),
    member(QF, Accepts).

% --- Word enumeration / Перерахування слів ---
%
% word_of_length(+N, +Sigma, -Word)
%   On backtracking, generates all words of length N over Sigma in
%   На backtracking-у видає всі слова довжини N над Sigma в
%   lexicographic order (the order of Sigma defines the alphabet order).
%   лексикографічному порядку (порядок Sigma = порядок алфавіту).

word_of_length(0, _,     []).
word_of_length(N, Sigma, [C|W]) :-
    N > 0,
    N1 is N - 1,
    member(C, Sigma),
    word_of_length(N1, Sigma, W).

% --- Accepted words of length up to K / Прийняті слова довжини до K ---

accepted_up_to(Name, K, Words) :-
    dfa(Name, _, Sigma, _, _, _),
    findall(W,
            ( between(0, K, N),
              word_of_length(N, Sigma, W),
              accepts_dfa(Name, W) ),
            Words).

% --- Pretty printing of a word / Друк слова ---
% Empty word is shown as <eps>.

word_atom([],   '<eps>') :- !.
word_atom(Word, Atom) :- atomic_list_concat(Word, '', Atom).

% --- Reporting / Друк результату одного тесту ---

report(Name, K) :-
    accepted_up_to(Name, K, Words),
    length(Words, N),
    format("~nDFA ~w,  k = ~w   (~w accepted word(s)):~n", [Name, K, N]),
    (   Words = []
    ->  format("  (none)~n")
    ;   forall(member(W, Words),
               ( word_atom(W, Atom), format("  ~w~n", [Atom]) ))
    ).

% --- Main / Головна програма ---

main :-
    format("Task 3 (Variant 3): all words of length <= k accepted by DFA~n"),
    format("Order: shortlex (shorter first, then lexicographic)~n"),
    format("~`-t~65|~n"),

    % M1: contains "aa"
    report(m1, 0),    % nothing — q0 is not accepting
    report(m1, 2),    % only "aa"
    report(m1, 4),    % aa, aaa, aab, baa, aaaa, aaab, aaba, aabb, abaa, baaa, baab, bbaa

    % M2: even length
    report(m2, 4),    % "", and all words of length 2 and 4

    % M3: ends with "ab"
    report(m3, 3).    % ab, aab, bab
