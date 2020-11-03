import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B

data Customers = Customers {
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
    if (read option) == 0 then menu else do selectedOptionClient (read option)

selectedOptionClient :: Int -> IO()
selectedOptionClient opcao | opcao == 1 = do {readFromJSON; menuCustomers} 
                     | opcao == 2 = do {readFromJSON; menuCustomers}
                     | opcao == 3 = do {readFromJSON; menuCustomers}
                     | opcao == 4 = do {readFromJSON; menuCustomers}
                     | otherwise =  do {readFromJSON; menuCustomers}

writeToJSON :: [Customer] -> IO ()
writeToJSON list = do
  B.writeFile "db/customers.json" (encode list)

readFromJSON :: IO()
readFromJSON = do
  d <- (eitherDecode <$> B.readFile "db/customers.json") :: IO (Either String [Vehicle])
  case d of
    Left err -> putStrLn err
    Right ps -> printCustomers ps

printCustomers :: [Customer] -> IO ()
printCustomers customers = putStrLn ("\n\n\n" ++ (listCustomer customers) ++ "\n\n")

listCustomer :: [Customer] -> String
listCustomer [] = ""
listCustomer (x:xs) = toStringCustomer x ++ ['\n'] ++ listCustomer xs

toStringCustomer :: Customer -> String
toStringCustomer (Vehicle {customerId = i, idCNH = p, name = k, programPoints = cat}) = show i ++ " - " ++ p ++ " - " ++ cat ++ " - " ++ show k ++ "pts"


