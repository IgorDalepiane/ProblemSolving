module Clients where

data Client = Client {
    clientId :: Integer,
    name :: String,
    idCNH :: String,
    programPoints :: Integer
} deriving (Show)


clientToString :: Client -> String
clientToString (Client {clientId = clientId, name = name, idCNH = idCNH, programPoints = lo}) = show clientId ++ " - " ++ name ++ " - " ++ idCNH ++ " - " ++ show(lo)