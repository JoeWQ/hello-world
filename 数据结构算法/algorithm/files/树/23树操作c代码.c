可以运行。设计了测试用例覆盖了所有的情况，测试后结果正确。

2-3树具体的讲解请看文档，文档是东南大学邓建明老师上课使用的。

 


#include "f.h"
void main(){
	stack=(Stack)malloc(sizeof(Stacks));
	stack->tail=(BiStack)malloc(sizeof(StackNode));
	stack->tail->preNode=NULL;
	stack->tail->pTree=NULL;
	stack->head=stack->tail;
	//for the delete function
	BiTree t=NULL;//指向2-3树根节点
	int inputs=1;
	int input_set[10]={11,22,34,42,6,3,28,24,36,9};
	for (int i=0;i<10;i++)
	{
		insert(input_set[i],&t);
	}
	/*
	while (inputs!=0)
	{
		printf("\n请输入一个正整数插入到2-3树中：");
		scanf("%d",&inputs);
		if (inputs!=0)
		{
			insert(inputs,&t);
		}
	}*/
	int key=-1;
	int key_set[9]={28,36,24,34,6,3,22,42,11};
	deletes(11,&t);
	/*
	for (int i=0;i<6;i++)
	{
		if (i==14)
		{
			int sss=0;
		}
		if (!deletes(key_set[i],&t))
		{
			printf("there is no node in the tree you want to delete");
		}
	}
	/*
	while(key!=0){
		printf("\n请输入要删除节点的key值：");
		scanf("%d",&key);
		
		if (!deletes(key,&t))
		{
			printf("there is no node in the tree you want to delete");
		}
		
	}*/
	int s;
}
  
 


#include <stdio.h>
#include <malloc.h>
#define NUM 10
#define INTERIOR 0
#define LEAF 1
#define FALSE 0
#define TRUE 1
typedef struct Node//节点
{
	int type;
	int key;
	int low2;
	int low3;
	struct Node * son1;
	struct Node * son2;
	struct Node * son3;
}TreeNode,*BiTree;
typedef struct sNode
{
	struct sNode *preNode;
	BiTree pTree;
}StackNode, *BiStack;
typedef struct stackn
{
	BiStack head;
	BiStack tail;
}Stacks,*Stack;
Stack stack;
void push(BiTree bt){
	BiStack bs=(BiStack)malloc(sizeof(StackNode));
	bs->preNode=stack->head;
	bs->pTree=bt;
	stack->head=bs;
}
BiTree pop(){
	if (stack->head == stack->tail)
	{
		return NULL;
	}
	BiTree bt=stack->head->pTree;
	BiStack bs=stack->head;
	if (bs!=stack->tail)
	{
		stack->head=bs->preNode;
	}
	free(bs);
	return bt;
}
void clean(){
	while(stack->head!=stack->tail){
		BiStack tmp=stack->head;
		stack->head=stack->head->preNode;
		free(tmp);
	}
}

