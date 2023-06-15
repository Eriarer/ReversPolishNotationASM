#include <stdio.h>
#include <stdlib.h>
void printAnswer(char* expression, float input);

void printAnswer(char* expression, float input) {
    int aux = input;
    if(input - aux != 0)
        printf("%s = %.2f\n", expression, input);
    else
        printf("%s = %.0f\n", expression, input);

}