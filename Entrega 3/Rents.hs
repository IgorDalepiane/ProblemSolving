{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Rents where

import Customers
import Vehicles
import Data.Aeson
import qualified Data.ByteString.Lazy as B
import GHC.Generics

data Rents = Rents
  { rentId :: Int,
    customerRent :: Customer,
    vehicle :: Vehicle,
    rentDate, returnDate :: String,
    returned :: Bool
  }
  deriving (Generic, Show)

instance ToJSON Rents where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Rents

menuRents :: IO ()
menuRents = do
  putStrLn "1 - Cadastrar nova locacao"
  putStrLn "2 - Cadastrar devolucao"
  putStrLn "Opcao: "
  option <- getLine
  if read option == 0 then putStrLn "Retornando..." else do selectedOptionRents (read option)

selectedOptionRents :: Int -> IO ()
selectedOptionRents opcao
  | opcao == 1 = do rent
  | opcao == 2 = do devolution
  | otherwise = putStrLn "Opção inválida."

-- rent

-- getAvailableVehicles :: [Vehicle]
-- getAvailableVehicles = do
--   vehicles <- read

rent :: IO()
rent = do
  putStrLn "\n###Locar veículo###"
  putStrLn "\nCarros disponíveis: "
  -- let availableVehicles = 
  rentIdGet <- getLine
  putStrLn "\nQuilometragem rodada: "
  kmGet <- getLine
  -- read list
  listRents <- readRentFromJSON
  -- search rent
  let returnedRent = returnRent (read rentIdGet :: Int) listRents
  let listRentsUpdated = removeRent (read rentIdGet :: Int) listRents
  -- CUSTOMER
  ---- read customer
  lista <- readCustomersJSON
  let customerReturnedRent = customerRent returnedRent
  let returnedCustomer = returnItem (customerId customerReturnedRent) lista
  let listaAtualizada = removeItem (customerId customerReturnedRent) lista
  ---- change points
  let points = div (read kmGet :: Int)  100
  let customerRentUpdated = CustomerInstance {customerId = customerId returnedCustomer, customerName = customerName returnedCustomer, idCNH = idCNH returnedCustomer, programPoints = points}
  ---- add customer to list
  let listWithNewCustomer = addToList listaAtualizada customerRentUpdated
  writeCustomerToJSON listWithNewCustomer
  -- change status
  let newRent = Rents {rentId = rentId returnedRent, customerRent = customerRentUpdated, returned = True}
  let listRentsNewStatus = addToRentsList  listRentsUpdated newRent
  writeRentToJSON listRentsNewStatus
  let pointsRetunedCustomer = programPoints customerReturnedRent
  putStrLn $ "\nDevolucao realizada com sucesso, o cliente " ++ customerName customerReturnedRent ++ " esta com "++ show pointsRetunedCustomer ++" pontos no programa de fidelidade\n"

-- devolution

devolution :: IO ()
devolution = do
  putStrLn "\n\nRealizar devolucao de um veiculo"
  putStrLn "\nID da locacao: "
  rentIdGet <- getLine
  putStrLn "\nQuilometragem rodada: "
  kmGet <- getLine
  -- read list
  listRents <- readRentFromJSON
  -- search rent
  let returnedRent = returnRent (read rentIdGet :: Int) listRents
  let listRentsUpdated = removeRent (read rentIdGet :: Int) listRents
  -- CUSTOMER
  ---- read customer
  lista <- readCustomersJSON
  let customerReturnedRent = customerRent returnedRent
  let returnedCustomer = returnItem (customerId customerReturnedRent) lista
  let listaAtualizada = removeItem (customerId customerReturnedRent) lista
  ---- change points
  let points = div (read kmGet :: Int)  100
  let customerRentUpdated = CustomerInstance {customerId = customerId returnedCustomer, customerName = customerName returnedCustomer, idCNH = idCNH returnedCustomer, programPoints = points}
  ---- add customer to list
  let listWithNewCustomer = addToList listaAtualizada customerRentUpdated
  writeCustomerToJSON listWithNewCustomer
  -- change status
  let newRent = Rents {rentId = rentId returnedRent, customerRent = customerRentUpdated, returned = True}
  let listRentsNewStatus = addToRentsList  listRentsUpdated newRent
  writeRentToJSON listRentsNewStatus
  let pointsRetunedCustomer = programPoints customerReturnedRent
  putStrLn $ "\nDevolucao realizada com sucesso, o cliente " ++ customerName customerReturnedRent ++ " esta com "++ show pointsRetunedCustomer ++" pontos no programa de fidelidade\n"

-- List

addToRentsList :: [Rents] -> Rents -> [Rents]
addToRentsList [] x = [x]
addToRentsList x ve = x ++ [ve]

returnRent :: Int -> [Rents] -> Rents
returnRent _ [] = error "Nao ha uma locacao com o identificador informado!"
returnRent y (x : xs)
  | y <= 0 = x
  | otherwise = returnRent (y -1) xs

-- Remove Rent

removeRent :: Int -> [Rents] -> [Rents]
removeRent _ [] = []
removeRent x (y : ys)
  | x == rentId y = removeRent x ys
  | otherwise = y : removeRent x ys

-- JSON actions

writeRentToJSON :: [Rents] -> IO ()
writeRentToJSON list = do
  B.writeFile "db/rents.json" (encode list)

readRentFromJSON :: IO [Rents]
readRentFromJSON = do
  input <- B.readFile "db/rents.json"

  let rents = decode input :: Maybe [Rents]

  case rents of
    Nothing -> return []
    Just rents -> return rents

