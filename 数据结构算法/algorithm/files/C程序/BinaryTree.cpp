#include<stdio.h>
#include<stdlib.h>
#define null NULL
#define LIMIT 5
typedef struct Tree{
	int e;
	int index;
	struct Tree *lchild;
	struct Tree *rchild;
}BiTree;
typedef struct Stack
{
	struct Tree *child;
	struct Stack *next;
}Link;
struct StackInfo
{
	struct Stack *head;
/*	struct Stack *tail;*/
	int length;
};
BiTree *createBinaryTree(int limit);
void constructBiTree(BiTree *,int,int *);
void initNode(BiTree *,int *);
void visit(BiTree *head);
void push(StackInfo *,BiTree *);
BiTree *pop(StackInfo *);
int isStackInfoEmpty(StackInfo *S);
/*void freeBiTree(BITree *);*/
int main()
{
	BiTree *head=null;
	head=createBinaryTree(LIMIT);
	visit(head);
	return 0;
}
void initNode(BiTree *p,int *index)
{
	if(p!=null)
	{
		p->e=rand();
		p->index=*index;
		p->lchild=null;
		p->rchild=null;
		++*index;
	}
}
BiTree *createBinaryTree(int limit)
{
	BiTree *head=null;
	int index=0;
    head=(BiTree *)malloc(sizeof(BiTree));
	initNode(head,&index);
	constructBiTree(head,--limit,&index);
	return head;
}
void constructBiTree(BiTree *p,int limit,int *index)
{
	if(p!=null&&limit>0)
	{
		p->lchild=(BiTree *)malloc(sizeof(BiTree));
		p->rchild=(BiTree *)malloc(sizeof(BiTree));
		initNode(p->lchild,index);
		initNode(p->rchild,index);
		constructBiTree(p->lchild,limit-1,index);
		constructBiTree(p->rchild,limit-1,index);
	}
}
void push(StackInfo *S,BiTree *child)
{
	Link *node=null;
	if(child!=null)
	{
    	node=(Link *)malloc(sizeof(Link ));
    	node->child=child;
    	node->next=S->head;
    	S->head=node;
    	++S->length;
	}
}
BiTree *pop(StackInfo *S)
{
	BiTree *key=null;
	Link *link=null;
	if(S->head!=null)
	{
		link=S->head;
		S->head=link->next;
		key=link->child;
		--S->length;
		free(link);
		return key;
	}
	return null;
}
int isStackInfoEmpty(StackInfo *S)
{
	if(S->length!=0)
		return 0;
	else
		return 1;
}
void visit(BiTree *head)
{
	StackInfo *S=null;
	BiTree *key=null,*p=head;
	S=(StackInfo *)malloc(sizeof(StackInfo));
    S->head=null;
	S->length=0;
      while(!isStackInfoEmpty(S)||p)
	  {
		  if(p!=null)
		  {

		      while(p!=null)
			  {
                  push(S,p);
				  p=p->lchild;
			  }
		  }
		  else
		  {
			  p=pop(S);
			  printf("第 %d 个数据内容为 : %d \n",key->index,key->e);
			  key=p;
			  p=key->rchild;
			  free(key);
		  }
	  }
	  free(S);
}














	
     




