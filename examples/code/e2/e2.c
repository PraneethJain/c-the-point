#include <stdio.h>

int main(void) {
  int x = 5;
  
  printf("&x=%p\n", &x);
  printf("x=%d\n", x);
  printf("*&x=%d\n", *&x);
  
  int y = 7;

  int *p = &x;

  printf("p=%p\n", &p);
  printf("&p=%p\n", p);
  printf("*&p=%p\n", *&p);
  printf("*p=%d\n", *p);  
  printf("&*p=%p\n", &*p);
  
  *p = y;

  printf("p=%p\n", &p);
  printf("&p=%p\n", p);
  printf("*&p=%p\n", *&p);
  printf("*p=%d\n", *p);  
  printf("&*p=%p\n", &*p);
  
  
  return 0;
}
