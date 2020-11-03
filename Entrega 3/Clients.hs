module Clients where

data Client = Client {
    clientId :: Integer,
    name :: String,
    idCNH :: String,
    programPoints :: Integer
} deriving (Show)

menuClient :: IO ()
menuClient = do
    putStrLn "1 - Cadastrar novo cliente"
    putStrLn "2 - Alterar dados de cliente"
    putStrLn "3 - Excluir clientes"
    putStrLn "4 - Consultar cliente"
    putStrLn "0 - voltar" 
    putStrLn "Opcao: "
    option <- getLine
    if (read option) == 0 then menu else do selectedOptionClient (read option)

selectedOptionClient :: Int -> IO()
selectedOptionClient opcao | opcao == 1 = do {addNewClient (Client {clientId = 2, name = "kildere", idCNH = "54648", programPoints = 5}); menu} 
                     | opcao == 2 = do {putStrLn "Opcao em Desenvolvimento"; menu}
                     | opcao == 3 = do {putStrLn "Opcao em Desenvolvimento"; menu}
                     | opcao == 4 = do {putStrLn "Opcao em Desenvolvimento"; menu}
                     | otherwise =  do {putStrLn "Opcao em Desenvolvimento"; menu}

addNewClient :: Client -> IO()
addNewClient client = do
    let conteudo = conteudoAdicionar client
    appendFile "clints.txt" (conteudo)
    where
        conteudoAdicionar :: Client -> String
        conteudoAdicionar client
            | 2 == (-1) = ""
            | otherwise = ((clientToString (client)) ++ "\n")


clientToString :: Client -> String
clientToString (Client {clientId = clientId, name = name, idCNH = idCNH, programPoints = lo}) = show clientId ++ " - " ++ name ++ " - " ++ idCNH ++ " - " ++ show(lo)