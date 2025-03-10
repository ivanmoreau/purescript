-- | This is just a simple token printer. It's not a full fledged formatter, but
-- it is used by the layout golden tests. Printing each token in the tree with
-- this printer will result in the exact input that was given to the lexer.

module Language.PureScript.CST.Print
  ( printToken
  , printTokens
  , printModule
  , printLeadingComment
  , printTrailingComment
  ) where

import Prelude

import Data.DList qualified as DList
import Data.Text (Text)
import Data.Text qualified as Text
import Language.PureScript.CST.Types (Comment(..), LineFeed(..), Module, SourceStyle(..), SourceToken(..), Token(..), TokenAnn(..))
import Language.PureScript.CST.Flatten (flattenModule)

printToken :: Token -> Text
printToken = printToken' True

-- | Prints a given Token. The bool controls whether or not layout
-- tokens should be printed.
printToken' :: Bool -> Token -> Text
printToken' showLayout = \case
  TokLeftParen             -> "("
  TokRightParen            -> ")"
  TokLeftBrace             -> "{"
  TokRightBrace            -> "}"
  TokLeftAngle             -> "<"
  TokLeftAngleClose        -> "</"
  TokRightAngle            -> ">"
  TokLeftSquare            -> "["
  TokRightSquare           -> "]"
  TokLeftArrow ASCII       -> "<-"
  TokLeftArrow Unicode     -> "←"
  TokRightArrow ASCII      -> "->"
  TokRightArrow Unicode    -> "→"
  TokRightFatArrow ASCII   -> "=>"
  TokRightFatArrow Unicode -> "⇒"
  TokDoubleColon ASCII     -> "::"
  TokDoubleColon Unicode   -> "∷"
  TokForall ASCII          -> "forall"
  TokForall Unicode        -> "∀"
  TokEquals                -> "="
  TokPipe                  -> "|"
  TokTick                  -> "`"
  TokDot                   -> "."
  TokComma                 -> ","
  TokUnderscore            -> "_"
  TokBackslash             -> "\\"
  TokLowerName qual name   -> printQual qual <> name
  TokUpperName qual name   -> printQual qual <> name
  TokOperator qual sym     -> printQual qual <> sym
  TokSymbolName qual sym   -> printQual qual <> "(" <> sym <> ")"
  TokSymbolArr Unicode     -> "(→)"
  TokSymbolArr ASCII       -> "(->)"
  TokHole hole             -> "?" <> hole
  TokChar raw _            -> "'" <> raw <> "'"
  TokString raw _          -> "\"" <> raw <> "\""
  TokRawString raw         -> "\"\"\"" <> raw <> "\"\"\""
  TokInt raw _             -> raw
  TokNumber raw _          -> raw
  TokLayoutStart           -> if showLayout then "{" else ""
  TokLayoutSep             -> if showLayout then ";" else ""
  TokLayoutEnd             -> if showLayout then "}" else ""
  TokEof                   -> if showLayout then "<eof>" else ""

printQual :: [Text] -> Text
printQual = Text.concat . map (<> ".")

printTokens :: [SourceToken] -> Text
printTokens = printTokens' True

printTokens' :: Bool -> [SourceToken] -> Text
printTokens' showLayout toks = Text.concat (map pp toks)
  where
  pp (SourceToken (TokenAnn _ leading trailing) tok) =
    Text.concat (map printLeadingComment leading)
      <> printToken' showLayout tok
      <> Text.concat (map printTrailingComment trailing)

printModule :: Module a -> Text
printModule = printTokens' False . DList.toList . flattenModule

printLeadingComment :: Comment LineFeed -> Text
printLeadingComment = \case
  Comment raw -> raw
  Space n -> Text.replicate n " "
  Line LF -> "\n"
  Line CRLF -> "\r\n"

printTrailingComment :: Comment void -> Text
printTrailingComment = \case
  Comment raw -> raw
  Space n -> Text.replicate n " "
  Line _ -> ""
