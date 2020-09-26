#include "devolution.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 256

void devolution(node_t *head, int id) {
    // modification entrada.txt
    FILE *entrada = fopen("Assets/entrada.txt", "w+");

    int count = 0;

    // Set values ​​on the first line to be replaced by counting when the loop ends
    fprintf(entrada, "00\n");

  while (head -> next != NULL) {
    if (head -> m.id == id) {
      // make add one quantity in specific movie
      head->m.quantity += 1;
      printf("\"%s\" foi devolvido com sucesso.\n", head->m.title);
    }

    fprintf(entrada, "%s;%d;%d;%s", head->m.title, head->m.year,
            head -> m.quantity, head->m.category);
    head = head -> next;
    count++;
  }

  // Put the cursor at the beginning of the file
  fseek(entrada, 0, SEEK_SET);
  fprintf(entrada, "%d", count);

  fclose(entrada);
}

// Seach if exist id of devolution on file rentHistory
int searchIdOnFile(char *id) {
  FILE *rentHistory = fopen("Assets/rentHistory.txt", "r");
  int line_num = 1;
  int line_specifc = 0;
  int find_result = 0;
  char temp[10];

  // Verify if file exist
  if(rentHistory == NULL) {
    return(-1);
  }

  // Search in rentHistory file if exist id
  while(fgets(temp, 10, rentHistory) != NULL) {
    if((strstr(temp, id)) != NULL) {
      printf("Encontramos o registro da sua locacao: %d\n", line_num);
      line_specifc = line_num;
      printf("\n%s\n", temp);
      find_result++;
    }
    line_num++;
  }

  //Close the file if still open.
  if(rentHistory) {
    fclose(rentHistory);
  }

  // return result
   if(find_result == 0) {
        return -2;
	} else {
        return line_specifc;
    }
}

// delete the line references of location in rentHistory
int deleteLineInFile(int lineToDelete){
  int linetoCopy = 0;
  char ch;
  FILE *rentHistory, *tempFile;
  char fname[MAX];
  char stringLine[MAX], *temp = "Assets/tempFile.txt";

  rentHistory = fopen("Assets/rentHistory.txt", "r");
  if (rentHistory == NULL){
    return 0;
  }

  tempFile = fopen(temp, "w"); // open the temporary file in write mode

  if (!tempFile) {
    printf("Tivemos um problema ao devolver seu filme.\n");
    fclose(rentHistory);
    return 0;
  }

  // copy all contente of rentHistory to tempFile
  while (!feof(rentHistory)) {
    strcpy(stringLine, "\0");
    fgets(stringLine, MAX, rentHistory);
    if (!feof(rentHistory)) {
      linetoCopy++;
      // Skip the specific line
      if (linetoCopy != lineToDelete) {
        fprintf(tempFile, "%s", stringLine);
      }
    }
  }
  fclose(rentHistory);
  fclose(tempFile);
  remove("Assets/rentHistory.txt"); // remove the original rentHistory
  rename(
      "Assets/tempFile.txt",
      "Assets/rentHistory.txt"); // rename the temporary file to rentHistory.txt

  return 1;
}