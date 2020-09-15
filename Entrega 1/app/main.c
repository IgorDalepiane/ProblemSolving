#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./Carries collection/load.h"

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
  char searchTerms[50];
  scanf("%d", &op);

  switch (op) {
  // Location
  case 1:
    printf("Funcionalidade em desenvolvimento..\n");
    pressKeyToContinue();
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
    printFromList(head);                      // show all movies details
    printSingleMovieDetailsFromList(head, 4); // show single movie details
    pressKeyToContinue();
    menu(head);

  // Reports
  case 5:
    printf("Funcionalidade em desenvolvimento..\n");
    pressKeyToContinue();
    menu(head);

  // Complete collection
  case 6:
    printf("Funcionalidade em desenvolvimento..\n");
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