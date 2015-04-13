Idris.Yaml
----------

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

<img align="left" src="http://fc02.deviantart.net/fs70/f/2012/031/3/6/yun_by_thamychan-d4o7bqo.png"/>

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
