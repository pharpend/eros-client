module Text.Eros.Client where

import Data.Text.Lazy (Text)
import Text.Eros

-- |Okay, here's a function that actually does something. It takes an
-- 'ClientInput' type, and process it.
processClientInput :: ClientInput -> IO ClientOutput
processClientInput (ClientInput txt lists _) = do
    outLists <- mapM listPair lists
    return $ ClientOutput outLists
  where
    listPair :: ErosList -> IO (ErosList, Score)
    listPair ls = do
      pmap <- loadPhraseMap ls
      let scr = messageScore txt pmap
      return (ls, scr)

-- |We represent the input data in its own data type. This is needed
-- for JSON parsing, but it will also be useful down the road, when I
-- allow input that isn't JSON.
data ClientInput = ClientInput { text          :: Text
                               , erosLists     :: [ErosList]
                               , configuration :: ClientConf
                               }

-- |This is the output data type. I will make an instance of ToJSON
-- for this data type. Again, at the start, only JSON input and output
-- is existent.
data ClientOutput = ClientOutput { elScore  :: [(ErosList, Score)]
                                 }

-- |Configuration for the client
data ClientConf = ClientConf { ignoreStdin :: Bool
                             , pretty      :: Bool
                             , quiet       :: Bool
                             , inputFiles  :: [FilePath]
                             , outputFiles :: [FilePath]
                             }

-- |No configuration.
nullConf :: ClientConf
nullConf = ClientConf False False False [] []

-- |It's convenient to think of Scores as Scores, although, they are
-- truly ints.
type Score = Int
