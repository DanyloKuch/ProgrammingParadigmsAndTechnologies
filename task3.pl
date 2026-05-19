% Task 3 (variant 16) / Задача 3 (варіант 16)
% Detect whether a DFA accepts at least one word of the form xvxw
% Виявити, чи приймає скінчений автомат хоча б одне слово виду xvxw
% for some word x; if yes, exhibit such a word.
% для деякого слова x; якщо так — навести приклад.
%
% Algorithm (product automaton + BFS on pairs of states):
% Алгоритм (добуток автоматів + BFS по парах станів):
%   For each candidate Q1 (state where reading x from Q0 may lead):
%       Q2 = δ*(Q1, V)
%       BFS in pairs (S1, S2) starting from (Q0, Q2), advancing both
%       coordinates by the same symbol. If we reach (Q1, Q3) such that
%       δ*(Q3, W) ∈ F — we found x (path of the BFS).

:- initialization(main, main).

% --- DFA encoding / Опис автоматів ---
% dfa(Name, States, Alphabet, Start, Accepts, Transitions)
% Transitions: list of (State, Symbol, NextState).

% M1: contains substring "aa" / містить підрядок "aa"
dfa(m1,
    [0, 1, 2], [a, b], 0, [2],
    [ (0,a,1), (0,b,0),
      (1,a,2), (1,b,0),
      (2,a,2), (2,b,2) ]).

% M2: even length / парна довжина
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

% --- DFA helpers / Допоміжні предикати ---

step(Trans, Q, A, Q1) :- member((Q, A, Q1), Trans).

run_from(_,     Q, [],     Q).
run_from(Trans, Q, [C|Cs], Final) :-
    step(Trans, Q, C, Q1),
    run_from(Trans, Q1, Cs, Final).

% --- BFS on pairs of states / BFS по парах станів ---
%
% bfs(+Transitions, +Alphabet, +Queue, +Visited, +TargetPred, -XReversed)
% Queue items: pair(S1, S2, RevX). RevX — символи x у зворотньому порядку
% (накопичуємо префіксом для O(1) подовження).

bfs(_, _, [pair(S1, S2, RevX) | _], _, TargetPred, RevX) :-
    call(TargetPred, S1, S2), !.
bfs(Trans, Sigma, [pair(S1, S2, RevX) | Rest], Visited, TargetPred, X) :-
    findall(pair(NS1, NS2, [A|RevX]),
            ( member(A, Sigma),
              step(Trans, S1, A, NS1),
              step(Trans, S2, A, NS2),
              \+ member((NS1, NS2), Visited) ),
            Successors),
    succ_pairs(Successors, NewPairs),
    append(Visited, NewPairs, Visited1),
    append(Rest, Successors, Queue1),
    bfs(Trans, Sigma, Queue1, Visited1, TargetPred, X).

succ_pairs([], []).
succ_pairs([pair(A, B, _)|T], [(A, B)|R]) :- succ_pairs(T, R).

% --- Main search / Основний пошук ---
%
% find_x(+DfaName, +V, +W, -X)
%   X is a word such that the DFA accepts X ++ V ++ X ++ W.
%   X — слово, для якого автомат приймає X ++ V ++ X ++ W.

find_x(Name, V, W, X) :-
    dfa(Name, States, Sigma, Q0, Accepts, Trans),
    member(Q1, States),
    run_from(Trans, Q1, V, Q2),
    InitQueue   = [pair(Q0, Q2, [])],
    InitVisited = [(Q0, Q2)],
    Target = [S1, S2]>>(
        S1 == Q1,
        run_from(Trans, S2, W, S3),
        member(S3, Accepts)
    ),
    bfs(Trans, Sigma, InitQueue, InitVisited, Target, RevX),
    reverse(RevX, X), !.

% --- Reporting / Друк результату ---

report(Name, V, W) :-
    format("~nDFA: ~w,  v = ~w,  w = ~w~n", [Name, V, W]),
    (   find_x(Name, V, W, X)
    ->  append([X, V, X, W], Word),
        format("  Found x = ~w   ->   xvxw = ~w~n", [X, Word])
    ;   format("  No such x exists for this (DFA, v, w).~n")
    ).

% --- Main / Головна програма ---

main :-
    format("Task 3: detect whether DFA accepts a word of form xvxw~n"),
    format("~`-t~55|~n"),

    % Тест 1: M1 (містить 'aa'), v='a', w='b' -> очікуємо x='a' -> "aaab"
    report(m1, [a], [b]),

    % Тест 2: M1, v='b', w='b' -> очікуємо x='aa' -> "aabaab"
    report(m1, [b], [b]),

    % Тест 3: M1, v='', w='' -> очікуємо x='aa' -> "aaaa"
    report(m1, [], []),

    % Тест 4: M2 (парна довжина), v='a', w='' -> |xvxw|=2|x|+1 непарне -> None
    report(m2, [a], []),

    % Тест 5: M3 (закінчується на 'ab'), v='a', w='b' -> очікуємо x='aa' -> "aaaaab"
    report(m3, [a], [b]).
