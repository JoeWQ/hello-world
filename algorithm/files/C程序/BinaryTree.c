#include<stdio.h>
#include<stdlib.h>
#define null NULL
typedef struct BinaryTree
{
	int index;
	int e;
	struct BinaryTree *left;
	struct BinaryTree *right;
}Tree;
typedef struct Node
{
	struct BinaryTree *node;
	struct Node *next;
}Link;
typedef struct SQStack
{
	int length;
	struct Node *head;
}Stack;
void init(Tree *,int *);
Stack *initStack();
Tree *createTree(int );
void push(Stack *,Tree *);
Tree *pop(Stack *);
void construct(Tree *,int *);
void traverseTree(Tree *);
void freeTree(Tree *);
int main()
{
}
void init(Tree *p,int *index)
{
	if(p!=null)
	{
		p->index=++*index;
		p->e=rand();
		p->left=null;
		p->right=null;
	}
}
Stack *initStack()
{
	Stack *s=(Stack *)malloc(sizeof(Stack));
	if(s!=null)
	{
		s->length=0;
		s->head=null;
		return s;
	}
	else
		return null;
}  