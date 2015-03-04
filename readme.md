Idris.Yaml
----------

``` idris
test : String -> IO ()
test s = case parse yamlToplevelValue s of
  Left err => putStrLn $ "error: " ++ err
  Right v  => print v
  
quest : (List String) -> { [STDIO] } Eff IO ()
quest file = do
    let config = concat file
    test config

compile : String -> FileIO () ()
compile f = do case !(open f Read) of
                True => do quest !readFile
                           close {- =<< -}
                False => putStrLn "Error!"

main : IO ()
main = System.getArgs >>= \args => do
    run $ compile "Synthia.syn"
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
