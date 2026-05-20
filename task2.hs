-- Задача 2 (варіант 16)
-- Розбити заданий список на кілька підсписків, записуючи, за можливості,
-- у перший і останній по 1^1 елементів, потім у другий і передостанній
-- по 2^2 елементів, і т.д.
--
-- Розміри підсписків: 1, 1, 4, 4, 27, 27, 256, 256, ...
-- (беремо з початку і кінця по черзі)
--
-- Приклад: [1..10] -> [[1],[2,3,4,5],[6,7,8,9],[10]]

import System.IO (hSetEncoding, stdout, stdin, utf8, hFlush)

chunkSizes :: [Int]
chunkSizes = [n^n | n <- [1..]]

splitSymmetric :: [Int] -> [[Int]]
splitSymmetric [] = []
splitSymmetric xs = go xs chunkSizes [] []
  where
    go [] _ fronts backs = reverse fronts ++ backs
    go ys (k:ks) fronts backs
      | length ys < 2 * k =
          reverse fronts ++ [ys] ++ backs
      | otherwise =
          let front  = take k ys
              rest1  = drop k ys
              back   = drop (length rest1 - k) rest1
              rest2  = take (length rest1 - k) rest1
          in go rest2 ks (front : fronts) (back : backs)
    go ys [] fronts backs = reverse fronts ++ [ys] ++ backs

isValidInput :: String -> Bool
isValidInput s = all (\c -> c == ' ' || c == '-' || c `elem` "0123456789") (trim s)
  where
    trim = dropWhile (`elem` " \t\r") . reverse . dropWhile (`elem` " \t\r") . reverse

prompt :: String -> IO String
prompt msg = do
  putStr msg
  hFlush stdout
  getLine

main :: IO ()
main = do
  hSetEncoding stdout utf8
  hSetEncoding stdin  utf8
  putStrLn "Задача 2: Розбити список симетрично по 1^1, 2^2, 3^3, ..."
  putStrLn (replicate 55 '-')
  line <- prompt "Введи числа через пробіл (порожньо = []): "
  if not (isValidInput line)
    then putStrLn "Помилка! Можна вводити лише цілі числа."
    else do
      let xs = map read (words line) :: [Int]
      putStrLn $ "Вхід:     " ++ show xs
      putStrLn $ "Результат: " ++ show (splitSymmetric xs)
