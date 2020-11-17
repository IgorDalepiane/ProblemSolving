{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Customers where

import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import Data.List

data Customer = CustomerInstance {
    customerId, programPoints :: Int,
    cnh, name :: String
} deriving (Generic, Show)

instance ToJSON Customer where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Customer

menuCustomers :: IO ()
menuCustomers = do
  putStrLn "1 - Cadastrar novo cliente"
  putStrLn "2 - Alterar dados de cliente"
  putStrLn "3 - Excluir clientes"
  putStrLn "4 - Listar clientes"
  putStrLn "0 - voltar"
  putStrLn "Opcao: "
  option <- getLine
  if read option == 0 then putStrLn "Retornando..." else do selectedOptionCustomers (read option)

selectedOptionCustomers :: Int -> IO ()
selectedOptionCustomers opcao
  | opcao == 1 = do optionAddCustomer; menuCustomers
  | opcao == 2 = do optionUpdateCustumer; menuCustomers
  | opcao == 3 = do optionRemoveCustomer; menuCustomers
  | opcao == 4 = do lista <- readCustomersFromJSON; printCustomers lista; menuCustomers
  | otherwise = do putStrLn "\n\nInsira uma opção válida.\n"; menuCustomers

-- Add Customer
optionAddCustomer :: IO ()
optionAddCustomer = do
  putStrLn "\n\nCadastro de novo cliente"
  putStrLn "\nNome: "
  _name <- getLine
  putStrLn "\nNumero da CNH: "
  _cnh <- getLine
  lista <- readCustomersFromJSON
  let newCustomer = CustomerInstance {customerId = genCustomerId lista, name = _name, cnh = _cnh, programPoints = 0}
  let list = addCustomerToList lista newCustomer
  writeCustomerToJSON list
  putStrLn $ "\nO cliente " ++ _name ++ " foi adicionado com sucesso! \n"

genCustomerId :: [Customer] -> Int
genCustomerId [] = 0
genCustomerId x = do
  let lastCustomer = last x
  customerId lastCustomer + 1

addCustomerToList :: [Customer] -> Customer -> [Customer]
addCustomerToList [] x = [x]
addCustomerToList x ve = x ++ [ve]

-- Update Customer
optionUpdateCustumer :: IO ()
optionUpdateCustumer = do
  putStrLn "\n\nEditar um cliente"
  putStrLn "\nIdentificador do Cliente: "
  customerIdToEdit <- getLine
  lista <- readCustomersFromJSON
  
  let Just returnedCustomer = getCustomer (read customerIdToEdit :: Int) lista
  putStrLn "Editando cliente: "
  putStrLn $ listCustomer [returnedCustomer]
  
  let listaAtualizada = rmCustomer (read customerIdToEdit :: Int) lista
  putStrLn "\nNovo Nome: "
  _name <- getLine
  putStrLn "\nNovo Numero da CNH: "
  _cnh <- getLine

  let newCustomer = CustomerInstance {customerId = customerId returnedCustomer, name = _name, cnh = _cnh, programPoints = programPoints returnedCustomer}
  let list = addCustomerToList listaAtualizada newCustomer

  writeCustomerToJSON $ sortCustomerById list

  putStrLn "\nO cliente antigo: "
  putStrLn $ listCustomer [returnedCustomer]
  putStrLn "foi editado para: "
  putStrLn $ listCustomer [newCustomer]

sortCustomerById :: [Customer] -> [Customer]
sortCustomerById = sortOn customerId

-- Remove Customer
optionRemoveCustomer :: IO ()
optionRemoveCustomer = do
  putStrLn "\n\nRemocao de cliente"
  putStrLn "\nIdentificador do cliente: "
  customerIdToDelete <- getLine
  lista <- readCustomersFromJSON
  let listaAtualizada = rmCustomer (read customerIdToDelete :: Int) lista
  writeCustomerToJSON listaAtualizada
  putStrLn $ "\nO cliente com o identificador " ++ customerIdToDelete ++ " foi removido com sucesso! \n"

rmCustomer :: Int -> [Customer] -> [Customer]
rmCustomer _ [] = []
rmCustomer x (y : ys)
  | x == customerId y = rmCustomer x ys
  | otherwise = y : rmCustomer x ys

-- List Customers
getCustomer :: Int -> [Customer] -> Maybe Customer
getCustomer _ [] = Nothing
getCustomer y (x:xs)  
  | y == customerId x = Just x
  | otherwise = getCustomer y xs

printCustomers :: [Customer] -> IO ()
printCustomers customers = putStrLn ("\n\nId - CNH - Nome do cliente - Pontos de fidelidade\n\n" ++ listCustomer customers ++ "\n")

listCustomer :: [Customer] -> String
listCustomer [] = ""
listCustomer (x : xs) = toStringCustomer x ++ ['\n'] ++ listCustomer xs

toStringCustomer :: Customer -> String
toStringCustomer CustomerInstance {
  customerId    = i, 
  cnh           = cnh, 
  name          = n, 
  programPoints = pp 
} = show i  ++ " - " ++ 
    cnh     ++ " - " ++ 
    n       ++ " - " ++ 
    show pp ++ "pts"

-- JSON IO
writeCustomerToJSON :: [Customer] -> IO ()
writeCustomerToJSON list = do
  B.writeFile "db/customers.json" (encode list)

readCustomersFromJSON :: IO [Customer]
readCustomersFromJSON = do
  input <- B.readFile "db/customers.json"

  let customers = decode input :: Maybe [Customer]

  case customers of
    Nothing -> return []
    Just customers -> return customers
