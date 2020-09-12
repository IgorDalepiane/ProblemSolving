
typedef struct movie {
  int id;
  char title[50];
  int year;
  int quantity;
  char category[20];
} movie_t;

typedef struct node {
  movie_t m;
  struct node *next;
} node_t;

// pushes items to the list
void pushToList(node_t *head, movie_t movie); // add after the last
// void pushToList(node_t **head, movie_t movie); // add before the last
// prints elements of a list
void printFromList(node_t *head);

void removeLastFromList(node_t *head);
