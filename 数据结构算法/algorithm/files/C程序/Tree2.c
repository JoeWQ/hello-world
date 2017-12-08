#include<stdio.h>
#include<stdlib.h>
#define null NULL
#define Capacity 4
typedef struct tree
{
	int record;
	struct tree *left;
	struct tree *right;

}Tree;
Tree *initialize();
void createTree(Tree *,int );
void freeTree(Tree *);
void print(Tree *,int );
void giveValue(Tree *);
int main()
{
	Tree *p=null;
	p=initialize();
	createTree(p,Capacity);
	print(p,0);
	puts("The tree has been constructed !");
	freeTree(p);
	return 0;
}
void createTree(Tree *p,int capacity)
{
	Tree *left=null,*right=null;
	if(capacity>0&&p!=null)
	{
       left=(Tree *)malloc(sizeof(Tree));
	   p->left=left;
	   giveValue(left);
       createTree(left,(capacity-1));
	   right=(Tree *)malloc(sizeof(Tree));
	   p->right=right;
	   giveValue(right);
	   createTree(right,(capacity-1));	   
	}
}   
void giveValue(Tree *p)
{
	if(p!=null)
	{
		p->right=null;
		p->left=null;
		p->record=rand();
	}
}
Tree *initialize()
{
	Tree *head=null;
	head=(Tree *)malloc(sizeof(Tree));
	giveValue(head);
	if(head!=null)
	  return head;
	else
		return null;
}
void print(Tree *p,int i)
{
	if(p!=null)
	{
		printf("The %dth record is : %d .\n",i,p->record);
		if(p->left!=null)
			print(p->left,++i);
        if(p->right!=null)
			print(p->right,++i);
	}
}
void freeTree(Tree *p)
{
	if(p!=null)
	{
		if(p->left!=null)
			freeTree(p->left);   
		if(p->right!=null)
			freeTree(p->right);
		freeTree(p);
	}
}


