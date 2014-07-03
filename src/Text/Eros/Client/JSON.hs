{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module Text.Eros.Client.JSON where

import           Control.Applicative
import           Control.Monad (mzero)
import           Data.Aeson hiding (encode)
import qualified Data.Aeson as Aeson
import           Data.Aeson.Encode.Pretty
import qualified Data.ByteString.Lazy as B
import qualified Data.Text.Lazy as L
import           Text.Eros
import           Text.Eros.Client

-- |This will print JSON in a pretty matter, using 2-space indents. I
-- have no idea why 4-space indents are the default.
encode :: ToJSON a => a -> ClientConf ->  B.ByteString
encode val conf = case (pretty conf) of
                    True -> encodePretty' defConfig { confIndent = 2 } val
                    _    -> Aeson.encode val

-- |THIS is pretty self-explanatory
instance FromJSON ErosList where
  parseJSON (String s) = case erosListByName (L.fromStrict s) of
                           Just list -> return list
                           Nothing   -> mzero
  parseJSON _          = mzero

instance FromJSON ClientConf where
  parseJSON (Object v) = ClientConf
    <$> v .:? "pretty"       .!= False
    <*> v .:? "quiet"        .!= False
    <*> v .:? "output-files" .!= []
  parseJSON _          = mzero


-- |This is pretty self-explanatory
instance FromJSON ClientInput where
  parseJSON (Object v) = ClientInput
    <$> v .:  "text"
    <*> v .:  "eros-lists"
    <*> v .:? "options"    .!= nullConf
  parseJSON _          = mzero

-- |Pretty self-explanatory
instance ToJSON ErosList where
  toJSON el = case erosNameByList el of
                Just nom -> toJSON nom
                Nothing  -> "There's probably a bug in the JSON parsing \
                            \library Eros uses. You should file a bug \
                            \report at https://github.com/pharpend/eros/issues."

-- |Pretty self-explanatory
instance ToJSON (ErosList, Score) where
  toJSON (el, sc) = object [ "eros-list" .= el
                           , "score"     .= sc
                           ]

-- |Pretty self-explanatory
instance ToJSON ClientOutput where
  toJSON (ClientOutput elm) = toJSON elm
