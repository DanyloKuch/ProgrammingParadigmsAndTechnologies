import Data.List (sort, nub)
import System.IO

-- Задача 1,1 Haskell варіант 
-- Вилучити N найбільших елементів зі списку.
-- Порядок решти елементів зберігається.

removeNLargest :: Int -> [Int] -> [Int]
removeNLargest n xs
  | n <= 0    = xs
  | null xs   = []
  | otherwise = filter (`notElem` toRemove) xs
  where
    toRemove = take n . reverse . sort . nub $ xs

isValidInput :: String -> Bool
isValidInput s = all (\c -> c == ' ' || c == '-' || c `elem` "0123456789") s

main :: IO ()
main = do
    hSetEncoding stdout utf8
    putStrLn "Задача 1-а: Вилучити N найбільших елементів зі списку"
    putStrLn "Введи N (кількість найбільших для вилучення):"
    nLine <- getLine
    case isValidInput nLine of
        False -> putStrLn "Помилка! N має бути цілим числом!"
        True -> do
            let n = read nLine :: Int
            putStrLn "Введи числа через пробіл:"
            xsLine <- getLine
            case isValidInput xsLine of
                False -> putStrLn "Помилка! Можна вводити тільки числа!"
                True -> do
                    let xs = map read (words xsLine) :: [Int]
                    putStrLn "Результат:"
                    print (removeNLargest n xs)