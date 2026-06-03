-- Задача 3 (варіант 16)
-- Для заданих слів v і w виявити, чи допускає скінчений автомат хоча б
-- одне слово, що може бути подане у вигляді xvxw для деякого слова x.
-- При ствердній відповіді навести приклад відповідного слова xvxw.

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Data.Map.Strict (Map)
import Data.Set (Set)
import Data.Maybe (listToMaybe)
import System.IO (hSetEncoding, stdin, stdout, utf8, hFlush)

-- DFA: states, alphabet, transition, start, accept
data DFA = DFA
  { dfaStates   :: [Int]
  , dfaAlphabet :: [Char]
  , dfaDelta    :: Map (Int, Char) Int
  , dfaStart    :: Int
  , dfaAccept   :: Set Int
  }

step :: DFA -> Int -> Char -> Int
step d q c = dfaDelta d Map.! (q, c)

runOn :: DFA -> Int -> String -> Int
runOn d = foldl (step d)

isAccepted :: DFA -> String -> Bool
isAccepted d s = Set.member (runOn d (dfaStart d) s) (dfaAccept d)

bfsPairs :: DFA -> (Int, Int) -> Map (Int, Int) String
bfsPairs d start = go (Map.singleton start "") [start]
  where
    sigma = dfaAlphabet d
    go visited []     = visited
    go visited (p:qs) =
      let (s1, s2) = p
          xSoFar   = visited Map.! p
          fresh    = [ (np, a) | a <- sigma
                               , let np = (step d s1 a, step d s2 a)
                               , not (Map.member np visited) ]
          visited' = foldr (\(np, a) m -> Map.insert np (xSoFar ++ [a]) m)
                           visited fresh
          qs'      = qs ++ map fst fresh
      in go visited' qs'

findX :: DFA -> String -> String -> Maybe String
findX d v w = listToMaybe $ do
  q1 <- dfaStates d
  let q2    = runOn d q1 v
      reach = bfsPairs d (dfaStart d, q2)
  ((s1, s2), x) <- Map.toList reach
  if s1 == q1 && Set.member (runOn d s2 w) (dfaAccept d)
    then return x
    else []

mkDFA :: [Int] -> [Char] -> [((Int, Char), Int)] -> Int -> [Int] -> DFA
mkDFA qs sigma trans q0 fs = DFA qs sigma (Map.fromList trans) q0 (Set.fromList fs)

-- --- Preset DFAs ---

-- M1: над {a,b}, приймає слова з підрядком "aa"
dfaContainsAA :: DFA
dfaContainsAA = mkDFA [0,1,2] "ab"
  [ ((0,'a'),1), ((0,'b'),0)
  , ((1,'a'),2), ((1,'b'),0)
  , ((2,'a'),2), ((2,'b'),2)
  ] 0 [2]

-- M2: над {a,b}, приймає слова парної довжини
dfaEvenLen :: DFA
dfaEvenLen = mkDFA [0,1] "ab"
  [ ((0,'a'),1), ((0,'b'),1)
  , ((1,'a'),0), ((1,'b'),0)
  ] 0 [0]

-- M3: над {a,b}, приймає слова, що закінчуються на "ab"
dfaEndsAB :: DFA
dfaEndsAB = mkDFA [0,1,2] "ab"
  [ ((0,'a'),1), ((0,'b'),0)
  , ((1,'a'),1), ((1,'b'),2)
  , ((2,'a'),1), ((2,'b'),0)
  ] 0 [2]

-- M4: над {a,b}, приймає слова з парною кількістю символів 'a'
dfaEvenA :: DFA
dfaEvenA = mkDFA [0,1] "ab"
  [ ((0,'a'),1), ((0,'b'),0)
  , ((1,'a'),0), ((1,'b'),1)
  ] 0 [0]

presetByName :: String -> Maybe DFA
presetByName "m1" = Just dfaContainsAA
presetByName "m2" = Just dfaEvenLen
presetByName "m3" = Just dfaEndsAB
presetByName "m4" = Just dfaEvenA
presetByName _    = Nothing

-- --- IO helpers ---

prompt :: String -> IO String
prompt msg = do
  putStr msg
  hFlush stdout
  getLine

showDFA :: DFA -> IO ()
showDFA d = do
  putStrLn $ "  states:   " ++ show (dfaStates d)
  putStrLn $ "  alphabet: " ++ show (dfaAlphabet d)
  putStrLn $ "  start:    " ++ show (dfaStart d)
  putStrLn $ "  accept:   " ++ show (Set.toList (dfaAccept d))
  putStrLn   "  delta:"
  mapM_ (\((q,c),q') -> putStrLn $ "    " ++ show q ++ " --" ++ [c] ++ "--> " ++ show q')
        (Map.toAscList (dfaDelta d))

-- --- Manual DFA input ---

readManualDFA :: IO DFA
readManualDFA = do
  alphaLine <- prompt "Алфавіт (символи через пробіл, напр. a b): "
  let sigma = [c | tok <- words alphaLine, [c] <- [tok]]
  statesLine <- prompt "Стани (цілі через пробіл, напр. 0 1 2): "
  let states = map read (words statesLine) :: [Int]
  startLine <- prompt "Початковий стан: "
  let start = read startLine :: Int
  acceptLine <- prompt "Прийнятні стани (через пробіл): "
  let accept = map read (words acceptLine) :: [Int]
  putStrLn "Переходи, по одному на рядок у форматі \"стан символ наступний\","
  putStrLn "порожній рядок — завершити:"
  trans <- readTransitions
  return (mkDFA states sigma trans start accept)

readTransitions :: IO [((Int, Char), Int)]
readTransitions = do
  line <- getLine
  if null line
    then return []
    else do
      case words line of
        [qs, [c], qs'] -> do
          let q  = read qs  :: Int
              q' = read qs' :: Int
          rest <- readTransitions
          return (((q, c), q') : rest)
        _ -> do
          putStrLn "  (помилка формату, пропущено)"
          readTransitions

-- --- Modes ---

readDFA :: IO (Maybe DFA)
readDFA = do
  putStrLn ""
  putStrLn "Режим:"
  putStrLn "  1 — preset DFA (m1: містить \"aa\"; m2: парна довжина; m3: закінчується на \"ab\"; m4: парна кількість 'a')"
  putStrLn "  2 — ручний ввід DFA"
  modeLine <- prompt "Вибір [1/2]: "
  case modeLine of
    "1" -> do
      name <- prompt "Назва preset DFA (m1/m2/m3/m4): "
      case presetByName name of
        Just d  -> return (Just d)
        Nothing -> do
          putStrLn "Невідома назва."
          return Nothing
    "2" -> Just <$> readManualDFA
    _   -> do
      putStrLn "Невідомий режим."
      return Nothing

main :: IO ()
main = do
  hSetEncoding stdout utf8
  hSetEncoding stdin  utf8
  putStrLn "Задача 3: чи приймає DFA слово виду xvxw"
  putStrLn (replicate 55 '-')
  mdfa <- readDFA
  case mdfa of
    Nothing -> return ()
    Just d  -> do
      putStrLn "Обраний автомат:"
      showDFA d
      v <- prompt "Введи v: "
      w <- prompt "Введи w: "
      case findX d v w of
        Nothing -> putStrLn "  Немає такого x: жодне слово xvxw не приймається."
        Just x  -> do
          let word = x ++ v ++ x ++ w
          putStrLn $ "  Знайдено x = " ++ show x
          putStrLn $ "  xvxw       = " ++ show word
          putStrLn $ "  Перевірка (accepted?): " ++ show (isAccepted d word)
