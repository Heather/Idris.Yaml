module Main

import Yaml

procs : String -> IO ()
procs file = case parse yamlToplevelValue file of
                      Left err => putStrLn $ "error: " ++ err
                      Right v  => putStrLn $ show v

test : String -> IO ()
test f = case !(readFile f) of
                Right c => procs c
                Left _ => putStrLn "Error!"

main : IO ()
main = do
        test "test1.yml"
        test "test2.yml"
