% Task 1a (variant 8) / Задача 1-а (варіант 8)
% Remove N largest elements from the list.
% Зі списку вилучити N найбільших його елементів.

:- initialization(main, main).

% --- Logic / Логіка ---

% Insert into descending sorted list / Вставка в спадно відсортований список
insert_desc(X, [], [X]) :- !.
insert_desc(X, [H|T], [X,H|T]) :- X >= H, !.
insert_desc(X, [H|T], [H|R]) :- insert_desc(X, T, R).

% Sort descending / Сортування за спаданням
sort_desc([], []).
sort_desc([H|T], Sorted) :-
    sort_desc(T, ST), insert_desc(H, ST, Sorted).

% Take first K elements / Взяти перші K елементів
take_n(0, _, []) :- !.
take_n(_, [], []) :- !.
take_n(K, [H|T], [H|R]) :- K > 0, K1 is K-1, take_n(K1, T, R).

% Remove all elements that are in Rem / Вилучити всі елементи зі списку Rem
remove_all([], _, []).
remove_all([H|T], Rem, R)     :- member(H, Rem), !, remove_all(T, Rem, R).
remove_all([H|T], Rem, [H|R]) :- remove_all(T, Rem, R).

% Main predicate / Головний предикат
% remove_n_largest(+List, +N, -Result)
remove_n_largest(List, N, Result) :-
    list_to_set(List, Unique),      % remove duplicates / прибрати дублікати
    sort_desc(Unique, Sorted),      % sort descending / відсортувати за спаданням
    take_n(N, Sorted, ToRemove),    % take N largest / взяти N найбільших
    remove_all(List, ToRemove, Result).

% --- Input / Введення ---

% Read non-negative integer / Зчитати невід'ємне ціле число
read_n(N) :-
    read_line_to_string(user_input, Line),
    (   number_string(N0, Line), integer(N0), N0 >= 0
    ->  N = N0
    ;   format("Error! Enter a non-negative integer.~nEnter N: "),
        read_n(N)
    ).

% Read list of integers / Зчитати список цілих чисел
read_list(Xs) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " \t", " \t", Parts),
    exclude(=(""), Parts, Parts1),
    (   Parts1 = []
    ->  Xs = []
    ;   (   maplist([S,X]>>(number_string(X,S), integer(X)), Parts1, Xs)
        ->  true
        ;   format("Error! Enter integers separated by spaces.~nEnter list: "),
            read_list(Xs)
        )
    ).

% --- Main / Головна програма ---
main :-
    format("Task 1a: Remove N largest elements from the list~n"),
    format("~`-t~50|~n"),
    format("Enter N: "),
    read_n(N),
    format("Enter numbers separated by spaces: "),
    read_list(Xs),
    remove_n_largest(Xs, N, Result),
    format("Result: ~w~n", [Result]).
