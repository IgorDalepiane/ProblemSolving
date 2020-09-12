#include "load.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// #include "linkedList.h"

int main() {
  // node_t *head = (node_t *)malloc(sizeof(node_t)); // start linked list
  movie moviesArray[41];
  readFile("Entrega 1/Assets/entrada.txt", moviesArray);
  exit(EXIT_SUCCESS);
}

void readFile(char *path, movie moviesArray[]) {
  FILE *entrada = fopen(path, "r");

  char *token;
  char delim = ';';
  char *line = NULL;
  size_t length = 1024;
  ssize_t read;
  movie actualMovie;
  int counter;

  line = (char *)malloc(length * sizeof(char));

  if (entrada == NULL) {
    exit(EXIT_FAILURE);
  } else {
    // iterate over the lines of the file
    counter = 0;
    while ((read = getline(&line, &length, entrada)) != -1) {
      if (read <= 3) { // first line
        continue;
      }

      moviesArray[counter].id = counter + 1;
      token = strtok(line, ";"); // start reading line
      strcpy(moviesArray[counter].title, token);
      token = strtok(NULL, ";"); // jump to next token
      moviesArray[counter].year = atoi(token);
      token = strtok(NULL, ";"); // jump to next token
      moviesArray[counter].quantity = atoi(token);
      token = strtok(NULL, ";"); // jump to next token
      strcpy(moviesArray[counter].category, token);

      counter++;
    }
  }

  fclose(entrada);
  free(line);
}
