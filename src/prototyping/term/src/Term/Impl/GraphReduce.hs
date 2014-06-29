module Term.Impl.GraphReduce (GraphReduce) where

import           Data.Functor                     ((<$>))
import           Data.IORef                       (IORef, readIORef, writeIORef, newIORef)
import           Data.Typeable                    (Typeable)
import           System.IO.Unsafe                 (unsafePerformIO)

import           Term
import           Term.Impl.Common

-- Base terms
------------------------------------------------------------------------

newtype GraphReduce v = GR {unGR :: IORef (TermView GraphReduce v)}
  deriving (Typeable)

instance Subst GraphReduce where
  var v = unview (App (Var v) [])

  subst = genericSubst

instance IsTerm GraphReduce where
  termEq = genericTermEq
  strengthen = genericStrengthen
  getAbsName = genericGetAbsName

  whnf sig t = do
    blockedT <- genericWhnf sig t
    tView <- readIORef . unGR =<< ignoreBlocking blockedT
    writeIORef (unGR t) (tView)
    return $ blockedT

  view = readIORef . unGR

  unview tView = GR <$> newIORef tView

  set = setGR

  refl = reflGR


{-# NOINLINE setGR #-}
setGR :: GraphReduce v
setGR = unsafePerformIO $ GR <$> newIORef Set

{-# NOINLINE reflGR #-}
reflGR :: GraphReduce v
reflGR = unsafePerformIO $ GR <$> newIORef Refl
