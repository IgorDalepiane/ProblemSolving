#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "load.h"

void readFile(char *path, node_t *moviesList) {
  FILE *entrada = fopen(path, "r");

  char *token;
  char *line = NULL;
  size_t length = 1024;
  ssize_t read;
  movie_t currentMovie;
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

      currentMovie.id = counter + 1;
      token = strtok(line, ";"); // start reading line
      strcpy(currentMovie.title, token);
      token = strtok(NULL, ";"); // jump to next token
      currentMovie.year = atoi(token);
      token = strtok(NULL, ";"); // jump to next token
      currentMovie.quantity = atoi(token);
      token = strtok(NULL, ";"); // jump to next token
      strcpy(currentMovie.category, token);

      pushToList(moviesList, currentMovie);
      counter++;
    }
  }
  fclose(entrada);
  free(line);
}
