#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./Location/rent.h"

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
      // Lista para resetar o while
      node_t *resultsAux = (node_t *)malloc(sizeof(node_t));
      int id = 0;
      results = searchFromList(head, searchTerms); // Mostra resultados da busca
      resultsAux = results;

      char correctSearch = 's';
      if (results->m.id != 0) {
        printFromList(results);
        // Para o caso de o usuario errar o nome do filme e querer buscar por
        // outro
        printf("\nO filme que você quer alugar está na lista? [s/n]: ");
        scanf(" %c", &correctSearch);
        if (correctSearch == 'n') {
          continue;
        }
        int found;
        // Controle do loop se o id for inexistente ou fora de estoque
        int repeatId;
        do {
          found = 0;
          repeatId = 1;
          // Para o caso de existirem mais resultados na busca
          printf("\nDigite o código do filme escolhido: ");
          scanf("%d", &id);
          while (results->next != NULL) {
            if (results->m.id == id) {
              found = 1;
              // Verifica se o filme esta no estoque
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
  case 2:
    printf("Funcionalidade em desenvolvimento..\n");
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
  case 5:
    printf("Funcionalidade em desenvolvimento..\n");
    pressKeyToContinue();
    menu(head);

  // Complete collection
  case 6:
    makeBackup(head);
    pressKeyToContinue();
    menu(head);

  // Exit
  case 7:
    exit(0);
  }
}

int main() {
  // Aloca espaço para o começo da lista
  node_t *head = (node_t *)malloc(sizeof(node_t));
  // movie_t moviesArray[41];
  readFile("Assets/entrada.txt", head);

  // First program entry
  printf("##########################################\n");
  printf("##       Bem-vindo a Alce Movies        ##\n");

  menu(head);

  exit(EXIT_SUCCESS);
}
