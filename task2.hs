-- Задача 2 (варіант 16)
-- Розбити заданий список на кілька підсписків, записуючи, за можливості,
-- у перший і останній по 1^1 елементів, потім у другий і передостанній
-- по 2^2 елементів, і т.д.
--
-- Тобто розміри підсписків: 1, 1, 4, 4, 27, 27, 256, 256, ...
-- (беремо з початку і кінця по черзі)
--
-- Приклад: список з 10 елементів [1..10], розміри: 1,1,4,4,...
--   перший    <- 1 елемент  з початку: [1]
--   останній  <- 1 елемент  з кінця:   [10]
--   другий    <- 4 елементи з початку: [2,3,4,5]
--   передост. <- 4 елементи з кінця:   [6,7,8,9]
--   -> [[1],[2,3,4,5],[6,7,8,9],[10]]

-- Послідовність розмірів: 1^1, 2^2, 3^3, ...
chunkSizes :: [Int]
chunkSizes = [n^n | n <- [1..]]

splitSymmetric :: [Int] -> [[Int]]
splitSymmetric [] = []
splitSymmetric xs = go xs chunkSizes []
  where
    go [] _ acc = reverse acc
    go ys (k:ks) acc
      | length ys <= 2 * k =
          -- залишок не можна розбити на два шматки по k -- кладемо все разом
          reverse (ys : acc)
      | otherwise =
          let front = take k ys
              rest1 = drop k ys
              back  = drop (length rest1 - k) rest1
              rest2 = take (length rest1 - k) rest1
          in go rest2 ks (back : front : acc)
    go ys [] acc = reverse (ys : acc)

-- Тести
main :: IO ()
main = do
  putStrLn "Задача 2: Розбити список симетрично по 1^1, 2^2, 3^3, ..."
  putStrLn $ replicate 55 '-'

  let xs1 = [1..10]
  putStrLn $ "Тест 1: " ++ show xs1
  putStrLn $ "  Результат: " ++ show (splitSymmetric xs1)
  putStrLn $ "  (1 з початку, 1 з кінця, 4 з початку, 4 з кінця)"

  let xs2 = [7, 9]
  putStrLn $ "Тест 2: " ++ show xs2
  putStrLn $ "  Результат: " ++ show (splitSymmetric xs2)

  let xs3 = [1..60]
  putStrLn $ "Тест 3: [1..60]"
  putStrLn $ "  Результат: " ++ show (splitSymmetric xs3)
  putStrLn $ "  (1,1,4,4,27,27 = 64 > 60, тому 27 не повні)"

  let xs4 = [] :: [Int]
  putStrLn $ "Тест 4: " ++ show xs4
  putStrLn $ "  Результат: " ++ show (splitSymmetric xs4)

  let xs5 = [99]
  putStrLn $ "Тест 5: " ++ show xs5
  putStrLn $ "  Результат: " ++ show (splitSymmetric xs5)
  putStrLn $ "  (менше ніж 2*1=2 -- кладемо все в один підсписок)"
