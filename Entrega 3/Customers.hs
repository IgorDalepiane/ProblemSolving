{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}
{-# LANGUAGE DeriveGeneric #-}
module Customers where

import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B

data Customer = Customer {
    customerId :: Integer,
    name :: String,
    idCNH :: String,
    programPoints :: Integer
} deriving (Generic, Show)

instance ToJSON Customer where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON Customer

menuCustomers :: IO ()
menuCustomers = do
    putStrLn "1 - Cadastrar novo cliente"
    putStrLn "2 - Alterar dados de cliente"
    putStrLn "3 - Excluir clientes"
    putStrLn "4 - Consultar cliente"
    putStrLn "0 - voltar" 
    putStrLn "Opcao: "
    option <- getLine
    if (read option) == 0 then putStrLn("Retornando...") else do selectedOptionCustumer (read option)

selectedOptionCustumer :: Int -> IO()
selectedOptionCustumer opcao | opcao == 1 = do {registerCustumer; menuCustomers} 
                     | opcao == 2 = do {readFromJSON; menuCustomers}
                     | opcao == 3 = do {readFromJSON; menuCustomers}
                     | opcao == 4 = do {readFromJSON; menuCustomers}
                     | otherwise =  do {readFromJSON; menuCustomers}

registerCustumer :: IO ()
registerCustumer = do 
    putStrLn "Para cadastrar um novo cliente preencha as informacoes abaixo:"
    putStrLn "Nome: "
    nameGet <- getLine
    putStrLn "Numero da CNH: "
    idCNHGet <- getLine
    -- mudar o id do cliente
    do writeToJSON [(Customer {customerId = 0, name = nameGet, idCNH = idCNHGet, programPoints = 0})]

writeToJSON :: [Customer] -> IO ()
writeToJSON list = do
  B.writeFile "db/customers.json" (encode list)

readFromJSON :: IO()
readFromJSON = do
  d <- (eitherDecode <$> B.readFile "db/customers.json") :: IO (Either String [Customer])
  case d of
    Left err -> putStrLn err
    Right ps -> printCustomers ps

printCustomers :: [Customer] -> IO ()
printCustomers customers = putStrLn ("\n\n\n" ++ (listCustomer customers) ++ "\n\n")

listCustomer :: [Customer] -> String
listCustomer [] = ""
listCustomer (x:xs) = toStringCustomer x ++ ['\n'] ++ listCustomer xs

toStringCustomer :: Customer -> String
toStringCustomer (Customer {customerId = i, idCNH = cnh, name = n, programPoints = pp}) = show i ++ " - " ++ cnh ++ " - " ++ n ++ " - " ++ show pp ++ "pts"


