module Main where

import           Data.Aeson
import qualified Data.ByteString.Lazy  as B
import qualified Text.Eros.Client      as Erosc
import qualified Text.Eros.Client.JSON as ErosJson
import           System.Exit
import qualified System.IO as Io


-- |So, this is the main function. Whoop de doo.  It sends the contents
-- of 'StdIO.stdin' to runBtStr.
--
-- Eventually, I'll add in command line argument parsing, and then we'll
-- have a use for the 'EroscOptions' type.
main :: IO ()
main = runBtStr =<< B.hGetContents Io.stdin

-- |attempt to 'eitherDecode' the user input
runBtStr :: B.ByteString -> IO ()
runBtStr inputBt = do
    let eitherJson = (eitherDecode inputBt) :: Either String Erosc.ClientInput
    case eitherJson of
      Left msg      -> B.hPutStr Io.stdout (encode msg) >> exitFailure
      Right ecInput -> runInput ecInput

-- |This takes the 'Erosc.ClientInput' thing and processes it.
runInput :: Erosc.ClientInput -> IO ()
runInput ipt = do
  result <- Erosc.processClientInput ipt
  let jsonText = ErosJson.encode result $ Erosc.configuration ipt
  B.hPutStr Io.stdout jsonText

