% Task 2 (variant 16) / Задача 2 (варіант 16)
% Розбити список на підсписки розміром 1^1, 2^2, 3^3, ...
% Беремо з початку і кінця по черзі.
% Приклад: [1..10] -> [[1],[2,3,4,5],[6,7,8,9],[10]]
%

:- initialization(main, main).

split_at(0, List, [], List) :- !.
split_at(_, [], [], []) :- !.
split_at(K, [H|T], [H|F], R) :-
    K > 0, K1 is K - 1, split_at(K1, T, F, R).

take_chunks([], List, [], List).
take_chunks([K|Ks], List, [Chunk|Chunks], Tail) :-
    split_at(K, List, Chunk, Rest),
    take_chunks(Ks, Rest, Chunks, Tail).

max_chunks(Half, M) :- max_chunks_(1, 0, Half, M).
max_chunks_(K, Sum, Half, M) :-
    Next is Sum + K^K,
    (   Next =< Half
    ->  K1 is K + 1, max_chunks_(K1, Next, Half, M)
    ;   M is K - 1
    ).

split_symmetric([], []) :- !.
split_symmetric(List, Result) :-
    length(List, L),
    Half is L // 2,
    max_chunks(Half, M),
    (   M =:= 0
    ->  Result = [List]
    ;   numlist(1, M, Ns),
        maplist([N, S]>>(S is N^N), Ns, Sizes),
        take_chunks(Sizes, List, Fronts, AfterFront),
        sum_list(Sizes, FrontTotal),
        MiddleLen is L - 2 * FrontTotal,
        split_at(MiddleLen, AfterFront, Middle, BackPart),
        reverse(Sizes, RSizes),
        take_chunks(RSizes, BackPart, Backs, []),
        (   MiddleLen > 0
        ->  append(Fronts, [Middle|Backs], Result)
        ;   append(Fronts, Backs, Result)
        )
    ).

parse_token(S, X) :- number_string(X, S), !.
parse_token(S, A) :- atom_string(A, S).

read_list(Xs) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " \t", " \t", Parts),
    exclude(=(""), Parts, Parts1),
    maplist(parse_token, Parts1, Xs).

main :-
    format("Task 2: Split list by 1^1, 2^2, 3^3, ... (front and back)~n"),
    format("~`-t~55|~n"),

    Nums = [1,2,3,4,5,6,7,8,9,10],
    format("Демо (числа):  ~w~n", [Nums]),
    split_symmetric(Nums, R1),
    format("Результат:     ~w~n", [R1]),
    format("~`-t~55|~n"),

    Atoms = [ab, bc, cd, de, ef, fg, gh, hi, ij, jk],
    format("Демо (атоми):  ~w~n", [Atoms]),
    split_symmetric(Atoms, R2),
    format("Результат:     ~w~n", [R2]),
    format("~`-t~55|~n"),

    format("Введи елементи через пробіл (числа або слова): "),
    read_list(Xs),
    format("Вхід:      ~w~n", [Xs]),
    split_symmetric(Xs, R3),
    format("Результат: ~w~n", [R3]).
