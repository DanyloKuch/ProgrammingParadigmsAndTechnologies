% Task 4 / Задача 4
% Recursive-descent syntactic analyzer for a Koreniak-Hopcroft grammar.
% Рекурсивний синтаксичний аналізатор для граматики Кореняка-Хопкрофта.
%
% In a K-H grammar every production of every non-terminal starts with
% У граматиці К-Х кожне правило кожного нетермінала починається з
% a terminal, and these starting terminals are distinct for productions
% термінала, причому ці перші термінали різні для правил одного
% of the same non-terminal. So the first character of the input
% нетермінала. Тому перший символ залишку вхідного рядка однозначно
% uniquely determines which production must be applied.
% визначає, яке правило треба застосувати.
%
% Example grammar / Приклад граматики:
%   E -> ( T ) | n
%   T -> + E   | - E

:- initialization(main, main).

% --- Grammar encoding / Опис граматики ---
% production(NonTerminal, RHS) where RHS is a list of symbols.
% Each symbol is either t(Char) (terminal) or n(Atom) (non-terminal).

production('E', [t('('), n('T'), t(')')]).
production('E', [t('n')]).
production('T', [t('+'), n('E')]).
production('T', [t('-'), n('E')]).

% --- Parser / Парсер ---
% parse_nt(+NT, +Input, -Tree, -Rest)
%   parses non-terminal NT from Input, builds Tree, leaves Rest.

parse_nt(NT, [C|InputAfter], node(NT, Children), Rest) :-
    % find unique production for NT starting with terminal C
    production(NT, [t(C) | Tail]),
    !,                              % K-H: at most one such production
    parse_syms(Tail, InputAfter, ChildrenTail, Rest),
    Children = [leaf(C) | ChildrenTail].
parse_nt(NT, [], _, _) :-
    format("PARSE ERROR: unexpected end of input while parsing ~w~n", [NT]),
    fail.
parse_nt(NT, [C|_], _, _) :-
    format("PARSE ERROR: no rule for ~w starting with '~w'~n", [NT, C]),
    fail.

% parse_syms(+RHS, +Input, -Children, -Rest)
%   Parses the tail of a production (we have already consumed the leading
%   terminal that triggered rule selection).
%   Парсимо хвіст правила (перший термінал вже спожитий вище).

parse_syms([], Input, [], Input).
parse_syms([Sym|Syms], Input, [Tree|Trees], Rest) :-
    parse_sym(Sym, Input, Tree, Mid),
    parse_syms(Syms, Mid, Trees, Rest).

parse_sym(t(C), [C|Rest], leaf(C), Rest) :- !.
parse_sym(t(C), [X|_], _, _) :- !,
    format("PARSE ERROR: expected '~w', got '~w'~n", [C, X]),
    fail.
parse_sym(t(C), [], _, _) :- !,
    format("PARSE ERROR: expected '~w', got end of input~n", [C]),
    fail.
parse_sym(n(NT), Input, Tree, Rest) :-
    parse_nt(NT, Input, Tree, Rest).

% parse(+Start, +Input, -Tree)
%   Parses Input fully; whole input must be consumed.

parse(Start, Input, Tree) :-
    parse_nt(Start, Input, Tree, Rest),
    (   Rest = []
    ->  true
    ;   atom_chars(Extra, Rest),
        format("PARSE ERROR: extra input after parse: '~w'~n", [Extra]),
        fail
    ).

% --- Pretty printing / Друк дерева ---

pretty(Tree) :- pretty(Tree, 0).
pretty(leaf(C), D) :-
    indent(D), format("'~w'~n", [C]).
pretty(node(NT, Children), D) :-
    indent(D), format("~w~n", [NT]),
    D1 is D + 1,
    forall(member(Ch, Children), pretty(Ch, D1)).

indent(0) :- !.
indent(D) :- D > 0, write('  '), D1 is D - 1, indent(D1).

% --- Tests / Тестування ---

run_test(Label, Start, InputAtom) :-
    atom_chars(InputAtom, Input),
    format("~nTest ~w:  input = '~w'~n", [Label, InputAtom]),
    (   catch(parse(Start, Input, Tree), _, fail)
    ->  format("  ACCEPTED. Parse tree:~n"),
        pretty_indented(Tree)
    ;   true  % error already printed
    ).

pretty_indented(Tree) :- pretty_indented(Tree, 2).
pretty_indented(leaf(C), D) :-
    indent_n(D), format("'~w'~n", [C]).
pretty_indented(node(NT, Children), D) :-
    indent_n(D), format("~w~n", [NT]),
    D1 is D + 1,
    forall(member(Ch, Children), pretty_indented(Ch, D1)).

indent_n(0) :- !.
indent_n(D) :- D > 0, write('  '), D1 is D - 1, indent_n(D1).

main :-
    format("Task 4: recursive-descent parser for a Koreniak-Hopcroft grammar~n"),
    format("Grammar:  E -> ( T )  |  n        T -> + E  |  - E~n"),
    format("~`-t~65|~n"),

    % Valid inputs / Коректні слова
    run_test('1', 'E', 'n'),
    run_test('2', 'E', '(+n)'),
    run_test('3', 'E', '(-(+n))'),
    run_test('4', 'E', '(+(-(+n)))'),

    % Invalid inputs / Некоректні слова
    run_test('5', 'E', '+n'),      % E cannot start with '+'
    run_test('6', 'E', '(n)'),     % T cannot start with 'n'
    run_test('7', 'E', 'n+'),      % extra input
    run_test('8', 'E', '').        % empty input
