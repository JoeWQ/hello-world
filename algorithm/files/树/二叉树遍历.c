//二叉树的遍历
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define MAX_SIZE   16
//定义树的数据结构  
  typedef struct _Tree
 {
      int  data;
      int  index;
      struct  _Tree  *lchild;
      struct  _Tree  *rchild;
  }Tree;
//定义堆栈的数据结构
  typedef struct _Stack
 {
      struct _Tree   *node;
      struct _Stack  *next;
  }Stack;
//定义堆栈的相关信息的数据结构
  typedef struct _StackInfo
 {
      int len;
      struct _Stack   *front;
      struct _Stack   *rear;
  }StackInfo;
//********************************************
  Tree  *CreateTree(int);
//  void  *VisitTree(Tree *);
  StackInfo  *CreateStackInfo();
  void  addStack(StackInfo *,Tree *);
  Tree *removeStack(StackInfo *);
  int   IsStackEmpty(StackInfo *);
//层序遍历树
  void  LevelVisit(Tree *);
//中序遍历树
  void  InorderVisit(Tree *);
//**************************************************
//初始化树的节点
  void  init(Tree *node,int index)
 {
      node->data=rand();
      node->index=index;
      node->lchild=NULL;
      node->rchild=NULL;
  }
//**************************************************
  Tree *CreateTree(int limit)
 {
      Tree *tree,*lchild,*rchild;
      int i=0,seed;
      seed=time(NULL);
//初始化随机数发生器
      srand(seed);
//建立头结点
      tree=(Tree *)malloc(sizeof(Tree));
      init(tree,i++);
//第二层
      lchild=(Tree *)malloc(sizeof(Tree));
      init(lchild,i++);
      tree->lchild=lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->rchild=rchild;
//第三层      
      lchild=(Tree *)malloc(sizeof(Tree));
      init(lchild,i++);
      tree->lchild->lchild=lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->lchild->rchild=rchild;
   
      lchild=(Tree *)malloc(sizeof(Tree));
      init(lchild,i++);
      tree->rchild->lchild=lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->rchild->rchild=rchild;
//第五层(非完整的)
      lchild=tree->lchild->lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      lchild->rchild=rchild;

      return tree;
  }
//创建堆栈信息
  StackInfo  *CreateStackInfo()
 {
      StackInfo  *info;
      info=(StackInfo *)malloc(sizeof(StackInfo));
      info->len=0;
      info->front=NULL;
      info->rear=NULL;
      return info;
  }
//向堆栈信息中添加堆栈项
  void addStack(StackInfo *info,Tree *node)
 {
//注意，下面没有错误检测
      Stack  *item=(Stack *)malloc(sizeof(Stack));
      item->next=NULL;
      item->node=node;
      if(info->len)
     {
         item->next=info->front;
         info->front=item;
         ++info->len;
      }
      else
     {
         info->front=item;
         info->rear=item;
         ++info->len;
      }
  }
//删除栈顶
  Tree  *removeStack(StackInfo *info)
 {
      Stack  *tmp=NULL;
      Tree   *node=NULL;
      if(info->len)
     {
         tmp=info->front;
         info->front=tmp->next;
         --info->len;
         node=tmp->node;
         free(tmp);
         return node;
      }
      return NULL;
  }
  int IsStackEmpty(StackInfo *info)
 {
     return !info->len;
  }
//中序遍历树
  void  InorderVisit(Tree *tree)
 {
      StackInfo *info;
      Tree      *node;
//将根节点加入堆栈中
      info=CreateStackInfo();
//      addStack(info,tree);
//开始遍历
      while(!IsStackEmpty(info) || tree)
     {
          while(tree)
         {
              addStack(info,tree);
              tree=tree->lchild;
          }
          node=removeStack(info);
          printf("data:%4d,index:%2d \n",node->data,node->index);
//          tmp=node
          tree=node->rchild;
      }
      printf("***********中序遍历结束*******************\n");
      free(info);
   }
//层序遍历
  void  LevelVisit(Tree *tree)
 {
      StackInfo *info;
      Tree      *node=NULL;
      info=CreateStackInfo();
    //  addStack(info,tree);
	  node=tree;
      while(node)
     {
          printf("data:%4d ,index:%2d \n",node->data,node->index);
          if(node->lchild)
             addStack(info,node->lchild);
          if(node->rchild)
             addStack(info,node->rchild);
          node=removeStack(info); 

      }
      printf("********层序遍历结束************\n");
      free(info);
  }
//********************************************************************
  int main(int argc,char *argv[])
 {
      Tree *tree=CreateTree(MAX_SIZE);

      printf("中序遍历树:\n");
      InorderVisit(tree);
      printf("层序遍历树:\n");
      LevelVisit(tree);
  
      return 0;
  }