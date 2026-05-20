-- Task 4 / Задача 4
-- Recursive-descent parser for a Koreniak-Hopcroft grammar:
-- кожне правило кожного нетермінала починається з термінала, причому
-- ці перші термінали різні для всіх правил одного нетермінала.
--
-- Граматика задається відображенням: нетермінал -> список правих частин,
-- де права частина — послідовність символів (термінал = Char, нетермінал = String).

import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map)
import Data.List (intercalate)
import System.IO (hSetEncoding, stdin, stdout, utf8, hFlush)

data Sym = T Char | N String deriving (Eq, Show)

type Grammar = Map String [[Sym]]

data Tree = Leaf Char | Node String [Tree]

instance Show Tree where
  show (Leaf c)     = [c]
  show (Node n cs)  = n ++ "[" ++ intercalate "," (map show cs) ++ "]"

pretty :: Tree -> String
pretty = go 0
  where
    go d (Leaf c)    = replicate (d*2) ' ' ++ "'" ++ [c] ++ "'\n"
    go d (Node n cs) = replicate (d*2) ' ' ++ n ++ "\n" ++
                       concatMap (go (d+1)) cs

parseN :: Grammar -> String -> String -> Either String (Tree, String)
parseN g nt input =
  case Map.lookup nt g of
    Nothing    -> Left $ "Невідомий нетермінал: " ++ nt
    Just prods ->
      case input of
        []      -> Left $ "Несподіваний кінець вводу при розборі " ++ nt
        (c:_)   ->
          case [p | p@(T t : _) <- prods, t == c] of
            []     -> Left $ "Немає правила для " ++ nt ++ ", що починається з '" ++ [c] ++ "'"
            (p:_)  -> parseProd g nt p input

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
parseSym _ (T c) []      = Left $ "Очікувалось '" ++ [c] ++ "', а ввід вичерпано"
parseSym _ (T c) (x:xs)
  | c == x    = Right (Leaf c, xs)
  | otherwise = Left $ "Очікувалось '" ++ [c] ++ "', отримано '" ++ [x] ++ "'"
parseSym g (N nt) inp    = parseN g nt inp

parse :: Grammar -> String -> String -> Either String Tree
parse g start input = do
  (tree, rest) <- parseN g start input
  case rest of
    [] -> Right tree
    _  -> Left $ "Залишився непрочитаний ввід: " ++ show rest

-- --- Preset grammars / Готові граматики ---

-- G1:  E -> ( T ) | n         T -> + E | - E
preset1 :: (Grammar, String)
preset1 =
  ( Map.fromList
      [ ("E", [ [T '(', N "T", T ')']
              , [T 'n']
              ])
      , ("T", [ [T '+', N "E"]
              , [T '-', N "E"]
              ])
      ]
  , "E" )

-- G2:  S -> a A | b           A -> c S | d
preset2 :: (Grammar, String)
preset2 =
  ( Map.fromList
      [ ("S", [ [T 'a', N "A"]
              , [T 'b']
              ])
      , ("A", [ [T 'c', N "S"]
              , [T 'd']
              ])
      ]
  , "S" )

presetByName :: String -> Maybe (Grammar, String)
presetByName "g1" = Just preset1
presetByName "g2" = Just preset2
presetByName _    = Nothing

showGrammar :: Grammar -> IO ()
showGrammar g = mapM_ showRule (Map.toAscList g)
  where
    showRule (nt, prods) =
      putStrLn $ "  " ++ nt ++ " -> " ++ intercalate " | " (map showRHS prods)
    showRHS = unwords . map showSym
    showSym (T c)  = [c]
    showSym (N nt) = nt

-- --- IO helpers ---

prompt :: String -> IO String
prompt msg = do
  putStr msg
  hFlush stdout
  getLine

-- --- Manual grammar input ---
-- Користувач задає список нетерміналів, потім стартовий символ,
-- потім рядки виду "LHS sym sym ..." (порожній рядок завершує).
-- Кожен sym, що збігається з ім'ям нетермінала — нетермінал, інакше — термінал
-- (має бути рівно одним символом).

readManualGrammar :: IO (Maybe (Grammar, String))
readManualGrammar = do
  ntLine <- prompt "Нетермінали (імена через пробіл, напр. E T): "
  let nts = words ntLine
  if null nts
    then do
      putStrLn "Потрібен щонайменше один нетермінал."
      return Nothing
    else do
      start <- prompt "Стартовий нетермінал: "
      if start `notElem` nts
        then do
          putStrLn "Стартовий символ повинен бути серед нетерміналів."
          return Nothing
        else do
          putStrLn "Правила, по одному на рядок: \"LHS sym sym ...\""
          putStrLn "Нетермінали — як у списку, термінали — будь-які 1-символьні токени."
          putStrLn "Порожній рядок — завершити:"
          rules <- readRules nts
          return (Just (foldr addRule Map.empty rules, start))
  where
    addRule (lhs, rhs) g = Map.insertWith (++) lhs [rhs] g

readRules :: [String] -> IO [(String, [Sym])]
readRules nts = do
  line <- getLine
  if null line
    then return []
    else case words line of
      []     -> readRules nts
      [_]    -> do
        putStrLn "  (треба хоч один символ у RHS) пропущено"
        readRules nts
      (lhs:rhsToks) ->
        if lhs `notElem` nts
          then do
            putStrLn $ "  (LHS '" ++ lhs ++ "' не є нетерміналом) пропущено"
            readRules nts
          else case mapM (toSym nts) rhsToks of
            Nothing -> do
              putStrLn "  (термінал має бути 1 символом) пропущено"
              readRules nts
            Just rhs -> do
              rest <- readRules nts
              return ((lhs, rhs) : rest)

toSym :: [String] -> String -> Maybe Sym
toSym nts tok
  | tok `elem` nts = Just (N tok)
  | length tok == 1 = Just (T (head tok))
  | otherwise = Nothing

-- --- Mode ---

readGrammar :: IO (Maybe (Grammar, String))
readGrammar = do
  putStrLn ""
  putStrLn "Режим:"
  putStrLn "  1 — preset (g1: E->(T)|n, T->+E|-E ; g2: S->aA|b, A->cS|d)"
  putStrLn "  2 — ручний ввід граматики"
  modeLine <- prompt "Вибір [1/2]: "
  case modeLine of
    "1" -> do
      name <- prompt "Назва preset граматики (g1/g2): "
      case presetByName name of
        Just gs -> return (Just gs)
        Nothing -> do
          putStrLn "Невідома назва."
          return Nothing
    "2" -> readManualGrammar
    _   -> do
      putStrLn "Невідомий режим."
      return Nothing

main :: IO ()
main = do
  hSetEncoding stdout utf8
  hSetEncoding stdin  utf8
  putStrLn "Task 4: recursive-descent parser (Koreniak-Hopcroft grammar)"
  putStrLn (replicate 65 '-')
  mgs <- readGrammar
  case mgs of
    Nothing -> return ()
    Just (g, start) -> do
      putStrLn "Граматика:"
      showGrammar g
      putStrLn $ "Стартовий нетермінал: " ++ start
      input <- prompt "Введи рядок для розбору: "
      case parse g start input of
        Left err -> putStrLn $ "  ПОМИЛКА РОЗБОРУ: " ++ err
        Right tr -> do
          putStrLn "  ПРИЙНЯТО. Дерево розбору:"
          mapM_ (putStrLn . ("    " ++)) (lines (pretty tr))
