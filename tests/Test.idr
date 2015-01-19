module Main

import Yaml

import public Effects
import public Effect.StdIO
import public Effect.File

FileIO : Type -> Type -> Type
FileIO st t = { [FILE_IO st, STDIO] } Eff t 

readFile : FileIO (OpenFile Read) (List String)
readFile = readAcc [] where
  readAcc : List String -> FileIO (OpenFile Read) (List String)
  readAcc acc = if (not !eof) then readAcc $ !readLine :: acc
                              else return  $ reverse acc

procs : (List String) -> { [STDIO] } Eff ()
procs file = case parse yamlToplevelValue config of
                      Left err => putStrLn $ "error: " ++ err
                      Right v  => putStrLn $ show v
  where config = concat file

test : String -> FileIO () ()
test f = case !(open f Read) of
                True => do procs !readFile
                           close {- =<< -}
                False => putStrLn "Error!"

main : IO ()
main = do
  run $ test "test1.yml"
  run $ test "test2.yml"
