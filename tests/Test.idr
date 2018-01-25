module Main

import Yaml

import Control.ST
import Control.ST.File

procs : String -> (ConsoleIO m, File m) => ST m () []
procs file = case parse yamlToplevelValue file of
                      Left err => putStrLn $ "error: " ++ err
                      Right v  => putStrLn $ show v

test : String -> (ConsoleIO m, File m) => ST m () []
test f = with ST do
          Right str <- readFile f
              | Left ferr => putStrLn (show ferr)
          procs str

main : IO ()
main = do
        run $ test "test1.yml"
        run $ test "test2.yml"
