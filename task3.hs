-- Задача 3 (варіант 16)
-- Для заданих слів v і w виявити, чи допускає скінчений автомат хоча б
-- одне слово, що може бути подане у вигляді xvxw для деякого слова x.
-- При ствердній відповіді навести приклад відповідного слова xvxw.
--
-- Ідея алгоритму (добуток автоматів):
-- Для кожного кандидата q1 (стан після читання x із q0) обчислюємо
-- q2 = δ*(q1, v). Далі робимо BFS по парах станів (s1, s2) починаючи
-- з (q0, q2): на кожному символі a одночасно переходимо в
-- (δ(s1, a), δ(s2, a)). Якщо досягаємо такої пари (q1, q3), що
-- δ*(q3, w) ∈ F — знайдено x (шлях у BFS).

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Data.Map.Strict (Map)
import Data.Set (Set)
import Data.Maybe (listToMaybe)

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

-- BFS на парах станів. Map зберігає для кожної досяжної пари
-- найкоротший рядок x, який привів у цю пару з початкової.
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

-- Пошук x. Перебираємо кандидата q1, для кожного робимо BFS і шукаємо
-- пару (q1, q3) серед досяжних з (q0, δ*(q1, v)).
findX :: DFA -> String -> String -> Maybe String
findX d v w = listToMaybe $ do
  q1 <- dfaStates d
  let q2    = runOn d q1 v
      reach = bfsPairs d (dfaStart d, q2)
  ((s1, s2), x) <- Map.toList reach
  if s1 == q1 && Set.member (runOn d s2 w) (dfaAccept d)
    then return x
    else []

-- --- Допоміжні конструктори DFA ---
mkDFA :: [Int] -> [Char] -> [((Int, Char), Int)] -> Int -> [Int] -> DFA
mkDFA qs sigma trans q0 fs = DFA qs sigma (Map.fromList trans) q0 (Set.fromList fs)

-- Приклад автомата M1: над {a,b}, приймає слова з підрядком "aa".
-- Стани: 0 — стартовий (жодного a підряд), 1 — щойно бачили 'a',
--        2 — приймальний (вже зустрівся "aa").
dfaContainsAA :: DFA
dfaContainsAA = mkDFA [0,1,2] "ab"
  [ ((0,'a'),1), ((0,'b'),0)
  , ((1,'a'),2), ((1,'b'),0)
  , ((2,'a'),2), ((2,'b'),2)
  ] 0 [2]

-- DFA M2: над {a,b}, приймає слова парної довжини.
dfaEvenLen :: DFA
dfaEvenLen = mkDFA [0,1] "ab"
  [ ((0,'a'),1), ((0,'b'),1)
  , ((1,'a'),0), ((1,'b'),0)
  ] 0 [0]

-- DFA M3: над {a,b}, приймає слова, що закінчуються на "ab".
dfaEndsAB :: DFA
dfaEndsAB = mkDFA [0,1,2] "ab"
  [ ((0,'a'),1), ((0,'b'),0)
  , ((1,'a'),1), ((1,'b'),2)
  , ((2,'a'),1), ((2,'b'),0)
  ] 0 [2]

-- --- Testing / Тестування ---
report :: String -> DFA -> String -> String -> IO ()
report name d v w = do
  putStrLn $ "DFA: " ++ name
  putStrLn $ "  v = " ++ show v ++ ", w = " ++ show w
  case findX d v w of
    Nothing -> putStrLn "  No such x: no word xvxw is accepted."
    Just x  -> do
      let word = x ++ v ++ x ++ w
      putStrLn $ "  Found x = " ++ show x
      putStrLn $ "  xvxw   = " ++ show word
      putStrLn $ "  Check (accepted?): " ++ show (isAccepted d word)

main :: IO ()
main = do
  putStrLn "Task 3: does DFA accept a word of form xvxw"
  putStrLn (replicate 55 '-')

  -- Test 1: contains 'aa'; v='a', w='b'. Expect x='a' -> 'aaab'.
  report "M1 (contains 'aa')" dfaContainsAA "a" "b"

  -- Test 2: contains 'aa'; v='b', w='b'. Expect x='aa' -> 'aabaab'.
  report "M1 (contains 'aa')" dfaContainsAA "b" "b"

  -- Test 3: contains 'aa'; v='', w=''.   Expect x='aa' -> 'aaaa'.
  report "M1 (contains 'aa')" dfaContainsAA "" ""

  -- Test 4: even length; v='a', w=''. |xvxw|=2|x|+1 is always odd -> no x.
  report "M2 (even length)" dfaEvenLen "a" ""

  -- Test 5: ends with 'ab'; v='a', w='b'. Expect x='aa' -> 'aaaaab'.
  report "M3 (ends with 'ab')" dfaEndsAB "a" "b"
