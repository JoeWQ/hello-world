#include<stdio.h>
#include<stdlib.h>
typedef struct _Tree
{
	int data;
	int index;
	struct _Tree *left;
	struct _Tree *right;
}Tree;
void visit(Tree *);
Tree *createTree(int,FILE *);
void initNode(Tree *,FILE *);
static void create(Tree *,int *,FILE *);
void initNode(Tree *node,FILE *file)
{
	static int index=0;
	if(node)
	{	
		node->index=index;
		++index;
		node->data=0x80000000;
		puts("从文件中读取了两个个整数值");
		fscanf(file,"%d %d",&node->index,&node->data);
	}
}
void visit(Tree *node)
{
	if(node)
	{
    	printf("树中第 %d 节点的数据项的值为 %d \n",node->index,node->data);
		visit(node->left);
		visit(node->right);
	}
}
Tree *createTree(int totalNodes,FILE *file)
{
	int i=0;
	Tree *tree;
	if(totalNodes<=0)
		return NULL;
	tree=(Tree *)malloc(sizeof(Tree));
	initNode(tree,file);
	--totalNodes;
    create(tree,&totalNodes,file);	
	return tree;
}
static void create(Tree *parent,int *nodes,FILE *file)
{
	if(--*nodes>=0)
	{
		parent->left=(Tree *)malloc(sizeof(Tree));
		parent->right=(Tree *)malloc(sizeof(Tree));
		initNode(parent->left,file);
		initNode(parent->right,file);
		create(parent->left,nodes,file);
		create(parent->right,nodes,file);
	}
}
void destroyTree(Tree *tree)
{
	if(tree)
	{
		free(tree->left);
		free(tree->right);
		free(tree);
	}
}
//...............................
int main(int alpha,char **argv)
{
	FILE *file;
	Tree *tree;
	puts("创建树");
	if(alpha>=2)
	{
        file=fopen(argv[1],"wr+");
		if(!file)
			file=stdin;
	}
   tree=createTree(18,file);
   visit(tree);
   destroyTree(tree);
   puts("树已经被销毁");
   if(file!=stdin)
	   fclose(file);
   return 0;
}
