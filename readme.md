Idris.Yaml
----------

```haskell
test : String -> IO ()
test s = case parse yamlToplevelValue s of
  Left err => putStrLn $ "error: " ++ err
  Right v  => print v
  
main : IO ()
main = System.getArgs >>= \args => do
    test "a : \"b\""
```

warning
-------

it's not well tested and maybe needs additional work
