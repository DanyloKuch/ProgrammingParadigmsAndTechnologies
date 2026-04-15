% Задача 1-а (варіант 8)
% Зі списку вилучити N найбільших його елементів.
% Порядок решти елементів зберігається.
% Вилучаються всі входження N найбільших унікальних значень.

% --- Допоміжні предикати ---

% Сортування за спаданням (вставкою)
insert_desc(X, [], [X]) :- !.
insert_desc(X, [H|T], [X,H|T]) :- X >= H, !.
insert_desc(X, [H|T], [H|R]) :- insert_desc(X, T, R).

sort_desc([], []).
sort_desc([H|T], Sorted) :-
    sort_desc(T, ST),
    insert_desc(H, ST, Sorted).

% Взяти перші K елементів
take(0, _, []) :- !.
take(_, [], []) :- !.
take(K, [H|T], [H|R]) :-
    K > 0, K1 is K - 1,
    take(K1, T, R).

% Вилучити з List всі елементи, що є в Remove
remove_all([], _, []).
remove_all([H|T], Remove, Result) :-
    member(H, Remove), !,
    remove_all(T, Remove, Result).
remove_all([H|T], Remove, [H|R]) :-
    remove_all(T, Remove, R).

% --- Головний предикат ---
% remove_n_largest(+List, +N, -Result)
remove_n_largest(List, N, Result) :-
    list_to_set(List, Unique),   % прибрати дублікати
    sort_desc(Unique, Sorted),   % відсортувати за спаданням
    take(N, Sorted, ToRemove),   % взяти N найбільших
    remove_all(List, ToRemove, Result).

% --- Тести ---
:- initialization(main, main).

main :-
    format("Задача 1-а: Вилучити N найбільших елементів зі списку~n"),
    format("~`-t~55|~n"),

    % Тест 1: базовий випадок
    List1 = [3,1,4,1,5,9,2,6,5,3,5],
    remove_n_largest(List1, 3, R1),
    format("Тест 1: ~w, N=3~n", [List1]),
    format("  Результат: ~w~n", [R1]),
    format("  (вилучено: 9, 6, 5)~n"),

    % Тест 2: N=0 — список не змінюється
    List2 = [4,2,7,1],
    remove_n_largest(List2, 0, R2),
    format("Тест 2: ~w, N=0~n", [List2]),
    format("  Результат: ~w~n", [R2]),

    % Тест 3: N більше за кількість унікальних значень
    List3 = [5,5,5,3,3,1],
    remove_n_largest(List3, 5, R3),
    format("Тест 3: ~w, N=5~n", [List3]),
    format("  Результат: ~w~n", [R3]),

    % Тест 4: порожній список
    remove_n_largest([], 3, R4),
    format("Тест 4: [], N=3~n"),
    format("  Результат: ~w~n", [R4]),

    % Тест 5: N=2 зі звичайного списку
    List5 = [1,2,3],
    remove_n_largest(List5, 2, R5),
    format("Тест 5: ~w, N=2~n", [List5]),
    format("  Результат: ~w~n", [R5]).
