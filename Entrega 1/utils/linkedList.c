#include "linkedList.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void printFromList(node_t *head) {
  node_t *current = head;
  while (current != NULL) {
    // do not print the last item since it's just 0's and \00
    if (current->next == NULL) {
      break;
    }
    printf("=================================================\nCod: "
           "%d\nTítulo: %s\nAno de lançamento: %d\nQuantidade em estoque: "
           "%d\nCategoria: %s",
           current->m.id, current->m.title, current->m.year,
           current->m.quantity, current->m.category);
    current = current->next;
  }
}

node_t *searchFromList(node_t *head, char *data) {
  /* List declaration for return */
  node_t *response = (node_t *)malloc(sizeof(node_t));

  node_t *current = head;

  /* Turns search into uppercase for comparison */
  char *dataUpper = data;
  while (*dataUpper) {
    *dataUpper = toupper((unsigned char)*dataUpper);
    dataUpper++;
  }

  while (current->next != NULL) {
    /* If any information from the current movie is compatible with the search,
     * add it to the return */
    if (strstr(current->m.title, data) != NULL ||
        strstr(current->m.category, data) != NULL ||
        current->m.year == atoi(data) || current->m.id == atoi(data)) {
      pushToList(response, current->m);
    }
    current = current->next;
  }

  return response;
}

void printSingleMovieDetailsFromList(node_t *head, int id) {
  node_t *current = head;
  int position = 0;

  if (head == NULL) {
    printf("A lista nao foi inicializada");
    return;
  }

  while (current->next != NULL) {
    if (current->m.id == id) {
      printf("\nCod: "
             "%d\nTítulo: %s\nAno de lançamento: %d\nQuantidade em estoque: "
             "%d\nCategoria: %s",
             current->m.id, current->m.title, current->m.year,
             current->m.quantity, current->m.category);
      return;
    }

    current = current->next;
    position++;
  }

  printf("\nNenhum filme com este código foi encontrado.\n");
}

void pushToList(node_t *head, movie_t movie) {
  node_t *current = head;
  while (current->next != NULL) {
    current = current->next;
  }
  current->m = movie;
  current->next = (node_t *)malloc(sizeof(node_t));
  current->next->next = NULL;
}

void removeLastFromList(node_t *head) {
  /* if there is only one item in the list, remove it */
  if (head->next == NULL) {
    free(head);
    return;
  }

  /* get to the second to last node in the list */
  node_t *current = head;
  while (current->next->next != NULL) {
    current = current->next;
  }

  /* now current points to the second to last item of the list, so let's remove
   * current->next */
  free(current->next);
  current->next = NULL;
}