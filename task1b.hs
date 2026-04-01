import System.IO

-- Залишити у списку елементи у позиціях, що відповідають квадратам цілих чисел.
-- Позиції: 1, 4, 9, 16, 25, 36, ...

keepAtSquarePositions :: [Int] -> [Int]
keepAtSquarePositions xs = [x | (i, x) <- zip [1..] xs, isSquare i]
  where
    isSquare n = let s = floor (sqrt (fromIntegral n :: Double))
                 in s * s == n

isValidInput :: String -> Bool
isValidInput s = all (\c -> c == ' ' || c == '-' || c `elem` "0123456789") s

main :: IO ()
main = do
    hSetEncoding stdout utf8
    putStrLn "Задача 1-б: Залишити елементи на позиціях-квадратах (1, 4, 9, 16, ...)"
    putStrLn "Введи числа через пробіл:"
    line <- getLine
    case isValidInput line of
        False -> putStrLn "Помилка! Можна вводити тільки числа!"
        True -> do
            let xs = map read (words line) :: [Int]
            putStrLn "Результат:"
            print (keepAtSquarePositions xs)