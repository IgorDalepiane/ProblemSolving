#include "rent.h"
#include <stdio.h>
#include <stdlib.h>

void rent(node_t *head, int id) {
  // Modificação da entrada.txt
  FILE *entrada = fopen("Assets/entrada.txt", "w+");
  // Arquivo para salvar o historico de locações
  FILE *rentHistory = fopen("Assets/rentHistory.txt", "a+");
  int count = 0;
  // Define valores na primeira linha para serem substituidos pelo count quando
  // o loop ser finalizado
  fprintf(entrada, "00\n");
  while (head->next != NULL) {
    if (head->m.id == id) {
      // Adiciona o id do filme que foi retirado, no arquivo rentHistory
      fprintf(rentHistory, "%d\n", head->m.id);
      head->m.quantity -= 1;
      printf("\"%s\" foi alugado com sucesso.\n", head->m.title);
    }
    fprintf(entrada, "%s;%d;%d;%s", head->m.title, head->m.year,
            head->m.quantity, head->m.category);
    head = head->next;
    count++;
  }
  // Bota o cursor no começo do arquivo
  fseek(entrada, 0, SEEK_SET);
  fprintf(entrada, "%d", count);

  fclose(entrada);
  fclose(rentHistory);
}