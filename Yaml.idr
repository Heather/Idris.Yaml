module Yaml

import public Lightyear.Core
import public Lightyear.Combinators
import public Lightyear.Strings

import public Control.Monad.Identity

import public Data.SortedMap

%access public

data YamlValue = YamlString String
               | YamlNumber Float
               | YamlBool Bool
               | YamlNull
               | YamlObject (SortedMap String YamlValue)
               | YamlArray (List YamlValue) -- TODO: YamlObject

instance Show YamlValue where
    show (YamlString s)   = show s
    show (YamlNumber x)   = show x
    show (YamlBool True ) = "true"
    show (YamlBool False) = "false"
    show  YamlNull        = "null"
    show (YamlObject xs)  =
      "{" ++ intercalate ", " (map fmtItem $ SortedMap.toList xs) ++ "}"
     where
      intercalate : String -> List String -> String
      intercalate sep [] = ""
      intercalate sep [x] = x
      intercalate sep (x :: xs) = x ++ sep ++ intercalate sep xs

      fmtItem (k, v) = k ++ ": " ++ show v
    show (YamlArray  xs)  = show xs

hex : Parser Int
hex = do
    c <- map (ord . toUpper) $ satisfy isHexDigit
    pure $ if c >= ord '0' && c <= ord '9' then c - ord '0'
                                           else 10 + c - ord 'A'

hexQuad : Parser Int
hexQuad = do a <- hex
             b <- hex
             c <- hex
             d <- hex
             pure $ a * 4096 + b * 256 + c * 16 + d

specialChar : Parser Char
specialChar = do
    c <- satisfy (const True)
    case c of
        '"'  => pure '"'
        '\\' => pure '\\'
        '/'  => pure '/'
        'b'  => pure '\b'
        'f'  => pure '\f'
        'n'  => pure '\n'
        'r'  => pure '\r'
        't'  => pure '\t'
        'u'  => map chr hexQuad
        _    => fail "expected special char"

yamlString' : Parser (List Char)
yamlString' = (char '"' *!> pure Prelude.List.Nil) <|> do
  c <- satisfy (/= '"')
  if (c == '\\') then map (::) specialChar <*> yamlString'
                 else map (c ::) yamlString'

yamlString : Parser String
yamlString = char '"' *> map pack yamlString' <?> "Yaml string"

-- inspired by Haskell's Data.Scientific module
record Scientific where
  constructor MkScientific
  coefficient   : Integer
  exponent      : Integer

scientificToFloat : Scientific -> Float
scientificToFloat (MkScientific c e) = fromInteger c * exp
  where exp = if e < 0 then 1 / pow 10 (fromIntegerNat (- e))
                       else pow 10 (fromIntegerNat e)

parseScientific : Parser Scientific
parseScientific = do sign <- maybe 1 (const (-1)) `map` opt (char '-')
                     digits <- some digit
                     hasComma <- isJust `map` opt (char '.')
                     decimals <- if hasComma then some digit else pure Prelude.List.Nil
                     hasExponent <- isJust `map` opt (char 'e')
                     exponent <- if hasExponent then integer else pure 0
                     pure $ MkScientific (sign * fromDigits (digits ++ decimals))
                                         (exponent - cast (length decimals))
  where fromDigits : List (Fin 10) -> Integer
        fromDigits = foldl (\a, b => 10 * a + cast b) 0

yamlNumber : Parser Float
yamlNumber = map scientificToFloat parseScientific

yamlBool : Parser Bool
yamlBool  =  (char 't' >! string "rue"  *> return True)
         <|> (char 'f' >! string "alse" *> return False) <?> "Yaml Bool"

yamlNull : Parser ()
yamlNull = (char 'n' >! string "ull" >! return ()) <?> "Yaml Null"

||| A parser that skips whitespace without jumping over lines
yamlSpace : Monad m => ParserT m String ()
yamlSpace = skip (many $ satisfy (\c => c /= '\n' && isSpace c)) <?> "yamlSpace"

mutual
    yamlArray : Parser (List YamlValue)
    yamlArray = char '-' *!> (yamlArrayValue `sepBy` (char '-'))

    keyValuePair : Parser (String, YamlValue)
    keyValuePair = do key <- map pack (many (satisfy $ not . isSpace)) <* space
                      val <- char ':' *> yamlValue
                      pure (key, val)

    yamlObject : Parser (SortedMap String YamlValue)
    yamlObject = map fromList $ keyValuePair `sepBy` (char '\n') --(pure '\n')

    -- TODO check id indent is bigger than in array start
    yamlObjectA : Parser (SortedMap String YamlValue)
    yamlObjectA = map fromList $ keyValuePair `sepBy` (char '\n') --(pure '\n')

    yamlValue' : Parser YamlValue
    yamlValue' =  (map YamlString yamlString)
            <|> (map YamlNumber yamlNumber)
            <|> (map YamlBool   yamlBool)
            <|> (pure YamlNull <* yamlNull)
            <|>| map YamlArray  yamlArray
            <|>| map YamlObject yamlObject
            
    yamlValueA' : Parser YamlValue
    yamlValueA' =  (map YamlString yamlString)
             <|> (map YamlNumber yamlNumber)
             <|> (map YamlBool   yamlBool)
             <|> (pure YamlNull <* yamlNull)
             <|>| map YamlArray  yamlArray
             <|>| map YamlObject yamlObjectA

    yamlArrayValue : Parser YamlValue
    yamlArrayValue = space *> yamlValueA' <* space

    yamlValue : Parser YamlValue
    yamlValue = yamlSpace *> yamlValue' <* yamlSpace

yamlToplevelValue : Parser YamlValue
yamlToplevelValue = (map YamlArray yamlArray) <|> (map YamlObject yamlObject)
