Idris.Yaml
----------

[![Build Status](https://travis-ci.org/Heather/Idris.Yaml.png?branch=master)](https://travis-ci.org/Heather/Idris.Yaml)

``` idris
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
```

``` yaml
name : "Synthia"
version : 0
description : "Idris Package Manager"
bdeps : - "lighyear"
        - "eternal"
        - "yaml"
rdeps :
```

out:

``` shell
{"bdeps": ["lighyear", "eternal", "yaml"], "description": "Idris Package Manager", "name": "Synthia", "rdeps": {}, "version": 0}
```