BiTree createNode(int type,int key){
	BiTree t=(BiTree)malloc(sizeof(TreeNode));
	t->type=type;
	t->low2=t->low3=0;
	t->son1=t->son2=t->son3=NULL;
	t->key=key;
	return t;
}
/************************************************************************/
/* 
input:
	x		:	the leaf node to insert
	tp		:	the tree or the sun tree x will insert to
	pback:	:	null - the function is complete. if it is not null, it means
				a bother node of tp, it is created in the function because 
				tp has three sun node,so the function created it to stored 
				new node;It is used for father node(out function) to coordinate
				the tree;
				the node is right to tp
output:
	lowBack:	it is the least key number of the nodes of pback;
*/
/************************************************************************/
int addson(BiTree x,BiTree* tp_point,BiTree *pBack){
	BiTree tp=*tp_point;
	int low_back=0;
	if (tp->type == LEAF)
	{
		if (tp->key > x->key)
		{
			BiTree tmp=x;
			x=tp;
			(*tp_point)=tmp;
		}
		*pBack=x;
		return (*pBack)->key;
	}
	//tp node is a interior node
	int child;//it means which child node to insert;
	BiTree tp_next;
	if (x->key < tp->low2)
	{
		child =1;
		tp_next=tp->son1;
	}
	else if (x->key <tp->low3 || (tp->low3 ==0&&tp->son3 == NULL))
	{
		child =2;
		tp_next=tp->son2;
	}
	else
	{
		child =3;
		tp_next=tp->son3;
	}
	BiTree pNewBack=NULL;
	//set the tp_next as the tree to insert
	//iterate the function until dealing with the leaf node 
	int low_number=addson(x,&tp_next,&pNewBack);
	if (pNewBack != NULL)
	{
		if (tp->son3 == NULL)//if tp only have two child node, the new node which is create in the iteration function can be stored by tp node
		{
			if (child ==1)
			{
				tp->son3=tp->son2;
				tp->son2=pNewBack;
				tp->son1=tp_next;//tp_next is a pointer who point to the node/tree to insert
				tp->low3=tp->low2;
				tp->low2=low_number;
			}
			else//child == 2
			{
				tp->son3=pNewBack;
				tp->son2=tp_next;
				tp->low3=low_number;
			}

		}
		else{
			//tp have three child node so a new interior node(tp's right bother) should be create to store the new child node
			*pBack=createNode(INTERIOR,0);
			if (child ==1)
			{
				(*pBack)->son1=tp->son2;
				(*pBack)->son2=tp->son3;
				tp->son2=pNewBack;
				tp->son1=tp_next;

				tp->son3=NULL;

				(*pBack)->low2=tp->low3;
				low_back=tp->low2;

				tp->low2=low_number;
				tp->low3=0;
			}
			else if (child == 2)
			{
				(*pBack)->son1=pNewBack;
				(*pBack)->son2=tp->son3;
				tp->son2=tp_next;
				tp->son3=NULL;

				(*pBack)->low2=tp->low3;
				tp->low3=0;
				low_back=low_number;
			}
			else
			{
				//child ==3
				(*pBack)->son1=tp_next;
				(*pBack)->son2=pNewBack;
				tp->son3=NULL;
				(*pBack)->low2=low_number;
				low_back=tp->low3;
				tp->low3=0;
			}

		}
	}
	return low_back;
}
void insert(int key,BiTree *ts){
	BiTree tree=*ts;
	BiTree x=createNode(LEAF,key);
	if (tree == NULL)//如果2-3树为空树
	{
		*ts=x;
		return;
	}
	BiTree tp=tree;
	BiTree pBack=NULL;
	int low_number=addson(x,&tp,&pBack);
	if (pBack!=NULL)
	{
		//create a new interior node used as the new tree node
		BiTree newHead=createNode(INTERIOR,0);
		newHead->low2=low_number;
		newHead->son1=tp;
		newHead->son2=pBack;
		*ts=newHead;
	}
	return;
}
/************************************************************************/
/*
find the node to delete by key.On the same time,stack will store the router of nodes which have been searched.
intup:
	key		:	the key of the node which is supposed to delete
	tree	:	the tree to search for the node to delete
	p		:	point to a node whose low2 or low3 equal to the key to delete
output:
	if a node is searched successfully,return true;otherwise return false;
*/
/************************************************************************/
bool find_node(int key,BiTree tree,BiTree *p){
	if (tree==NULL)
	{
		return false;
	}
	push(tree);
	if (tree->type == LEAF)
	{
		if (tree->key == key)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	if (key==tree->low2 || key ==tree->low3)
	{
		*p=tree;
	}
	if (key<tree->low2)
	{
		find_node(key,tree->son1,p);
	}
	else if (key == tree->low2 || key<tree->low3||tree->low3==0)
	{
		find_node(key,tree->son2,p);
	}
	else{
		find_node(key,tree->son3,p);
	}
}
void changePpoint(BiTree a,BiTree p,int key){
	if (p->low2==a->key)
	{
		p->low2=key;
	}else{
		p->low3=key;
	}
}
int getLeastKey(BiTree t){
	if (t->type==INTERIOR)
	{
		return getLeastKey(t->son1);
	}else{
		return t->key;
	}
}
void deleteNode(BiTree *a_pointer,BiTree *f_pointer,BiTree *ff_pointer,BiTree p,BiTree *t_pointer){
	
	BiTree a=*a_pointer;
	printf("delete node begin! ");
	printf("node:%d %d %d %d\n",a->key,a->low2,a->low3,a->type);
	BiTree f=*f_pointer;
	BiTree ff=*ff_pointer;
	BiTree tLeft=NULL;
	BiTree tRight=NULL;
	int fchild=0;
	int achild=0;
	if (a==f->son1)
	{
		achild=1;
	}
	else if (a==f->son2)
	{
		achild=2;
	}
	else{
		achild=3;
	}
	if (f->low3!=0)//father node have three child node;
	{
		if (a==f->son3)
		{
			f->son3=NULL;
			f->low3=0;
			free(a);
		}
		else if (a==f->son2)
		{
			f->low2=f->low3;
			f->low3=0;
			f->son2=f->son3;
			f->son3=NULL;
			free(a);
		}
		else if (a==f->son1)
		{
			if (a->type==LEAF&&p!=NULL)
			{
				changePpoint(a,p,f->low2);
			}
			f->low2=f->low3;
			f->low3=0;
			f->son1=f->son2;
			f->son2=f->son3;
			f->son3=NULL;
			free(a);
		}
		else
		{
			printf("err:a不是f的子节点。\n");
		}
	}
	else{//father node have two child node,a =1,2
		BiTree b=NULL;
		if (achild ==1)
		{
			b=f->son2;
		}
		else{
			b=f->son1;
		}
		if (ff==NULL)//f is the root node
		{
			*t_pointer=b;
			free(a);
			free(f);
			return;
		}

		if (f==ff->son1)
		{
			tRight=ff->son2;
			fchild=1;
		}
		else if (f==ff->son2)
		{
			tLeft=ff->son1;
			tRight=ff->son3;
			fchild=2;
			//ff->low2=getLeastKey(f);
		}
		else if (f == ff->son3)
		{
			tLeft=ff->son2;
			fchild=3;
			//ff->low3=getLeastKey(f);
		}
		else{
			printf("err1:f not a child node of ff!\n");
		}

		//获得了父节点左右的分支，开始根据四种情况处理
		if (tLeft!=NULL&&tLeft->low3!=0)
		{//父节点由一个兄弟节点在左边，并且有三个子节点. done!
			f->son2=b;
			f->son1=tLeft->son3;
			tLeft->son3=NULL;
			if (a->type=LEAF&&a->key<b->key&&p!=NULL)
			{
				changePpoint(a,p,tLeft->low3);
			}
			int tmp=0;
			if (fchild==2)
			{
				tmp=ff->low2;
				ff->low2=tLeft->low3;
			}
			else{
				tmp=ff->low3;
				ff->low3=tLeft->low3;
			}
			if (achild=2)//如果a是父节点的第二个孩子，则b为第一个孩子，将b改为f的第二个字孩子以后，可以从ff中获得b的最小节点值。
			{
				f->low2=tmp;
			}
			tLeft->low3=0;
			free(a);
		}
		else if (tRight!=NULL&&tRight->low3!=0)
		{
			f->son1=b;
			f->son2=tRight->son1;
			tRight->son1=tRight->son2;
			tRight->son2=tRight->son3;
			tRight->son3=NULL;
			if (a->type=LEAF&&a->key<b->key&&p!=NULL)
			{
				changePpoint(a,p,b->key);
			}
			int tmp=0;
			if (fchild==1)
			{
				tmp=ff->low2;
				ff->low2=tRight->low2;
			}else{
				tmp=ff->low3;
				ff->low3=tRight->low2;
			}
			f->low2=tmp;
			if (tmp!=getLeastKey(f->son2))
			{
				printf("err:not equal to getLeastKey:2~");
			}
			//f->low2=getLeastKey(f->son2);
			tRight->low2=tRight->low3;
			tRight->low3=0;
			free(a);
		}
		else if (tLeft!=NULL)//左侧兄弟节点有两个儿子
		{
			tLeft->son3=b;
			if (achild==2)//修改tleft->low3
			{
				int tmp=0;
				if (fchild==2)
				{
					tmp=ff->low2;
				}
				else{
					tmp=ff->low3;
				}
				tLeft->low3=tmp;
			}
			else{
				tLeft->low3=f->low2;
			}
			*a_pointer=*f_pointer;
			*f_pointer=*ff_pointer;
			BiTree bitmp=pop();
			*ff_pointer=bitmp;
			free(a);
			deleteNode(a_pointer,f_pointer,ff_pointer,p,t_pointer);
		}
		else{//右侧兄弟节点有两个儿子
			tRight->son3=tRight->son2;
			tRight->son2=tRight->son1;
			tRight->son1=b;
			if (a->type=LEAF&&a->key<b->key&&p!=NULL)
			{
				changePpoint(a,p,b->key);
			}
			tRight->low3=tRight->low2;
			if (fchild==1)
			{
				tRight->low2=ff->low2;
			}else{
				tRight->low2=ff->low3;
			}
			*a_pointer=*f_pointer;
			*f_pointer=*ff_pointer;
			BiTree bitmp=pop();
			*ff_pointer=bitmp;
			free(a);
			deleteNode(a_pointer,f_pointer,ff_pointer,p,t_pointer);
		}
		

	}
	//删除节点的父节点的对于该节点的low信息不需要使用
}

int deletes(int key,BiTree *t){
	BiTree tree=*t;
	BiTree p=NULL;//point to a node whose low2 or low3 equal to the key to delete
	clean();
	if (tree==NULL||!find_node(key,tree,&p))
	{
		return FALSE;
	}
	if (tree->type=LEAF&&tree->key == key)
	{
		free(tree);
		*t=NULL;
	}
	BiTree a=pop();//the LEFT node
	BiTree f=pop();//father node
	BiTree ff=pop();//father node 's father node
	deleteNode(&a,&f,&ff,p,t);
	return TRUE;
}