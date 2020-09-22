#include "devolution.h"
#include <stdio.h>
#include <stdlib.h>

#define MAX 256

void devolution(node_t *head, int id) {
    // Modificação da entrada.txt
    FILE *entrada = fopen("Assets/entrada.txt", "w+");

    // Arquivo para salvar o historico de locações
    FILE *rentHistory = fopen("Assets/rentHistory.txt", "a+");
    int count = 0;

    // Define valores na primeira linha para serem substituidos pelo count quando o loop ser finalizado
    fprintf(entrada, "00\n");

    while (head -> next != NULL) {
        if (head -> m.id == id) {
            // Adiciona o id do filme que foi retirado, no arquivo rentHistory
            fprintf(rentHistory, "%d\n", head->m.id);
            head->m.quantity += 1;
            printf("\"%s\" foi devolvido com sucesso.\n", head->m.title);
        }

        fprintf(entrada, "%s;%d;%d;%s", head->m.title, head->m.year,
                head -> m.quantity, head->m.category);
        head = head -> next;
        count++;
    }

    // Bota o cursor no começo do arquivo
    fseek(entrada, 0, SEEK_SET);
    fprintf(entrada, "%d", count);

    fclose(entrada);
    fclose(rentHistory);
}

// Seach if exist id of devolution on file rentHistory
int searchIdOnFile(char *id) {
	FILE *rentHistory;
	int line_num = 1;
	int find_result = 0;
	char temp[10];

    // Verify if file exist
	if((fopen_s(&rentHistory, "Assets/rentHistory.txt", "r")) != NULL) {
		return(-1);
	}

    // Search in rentHistory file if exist id
	while(fgets(temp, 10, rentHistory) != NULL) {
		if((strstr(temp, id)) != NULL) {
			printf("Encontramos o registro da sua locacao: %d\n", line_num);
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
        return line_num;
    }
	
   	return(0);
}

// delete the line references of location in rentHistory
int deleteLineInFile(int lineToDelete){
    int linetoCopy = 0;
    char ch;
    FILE *rentHistory, *tempFile;
    char fname[MAX];
    char stringLine[MAX], temp[] = "Assets/tempFile.txt";
    
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
    remove(fname);  		// remove the original rentHistory 
    rename(temp, fname); 	// rename the temporary file to rentHistory.txt
    
    return 1;
} 