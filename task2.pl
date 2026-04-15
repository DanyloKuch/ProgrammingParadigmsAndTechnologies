% Задача 2 (варіант 16)
% Розбити заданий список на кілька підсписків, записуючи, за можливості,
% у перший і останній по 1^1 елементів, потім у другий і передостанній
% по 2^2 елементів, і т.д.
%
% Розміри підсписків: 1, 1, 4, 4, 27, 27, 256, 256, ...
% (беремо з початку і кінця по черзі)

% --- Допоміжні предикати ---

% Взяти перші K елементів
take(0, _, []) :- !.
take(_, [], []) :- !.
take(K, [H|T], [H|R]) :-
    K > 0, K1 is K - 1,
    take(K1, T, R).

% Пропустити перші K елементів
drop(0, List, List) :- !.
drop(_, [], []) :- !.
drop(K, [_|T], R) :-
    K > 0, K1 is K - 1,
    drop(K1, T, R).

% --- Головний предикат ---
% split_symmetric(+List, -Result)
split_symmetric([], []) :- !.
split_symmetric(List, Result) :-
    split_go(List, 1, [], Result).

% split_go(+Rest, +N, +Acc, -Result)
split_go([], _, Acc, Result) :-
    reverse(Acc, Result).
split_go(List, N, Acc, Result) :-
    K is N ^ N,
    length(List, Len),
    Threshold is 2 * K,
    (   Len =< Threshold
    ->  reverse([List|Acc], Result)
    ;   take(K, List, Front),
        drop(K, List, Rest1),
        length(Rest1, Len1),
        DropCount is Len1 - K,
        drop(DropCount, Rest1, Back),
        take(DropCount, Rest1, Rest2),
        N1 is N + 1,
        split_go(Rest2, N1, [Back, Front|Acc], Result)
    ).

% --- Тести ---
:- initialization(main, main).

main :-
    format("Задача 2: Розбити список по 1^1, 2^2, 3^3, ...~n"),
    format("~`-t~55|~n"),

    % Тест 1: [1..10]
    numlist(1, 10, L1),
    split_symmetric(L1, R1),
    format("Тест 1: [1..10]~n"),
    format("  Результат: ~w~n", [R1]),
    format("  (1 з початку, 1 з кінця, 4 з початку, 4 з кінця)~n"),

    % Тест 2: [7, 9]
    split_symmetric([7,9], R2),
    format("Тест 2: [7,9]~n"),
    format("  Результат: ~w~n", [R2]),

    % Тест 3: [1..60]
    numlist(1, 60, L3),
    split_symmetric(L3, R3),
    format("Тест 3: [1..60]~n"),
    format("  Результат: ~w~n", [R3]),
    format("  (1,1,4,4,27,27=64>60 - залишок одним шматком)~n"),

    % Тест 4: порожній список
    split_symmetric([], R4),
    format("Тест 4: []~n"),
    format("  Результат: ~w~n", [R4]),

    % Тест 5: один елемент
    split_symmetric([99], R5),
    format("Тест 5: [99]~n"),
    format("  Результат: ~w~n", [R5]).
