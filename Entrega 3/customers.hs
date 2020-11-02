main :: IO ()
main = do
    logo
    menu

logo :: IO ()
logo = do
    putStrLn "    __    ____  _________    ____ " 
    putStrLn "   / /   / __ \\/ ____/   |  / __ \\" 
    putStrLn "  / /   / / / / /   / /| | / /_/ /" 
    putStrLn " / /___/ /_/ / /___/ ___ |/ _, _/ " 
    putStrLn "/_____/\\____/\\____/_/  |_/_/ |_|  "
    putStrLn "                                    "

menu :: IO ()
menu = do
    putStrLn "1 - Cadastrar novo cliente"
    putStrLn "2 - Alterar dados de cliente"
    putStrLn "3 - Excluir clientes"
    putStrLn "4 - Consultar cliente"
    putStrLn "0 - Sair" 
    putStrLn "\nOpcao: "
    option <- getLine
    if (read option) == 0 then putStrLn("Fim") else do selectedOption (read option)

selectedOption :: Int -> IO()
selectedOption option | option == 1 = do putStrLn "Cadastrar"
                      | option == 2 = do putStrLn "Editar"
                      | option == 3 = do putStrLn "Excluir"
                      | option == 4 = do putStrLn "Consultar"
                      | otherwise =  do {putStrLn "Esta opcao nao existe. Por favor selecione uma opcao listada acima" ; menu}