module KMonad.App.Parser.IO

where

import KMonad.Prelude

import KMonad.App.Invocation.Types

import KMonad.App.Types
import KMonad.App.Parser.Types
import KMonad.App.Parser.Tokenizer (loadTokens)
import KMonad.App.Parser.TokenJoiner (joinConfigIO)




-- | Parse a configuration file into a 'AppCfg' record
loadConfig :: HasLogFunc e => FilePath -> Cmd -> RIO e CfgToken
loadConfig pth cmd = do

  -- FIXME: We need to separate out the Cmd entirely from this.
  --
  -- What needs to happen:
  -- 1. We parse an invocation
  -- 2. If we need to load a config, we load it
  -- 3. We overwrite the loaded config with options from the invocation
  -- 4. We use the result to start KMonad
  --
  -- What is happening:
  -- Everything at the same time

  tks <- loadTokens pth                 -- This can throw a PErrors
  cgt <- joinConfigIO (joinCLI cmd tks) -- This can throw a JoinError

  -- Try loading the sink and src
  lf  <- view logFuncL
  -- snk <- liftIO . _snk cgt $ lf
  -- src <- liftIO . _src cgt $ lf

  -- Assemble the AppCfg record
  pure $ AppCfg
    { _keyInputCfg  = _src cgt
    , _keyOutputCfg = _snk cgt
    , _keymapCfg    = _km    cgt
    , _firstLayer   = _fstL  cgt
    , _fallThrough  = _flt   cgt
    , _allowCmd     = _allow cgt
    }
