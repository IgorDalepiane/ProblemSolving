typedef struct {
  int id;
  char title[50];
  int year;
  int quantity;
  char category[20];
} movie;

void readFile(char* path, movie moviesArray[]);