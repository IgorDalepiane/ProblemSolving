#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

int main(){
    time_t timeT;
    timeT = time(NULL);
    struct tm tm = *localtime(&timeT);
    
    char current_day [2];
    char current_month [2];
    itoa(tm.tm_mday, current_day ,10);
    itoa(tm.tm_mon, current_month ,10);

    char file_name[25] = "..\\..\\Assets\\backup ";
    strcat(file_name, current_day);
    strcat(file_name, "-");
    strcat(file_name, current_month);

    FILE *file_pointer;
    char text[30];
    file_pointer = fopen(file_name, "w");

    if(file_pointer == NULL){
        printf("Erro ao criar arquivo");
    }else {    
        printf("Digite algo: ");
        scanf("%[^\n]s", text);

        fprintf(file_pointer, "%s", text);
        fclose(file_pointer);

        printf("Backup realizado com suceeso!\n");
    }
    getch();
}