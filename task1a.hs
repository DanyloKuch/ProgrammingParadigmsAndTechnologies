import System.IO (hSetEncoding, stdout, utf8)

myNub :: Eq a => [a] -> [a]
myNub [] = []
myNub (x:xs) = x : myNub (filter (/= x) xs)

mySort :: Ord a => [a] -> [a]
mySort [] = []
mySort (x:xs) = mySort [a | a <- xs, a < x] ++ [x] ++ mySort [a | a <- xs, a >= x]

removeNLargest :: Int -> [Int] -> [Int]
removeNLargest n xs
    | n <= 0    = xs
    | null xs   = []
    | otherwise = filter (`notElem` toRemove) xs
  where
    uniqueSorted = reverse (mySort (myNub xs))
    toRemove = take n uniqueSorted

isValidInput :: String -> Bool
isValidInput s = all (\c -> c == ' ' || c == '-' || c `elem` "0123456789") s

main :: IO ()
main = do
    hSetEncoding stdout utf8
    putStrLn "Задача 1-а: Вилучити N найбільших елементів (без Data.List)"
    putStrLn "Введи N:"
    nLine <- getLine
    if not (isValidInput nLine) || null nLine
      then putStrLn "Помилка! Введи ціле число."
      else do
        let n = read nLine :: Int
        putStrLn "Введи числа через пробіл:"
        xsLine <- getLine
        if not (isValidInput xsLine)
          then putStrLn "Помилка! Можна вводити лише числа."
          else do
            let xs = map read (words xsLine) :: [Int]
            putStrLn "Результат:"
            print (removeNLargest n xs)