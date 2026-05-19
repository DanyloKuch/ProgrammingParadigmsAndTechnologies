-- Task 4 / Задача 4
-- Implementation of a recursive-descent syntactic analyzer for a
-- Реалізація рекурсивного синтаксичного аналізатора для
-- Koreniak-Hopcroft grammar: every production of every non-terminal
-- граматики Кореняка-Хопкрофта: кожне правило кожного нетермінала
-- starts with a terminal symbol, and these terminals are distinct
-- починається з термінального символу, причому ці термінали різні
-- across productions of the same non-terminal.
-- для правил одного нетермінала.
--
-- The grammar is encoded as a map: non-terminal -> list of productions,
-- Граматика задається відображенням: нетермінал -> список правил,
-- where each production is the list of its right-hand-side symbols
-- де кожне правило — це список символів його правої частини
-- (the first symbol must be a terminal; the rest may be terminals
-- (перший символ обов'язково термінал; решта — термінали
-- or non-terminals).
-- або нетермінали).
--
-- Example grammar / Приклад граматики:
--   E -> ( T )  |  n
--   T -> + E    |  - E
-- Distinct first terminals: E starts with '(' or 'n'; T with '+' or '-'.

import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map)
import Data.List (intercalate)

-- A symbol is either a terminal (single character) or a non-terminal (name).
data Sym = T Char | N String deriving (Eq, Show)

-- Grammar: non-terminal name -> list of right-hand-sides (lists of Syms).
type Grammar = Map String [[Sym]]

-- Parse tree: terminal leaf or non-terminal with children.
data Tree = Leaf Char | Node String [Tree]

instance Show Tree where
  show (Leaf c)     = [c]
  show (Node n cs)  = n ++ "[" ++ intercalate "," (map show cs) ++ "]"

-- Pretty / Деревовидний друк
pretty :: Tree -> String
pretty = go 0
  where
    go d (Leaf c)    = replicate (d*2) ' ' ++ "'" ++ [c] ++ "'\n"
    go d (Node n cs) = replicate (d*2) ' ' ++ n ++ "\n" ++
                       concatMap (go (d+1)) cs

-- Parse a non-terminal from the input. Returns (tree, remaining input)
-- on success, or an error message on failure.
parseN :: Grammar -> String -> String -> Either String (Tree, String)
parseN g nt input =
  case Map.lookup nt g of
    Nothing    -> Left $ "Unknown non-terminal: " ++ nt
    Just prods ->
      case input of
        []      -> Left $ "Unexpected end of input while parsing " ++ nt
        (c:_)   ->
          -- Pick the production whose first terminal matches c.
          -- Грамматика К-Х гарантує, що такий продукт не більше одного.
          case [p | p@(T t : _) <- prods, t == c] of
            []     -> Left $ "No rule for " ++ nt ++ " starting with '" ++ [c] ++ "'"
            (p:_)  -> parseProd g nt p input
            -- (Take head; uniqueness is part of the grammar invariant.)

-- Parse a sequence of symbols (the right-hand-side of one production).
parseProd :: Grammar -> String -> [Sym] -> String -> Either String (Tree, String)
parseProd g nt prod input = do
  (children, rest) <- parseSyms g prod input
  return (Node nt children, rest)

parseSyms :: Grammar -> [Sym] -> String -> Either String ([Tree], String)
parseSyms _ []     inp = Right ([], inp)
parseSyms g (s:ss) inp = do
  (t,  inp1) <- parseSym  g s  inp
  (ts, inp2) <- parseSyms g ss inp1
  return (t:ts, inp2)

parseSym :: Grammar -> Sym -> String -> Either String (Tree, String)
parseSym _ (T c) []      = Left $ "Expected '" ++ [c] ++ "', got end of input"
parseSym _ (T c) (x:xs)
  | c == x    = Right (Leaf c, xs)
  | otherwise = Left $ "Expected '" ++ [c] ++ "', got '" ++ [x] ++ "'"
parseSym g (N nt) inp    = parseN g nt inp

-- Parse a whole input by starting from the start non-terminal and
-- requiring the entire input to be consumed.
parse :: Grammar -> String -> String -> Either String Tree
parse g start input = do
  (tree, rest) <- parseN g start input
  case rest of
    [] -> Right tree
    _  -> Left $ "Extra input after parse: " ++ show rest

-- --- Example grammar / Приклад граматики ---
--   E -> '(' T ')' | 'n'
--   T -> '+' E    | '-' E
exampleGrammar :: Grammar
exampleGrammar = Map.fromList
  [ ("E", [ [T '(', N "T", T ')']
          , [T 'n']
          ])
  , ("T", [ [T '+', N "E"]
          , [T '-', N "E"]
          ])
  ]

-- --- Tests / Тестування ---
runTest :: String -> Grammar -> String -> String -> IO ()
runTest label g start input = do
  putStrLn $ "Test " ++ label ++ ":  input = " ++ show input
  case parse g start input of
    Left err  -> putStrLn $ "  PARSE ERROR: " ++ err
    Right tr  -> do
      putStrLn   "  ACCEPTED. Parse tree:"
      mapM_ (putStrLn . ("    " ++)) (lines (pretty tr))

main :: IO ()
main = do
  putStrLn "Task 4: recursive-descent parser for a Koreniak-Hopcroft grammar"
  putStrLn "Grammar:  E -> ( T )  |  n        T -> + E  |  - E"
  putStrLn (replicate 65 '-')

  -- Valid inputs / Коректні слова
  runTest "1" exampleGrammar "E" "n"
  runTest "2" exampleGrammar "E" "(+n)"
  runTest "3" exampleGrammar "E" "(-(+n))"
  runTest "4" exampleGrammar "E" "(+(-(+n)))"

  -- Invalid inputs / Некоректні слова
  runTest "5" exampleGrammar "E" "+n"     -- E cannot start with '+'
  runTest "6" exampleGrammar "E" "(n)"    -- T cannot start with 'n'
  runTest "7" exampleGrammar "E" "n+"     -- extra input
  runTest "8" exampleGrammar "E" ""       -- empty input
