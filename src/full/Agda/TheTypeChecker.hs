
module Agda.TheTypeChecker
  ( checkDecls, checkDecl
  , inferExpr, checkExpr
  ) where

import Agda.TypeChecking.Rules.Decl
import Agda.TypeChecking.Rules.Term
