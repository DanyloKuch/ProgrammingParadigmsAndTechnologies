-- Задача 2 (варіант 16)
-- Розбити заданий список на кілька підсписків, записуючи, за можливості,
-- у перший і останній по 1^1 елементів, потім у другий і передостанній
-- по 2^2 елементів, і т.д.
--
-- Розміри підсписків: 1, 1, 4, 4, 27, 27, 256, 256, ...
-- (беремо з початку і кінця по черзі)
--
-- Приклад: [1..10] -> [[1],[2,3,4,5],[6,7,8,9],[10]]
--
-- Поліморфна версія: splitSymmetric :: [a] -> [[a]]
-- Алгоритм не звертається до значень елементів (лише take/drop/length/reverse),
-- тому тип-параметр 'a' може бути будь-яким: Int, Char, String тощо.

import System.IO (hSetEncoding, stdout, stdin, utf8, hFlush)

chunkSizes :: [Int]
chunkSizes = [n^n | n <- [1..]]

-- Працює зі списком будь-якого типу завдяки параметру 'a'
splitSymmetric :: [a] -> [[a]]
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

  -- Демонстрація поліморфізму: список цілих чисел
  let nums = [1..10] :: [Int]
  putStrLn $ "Демо [Int]:    " ++ show nums
  putStrLn $ "Результат:     " ++ show (splitSymmetric nums)
  putStrLn (replicate 55 '-')

  -- Демонстрація поліморфізму: список рядків
  let strs = ["ab","bc","cd","de","ef","fg","gh","hi","ij","jk"] :: [String]
  putStrLn $ "Демо [String]: " ++ show strs
  putStrLn $ "Результат:     " ++ show (splitSymmetric strs)
  putStrLn (replicate 55 '-')

  -- Інтерактивний ввід: слова (тип [String] — довільні токени)
  line <- prompt "Введи елементи через пробіл (будь-які слова або числа): "
  let xs = words line :: [String]
  putStrLn $ "Вхід:      " ++ show xs
  putStrLn $ "Результат: " ++ show (splitSymmetric xs)
