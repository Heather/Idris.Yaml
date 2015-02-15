Idris.Yaml
----------

First check out idris-config https://github.com/jfdm/idris-config
which seems like mainteined more actively

code:

```haskell
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

config:

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

warning
-------

it's not well tested and maybe needs additional work
