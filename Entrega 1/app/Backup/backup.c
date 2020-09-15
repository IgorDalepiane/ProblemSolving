#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "backup.h"

FILE *file_pointer;
char systemDate[6];

char *my_itoa(int num, char *str) {
  if (str == NULL) {
    return NULL;
  }
  sprintf(str, "%d", num);
  return str;
}

void getSystemDate() {
  time_t timeT;
  timeT = time(NULL);
  struct tm tm = *localtime(&timeT);

  char current_day[2];
  char current_month[2];

  my_itoa(tm.tm_mday, current_day);
  my_itoa(tm.tm_mon, current_month);

  strcat(systemDate, current_day);
  strcat(systemDate, "-");
  strcat(systemDate, current_month);
}

void makeBackup(node_t *moviesList) {
  printf("\n Realizando Backup...\n");

  getSystemDate();

  node_t *current = moviesList;

  char file_name[25] = "Assets\\backup ";
  strcat(file_name, systemDate);
  strcat(file_name, ".txt");

  if ((file_pointer = fopen(file_name, "w")) != NULL) {
    int countMovies = 0;
    while (current != NULL) {
      if (current->next == NULL)
        break;
      int id = current->m.id;
      char title[50];
      strcpy(title, current->m.title);
      int year = current->m.year;
      int quantity = current->m.quantity;
      char category[20];
      strcpy(title, current->m.category);
      fprintf(file_pointer, "%d %s; %d; %d; %s\n", current->m.id,
              current->m.title, current->m.year, current->m.quantity,
              current->m.category);

      countMovies++;
      current = current->next;
    }
    printf("\n Backup realizado com sucesso, total de %d filmes.\n",
           countMovies);
    fclose(file_pointer);
  } else {
    printf("Erro ao criar arquivo");
  }
}