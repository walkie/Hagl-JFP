{-# OPTIONS_GHC -fglasgow-exts #-}

module Game.Execution where

import Control.Monad.State
import Game.Definition
import Game.Lists

-----------
-- Types --
-----------

-- Game Execution State
data ExecState mv = ExecState {
    _game       :: Game mv,       -- game definition
    _players    :: [Player mv],   -- players active in game
    _numMoves   :: ByPlayer Int,  -- number of moves played by each player
    _location   :: GameTree mv,   -- current node in game tree
    _transcript :: Transcript mv, -- events so far this game (newest at head)
    _history    :: History mv     -- a summary of each game
}

-- History
type History mv = ByGame (Transcript mv, Summary mv)
type Transcript mv = [Event mv]
type Summary mv = (ByPlayer (ByTurn mv), ByPlayer Float)

data Event mv = DecisionEvent PlayerIx mv
              | ChanceEvent Int
              | PayoffEvent [Float]
              deriving (Eq, Show)

_transcripts :: History mv -> ByGame (Transcript mv)
_transcripts = fmap fst

_summaries :: History mv -> ByGame (Summary mv)
_summaries = fmap snd

_moves :: Summary mv -> ByPlayer (ByTurn mv)
_moves = fst

_payoff :: Summary mv -> ByPlayer Float
_payoff = snd

-- Player
type Name = String

data Player mv = forall s. Player Name s (Strategy mv s)
               | Name ::: Strategy mv ()

infix 0 :::

name :: Player mv -> Name
name (Player n _ _) = n
name (n ::: _) = n

instance Show (Player mv) where
  show = name
instance Eq (Player mv) where
  a == b = name a == name b
instance Ord (Player mv) where
  compare a b = compare (name a) (name b)

----------------------------------------
-- Game Execution and Strategy Monads --
----------------------------------------

newtype GameExec mv a = GameExec { unG :: StateT (ExecState mv) IO a }
newtype StratExec mv s a = StratExec { unS :: StateT s (GameExec mv) a }
type Strategy mv s = StratExec mv s mv

-- GameExec instances
instance Monad (GameExec mv) where
  return = GameExec . return
  (GameExec x) >>= f = GameExec (x >>= unG . f)

instance MonadState (ExecState mv) (GameExec mv) where
  get = GameExec get
  put = GameExec . put

instance MonadIO (GameExec mv) where
  liftIO = GameExec . liftIO

-- StratExec instances
instance Monad (StratExec mv s) where
  return = StratExec . return
  (StratExec x) >>= f = StratExec (x >>= unS . f)

instance MonadState s (StratExec mv s) where
  get = StratExec get
  put = StratExec . put

instance MonadIO (StratExec mv s) where
  liftIO = StratExec . liftIO

update :: MonadState s m => (s -> s) -> m s
update f = modify f >> get

--------------------------
-- GameMonad Type Class --
--------------------------

class MonadIO m => GameMonad m mv | m -> mv where
  getExecState :: m (ExecState mv)

instance GameMonad (GameExec mv) mv where
  getExecState = GameExec get

instance GameMonad (StratExec mv s) mv where
  getExecState = StratExec (lift getExecState)
