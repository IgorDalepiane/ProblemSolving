#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./Devolution/devolution.h"

void pressKeyToContinue() {
  printf("\nDigite qualquer coisa para continuar...\n");
  char pause[5];
  scanf("%s", pause);
}

void menu(node_t *head) {
  /* Menu design */
  printf("\n#########################################\n");
  printf("##  ◼  1 - Locação                     ##\n");
  printf("##  ◼  2 - Entrega de filmes           ##\n");
  printf("##  ◼  3 - Busca de um título          ##\n");
  printf("##  ◼  4 - Impressão                   ##\n");
  printf("##  ◼  5 - Relatórios                  ##\n");
  printf("##  ◼  6 - Acervo completo             ##\n");
  printf("##  ❌ 7 - Sair                        ##\n");
  printf("#########################################\n");
  printf("Escreva a sua opção: ");

  /* Declaration of variables */
  int op;
  int movieCode;
  char searchTerms[100];
  scanf("%d", &op);

  switch (op) {
  // Location
  case 1:
    system("clear");
    printf("##########################################\n");
    printf("##              Locar DVDs              ##\n");
    char repeat = 's';
    do {
      printf("Qual filme você quer alugar?: ");
      scanf("%s", searchTerms);

      node_t *results = (node_t *)malloc(sizeof(node_t));
      // List to reset the while
      node_t *resultsAux = (node_t *)malloc(sizeof(node_t));
      int id = 0;
      results = searchFromList(head, searchTerms); // Shows search results
      resultsAux = results;

      char correctSearch = 's';
      if (results->m.id != 0) {
        printFromList(results);
        // In case the user misses the name of the film and wants to look for another one
        printf("\nO filme que você quer alugar está na lista? [s/n]: ");
        scanf(" %c", &correctSearch);
        if (correctSearch == 'n') {
          continue;
        }
        int found;
        // Loop control if the id is nonexistent or out of stock
        int repeatId;
        do {
          found = 0;
          repeatId = 1;
          // In case there are more search results
          printf("\nDigite o código do filme escolhido: ");
          scanf("%d", &id);
          while (results->next != NULL) {
            if (results->m.id == id) {
              found = 1;
              // Checks whether the film is in stock
              if (results->m.quantity != 0) {
                repeatId = 0;
                rent(head, id);
              } else {
                printf("Fora de estoque.\n");
              }
            }
            results = results->next;
          }
          if (found == 0) {
            printf("Código inexistente.\n");
          }
          results = resultsAux;
        } while (repeatId == 1);
        printf("Deseja alugar outro filme? [s/n]: ");
        scanf(" %c", &repeat);
        printf("\n");
      } else {
        printf("\nNenhum filme encontrado.\n");
      }
    } while (repeat == 's');
    menu(head);

  // Devolution
  case 2:;
    char id[10];
    printf("\nDigite o código do filme locado: ");
    scanf("%s", id);
    int searchResult;
    searchResult = searchIdOnFile(id);
    if(searchResult == -1){
		  printf("\nOps, parece que ainda nao ha nenhuma locacao\n");
    }else if (searchResult == -2) {
		  printf("\nOps, tem certeza que digitou o id correto?\n");
    }else if(searchResult >=0){
      if(deleteLineInFile(searchResult)>0){
        devolution(head, atoi(id));
      }else{
        printf("\nINTERNAL SERVER ERROR\n");
      }
    } 

    pressKeyToContinue();
    menu(head);

  // Search
  case 3:
    // Clean the terminal
    system("clear");
    printf(
        "Você pode pesquisar filmes por Código, Titulo, Ano ou Categoria.\n");
    printf("Digite aqui: ");
    scanf("%s", searchTerms);

    // List of search results declaration
    node_t *searchResults = (node_t *)malloc(sizeof(node_t));
    // Perform the search
    searchResults = searchFromList(head, searchTerms);

    // If the list is not null, print it
    if (searchResults->m.id != 0) {
      printf("\n");
      printFromList(searchResults);
    } else {
      printf("\nNenhum resultado foi encontrado.\n");
    }
    pressKeyToContinue();
    menu(head);
    
  // Print
  case 4:
    do {
      int movieCode = 0;
      system("clear");
      printf(
          "Você pode pesquisar os detalhes de um filme através do seu código.\n");
      printf("Digite aqui o código do filme desejado: ");
      scanf("%d", &movieCode);

      printSingleMovieDetailsFromList(head, movieCode);

      printf("\nDeseja consultar os detalhes de outro filme? [s/n]: ");
          scanf(" %c", &repeat);
          printf("\n");

    } while(repeat == 's');
      menu(head);

  // Reports
case 5:;
    char reportTerms[100];
    system("clear");
    printf("Você pode gerar relatórios por Gênero e por Ano.\n");
    printf("Digite aqui: ");
    scanf("%s", reportTerms);

    // List of search results declaration
    node_t *reportResults = (node_t *)malloc(sizeof(node_t));
    // Perform the search
    reportResults = report(head, reportTerms);

    // If the list is not null, print it
    if (reportResults->m.id != 0) {
      printf("\n");
      printFromList(reportResults);
    } else {
      printf("\nNenhum resultado foi encontrado.\n");
    }
    pressKeyToContinue();
    menu(head);

  // Complete collection
  case 6:
    //make data with de head list
    makeBackup(head);
    pressKeyToContinue();
    menu(head);

  // Exit
  case 7:
    exit(0);
  }
}

int main() {
  // Allocates space to the beginning of the list
  node_t *head = (node_t *)malloc(sizeof(node_t));
  // movie_t moviesArray[41];
  readFile("Assets/entrada_mod.txt", head);

  // First program entry
  printf("##########################################\n");
  printf("##       Bem-vindo a Alce Movies        ##\n");

  menu(head);

  exit(EXIT_SUCCESS);
}
