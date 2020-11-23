{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Rents where
import Customers
import Vehicles
import Data.Aeson
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import Data.List
import Data.Maybe (isNothing)
import Data.Time

data Rent = RentInstance { 
  rentId, customerRentId, vehicleRentId, vehicleKms :: Int,
  customerRentName, customerRentCNH, vehicleRentCategory, vehicleRentPlate, rentDate, returnDate :: String,
  paidValue :: Float,
  returned :: Bool
} deriving (Generic, Show)

instance ToJSON Rent where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Rent

menuRents :: IO ()
menuRents = do
  putStrLn "1 - Cadastrar nova locacao"
  putStrLn "2 - Cadastrar devolucao"
  putStrLn "3 - Listar locacoes"
  putStrLn "0 - Voltar"
  putStrLn "Opcao: "
  option <- getLine
  if read option == 0 then putStrLn "Retornando..." else do selectedOptionRents (read option)

selectedOptionRents :: Int -> IO ()
selectedOptionRents opcao
  | opcao == 1 = do rent;
  | opcao == 2 = do devolution;
  | opcao == 3 = do list <- readRentFromJSON; printRents list;
  | otherwise = putStrLn "Opcao invalida."

-- Rent

getAvailableVehicles :: [Vehicle] -> [Rent] -> [Rent] -> [Vehicle]
getAvailableVehicles [] _ _ = []
getAvailableVehicles x _ [] = x
getAvailableVehicles (x:xs) [] z = x : getAvailableVehicles xs z z
getAvailableVehicles (x:xs) (y:ys) z 
  | vehicleId x == vehicleRentId y = getAvailableVehicles xs z z
  | vehicleId x /= vehicleRentId y = getAvailableVehicles (x:xs) ys z

rent :: IO()
rent = do
  putStrLn "###Locar veiculo###"
  putStrLn "Carros disponiveis: "

  vehicles <- readVehiclesFromJSON
  rents <- readRentFromJSON

  -- getAvailableVehicles (Lista dos veiculos) (ista de rents a ser iterada) (Backup das rents)
  let availableVehicles = getAvailableVehicles vehicles rents rents
  printVehicles availableVehicles

  putStrLn "Id do veiculo a ser locado: "
  _vehicleId <- getLine
  let ve = getVehicle (read _vehicleId :: Int) availableVehicles
  
  if isNothing ve
    then do
      putStrLn "\nErro! Veiculo nao encontrado. Digite 1 para continuar ou 0 para voltar."
      opt <- getLine
      if read opt == 1 then rent else menuRents
    else do
      let Just justVe = ve 
      customers <- readCustomersFromJSON
      putStrLn "Clientes:"
      printCustomers customers
      putStrLn "Id do cliente locador: "
      _customerId <- getLine
      
      let cust = getCustomer (read _customerId :: Int) customers

      if isNothing cust
        then do
          putStrLn "\nErro! Cliente nao encontrado. Digite 1 para continuar ou 0 para voltar."
          opt <- getLine
          if read opt == 1 then rent else menuRents
        else do
          let Just justCust = cust 
          putStrLn "Data de locacao (formato: dd/mm/aaaa):"
          _date <- getLine
          let newRent = RentInstance {
            rentId              = genRentId rents, 
            customerRentId      = read _customerId :: Int , 
            vehicleRentId       = read _vehicleId :: Int,
            customerRentName    = name justCust,
            customerRentCNH     = cnh justCust,
            vehicleRentCategory = category justVe,
            vehicleRentPlate    = plate justVe,
            vehicleKms          = kms justVe,
            rentDate            = _date, 
            paidValue           = 0,
            returnDate          = "", 
            returned            = False
          }

          let listRents = addRentsToList rents newRent

          writeRentToJSON listRents

          putStrLn "\nO veiculo foi locado com sucesso. \n"

genRentId :: [Rent] -> Int
genRentId [] = 0
genRentId x = do 
              let lastRent = last x
              rentId lastRent + 1

-- devolution

devolution :: IO ()
devolution = do
  -- read list
  listRents <- readRentFromJSON
  putStrLn "\n\nRealizar devolucao de um veiculo"
  putStrLn "Locacoes em Aberto: "
  printRents $ getOpenRents listRents
  putStrLn "\nID da locacao: "
  _rentId <- getLine
  let rent = getRent (read _rentId :: Int) listRents
  
  if isNothing rent
    then do
      putStrLn "\nErro! Locacao nao encontrada. Digite 1 para continuar ou 0 para voltar."
      opt <- getLine
      if read opt == 1 then devolution else menuRents
    else do
      let Just justRent = rent 
      putStrLn "\nQuilometragem rodada: "
      kmGet <- getLine
      putStrLn "\nData de devolucao (formato: dd/mm/aaaa): "
      dateString <- getLine
      let _rentDate = parseTimeOrError True defaultTimeLocale "%d/%m/%Y" (rentDate justRent) :: Day
      let _returnDate = parseTimeOrError True defaultTimeLocale "%d/%m/%Y" dateString :: Day
      let dias = diffDays _returnDate _rentDate
      -- remove a rent atual para modificar
      let listRentsUpdated = rmRent (read _rentId :: Int) listRents
      ---- read customer
      lista <- readCustomersFromJSON
      let custId = customerRentId justRent
      let Just cust = getCustomer custId lista
      let listaAtualizada = rmCustomer custId lista
      ---- change points
      let points = div (read kmGet :: Int)  100
      let updatedCust = CustomerInstance {
        customerId = custId, 
        name = name cust, 
        cnh = cnh cust, 
        programPoints = points
      }

      -- calculate rent value
      listVeihcles <- readVehiclesFromJSON
      let vehicle = getVehicle (vehicleRentId justRent) listVeihcles
      let Just justVehicle = vehicle
      let rentValue = (fromIntegral dias * categoryPrice justVehicle) + ((read kmGet::Float) * kilometerPrice justVehicle)
      
      putStrLn $ "O valor da locacao é: R$ " ++ show rentValue
      putStrLn $ "O cliente tem (" ++ show (programPoints cust) ++ ") pontos de fidelidade a serem usados: "
      _p <- getLine
      if (read _p :: Int) <= programPoints cust
        then do
          let discount = rentValue * ((read _p :: Float) / 10000)
          let newRentValue = rentValue - discount
          putStrLn $ "Novo valor: R$ " ++ show newRentValue
          putStrLn "Continuar? 1-Sim 0-Nao"
          _op <- getLine
          if read _op == 1 then print "" else menuRents
          -- add customer to list
          let listWithNewCustomer = addCustomerToList listaAtualizada updatedCust
          writeCustomerToJSON $ sortCustomerById listWithNewCustomer
          -- change status
          let newRent = RentInstance {
            rentId              = rentId justRent, 
            customerRentId      = custId, 
            vehicleRentId       = vehicleRentId justRent,
            customerRentName    = customerRentName justRent,
            customerRentCNH     = customerRentCNH justRent,
            vehicleRentCategory = vehicleRentCategory justRent,
            vehicleRentPlate    = vehicleRentPlate justRent,
            vehicleKms          = vehicleKms justRent,
            rentDate            = rentDate justRent, 
            returnDate          = show _returnDate, 
            paidValue           = newRentValue,
            returned            = True
          }

          writeRentToJSON $ addRentsToList listRentsUpdated newRent
          putStrLn $ "\nDevolucao realizada com sucesso, o cliente " ++ name updatedCust ++ " esta com "++ show (programPoints updatedCust) ++" pontos no programa de fidelidade\n"
        else do
          putStrLn "\nErro! Voce nao possui pontos o suficiente. Digite 1 para voltar ou 0 para sair."
          opt <- getLine
          if read opt == 1 then devolution else putStrLn "Retornando..."

-- List
sortRentById :: [Rent] -> [Rent]
sortRentById = sortOn rentId

addRentsToList :: [Rent] -> Rent -> [Rent]
addRentsToList [] x = [x]
addRentsToList x ve = x ++ [ve]

getRent :: Int -> [Rent] -> Maybe Rent
getRent _ [] = Nothing
getRent y (x : xs) | y == rentId x = Just x
                   | otherwise = getRent y xs

getOpenRents :: [Rent] -> [Rent]
getOpenRents [] = []
getOpenRents (x:xs) | not (returned x) = x : getOpenRents xs 
                    | otherwise = getOpenRents xs

printRents :: [Rent] -> IO ()
printRents rents = putStrLn (listRent rents ++ "\n")

listRent :: [Rent] -> String
listRent [] = ""
listRent (x:xs) = toStringRent x ++ ['\n'] ++ listRent xs

toStringRent :: Rent -> String
toStringRent RentInstance {
  rentId              = _rentId, 
  vehicleRentId       = _vehicleRentId, 
  customerRentId      = _customerRentId, 
  vehicleKms          = _vehicleKms, 
  customerRentName    = _customerRentName, 
  customerRentCNH     = _customerRentCNH, 
  vehicleRentCategory = _vehicleRentCategory, 
  vehicleRentPlate    = _vehicleRentPlate, 
  rentDate            = _rentDate,
  returnDate          = _returnDate } = 
    "ID: "                ++ show _rentId         ++ "\n" ++
    "ID Veiculo: "        ++ show _vehicleRentId  ++ "\n" ++
    "ID Cliente: "        ++ show _customerRentId ++ "\n" ++ 
    "Quilometragem: "     ++ show _vehicleKms     ++ "\n" ++ 
    "Cliente Nome: "      ++ _customerRentName    ++ "\n" ++ 
    "Cliente CNH: "       ++ _customerRentCNH     ++ "\n" ++ 
    "Veiculo Categoria: " ++ _vehicleRentCategory ++ "\n" ++
    "Veiculo Placa: "     ++ _vehicleRentPlate    ++ "\n" ++ 
    "Data Locacao: "      ++ _rentDate            ++ "\n" ++
    "Data Retorno: "      ++ _returnDate           

-- Remove Rent

rmRent :: Int -> [Rent] -> [Rent]
rmRent _ [] = []
rmRent x (y : ys)
  | x == rentId y = rmRent x ys
  | otherwise = y : rmRent x ys

-- JSON actions

writeRentToJSON :: [Rent] -> IO ()
writeRentToJSON list = do
  B.writeFile "db/rents.json" (encode list)

readRentFromJSON :: IO [Rent]
readRentFromJSON = do
  input <- B.readFile "db/rents.json"

  let rents = decode input :: Maybe [Rent]

  case rents of
    Nothing -> return []
    Just rents -> return rents
