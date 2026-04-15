% Задача 1-б (варіант 8)
% Залишити у списку елементи у позиціях, що відповідають квадратам цілих чисел.
% Позиції (з 1): 1, 4, 9, 16, 25, ...

% --- Головний предикат ---
% keep_squares(+List, -Result)
keep_squares(List, Result) :-
    keep_squares(List, 1, 1, Result).

% keep_squares(+Rest, +CurPos, +NextSqIdx, -Result)
keep_squares([], _, _, []).
keep_squares([H|T], Pos, SqIdx, [H|R]) :-
    Sq is SqIdx * SqIdx,
    Pos =:= Sq, !,
    NextPos is Pos + 1,
    NextSqIdx is SqIdx + 1,
    keep_squares(T, NextPos, NextSqIdx, R).
keep_squares([_|T], Pos, SqIdx, R) :-
    NextPos is Pos + 1,
    keep_squares(T, NextPos, SqIdx, R).

% --- Тести ---
:- initialization(main, main).

main :-
    format("Задача 1-б: Залишити елементи на позиціях-квадратах~n"),
    format("~`-t~55|~n"),
    format("Позиції: 1, 4, 9, 16, 25, ...~n~n"),

    % Тест 1: список [1..10]
    numlist(1, 10, L1),
    keep_squares(L1, R1),
    format("Тест 1: ~w~n", [L1]),
    format("  Результат: ~w~n", [R1]),
    format("  (позиції 1,4,9 -> елементи 1,4,9)~n"),

    % Тест 2: список [1..25]
    numlist(1, 25, L2),
    keep_squares(L2, R2),
    format("Тест 2: [1..25]~n"),
    format("  Результат: ~w~n", [R2]),
    format("  (позиції 1,4,9,16,25)~n"),

    % Тест 3: порожній список
    keep_squares([], R3),
    format("Тест 3: []~n"),
    format("  Результат: ~w~n", [R3]),

    % Тест 4: список з одного елемента
    keep_squares([42], R4),
    format("Тест 4: [42]~n"),
    format("  Результат: ~w~n", [R4]),
    format("  (позиція 1 = 1^2 -> береться)~n"),

    % Тест 5: список [1..3], тільки позиція 1 є квадратом
    numlist(1, 3, L5),
    keep_squares(L5, R5),
    format("Тест 5: ~w~n", [L5]),
    format("  Результат: ~w~n", [R5]).
