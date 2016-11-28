//�������ı���
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define MAX_SIZE   16
//�����������ݽṹ  
  typedef struct _Tree
 {
      int  data;
      int  index;
      struct  _Tree  *lchild;
      struct  _Tree  *rchild;
  }Tree;
//�����ջ�����ݽṹ
  typedef struct _Stack
 {
      struct _Tree   *node;
      struct _Stack  *next;
  }Stack;
//�����ջ�������Ϣ�����ݽṹ
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
//���������
  void  LevelVisit(Tree *);
//���������
  void  InorderVisit(Tree *);
//**************************************************
//��ʼ�����Ľڵ�
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
//��ʼ�������������
      srand(seed);
//����ͷ���
      tree=(Tree *)malloc(sizeof(Tree));
      init(tree,i++);
//�ڶ���
      lchild=(Tree *)malloc(sizeof(Tree));
      init(lchild,i++);
      tree->lchild=lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->rchild=rchild;
//������      
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
//�����(��������)
      lchild=tree->lchild->lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      lchild->rchild=rchild;

      return tree;
  }
//������ջ��Ϣ
  StackInfo  *CreateStackInfo()
 {
      StackInfo  *info;
      info=(StackInfo *)malloc(sizeof(StackInfo));
      info->len=0;
      info->front=NULL;
      info->rear=NULL;
      return info;
  }
//���ջ��Ϣ����Ӷ�ջ��
  void addStack(StackInfo *info,Tree *node)
 {
//ע�⣬����û�д�����
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
//ɾ��ջ��
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
//���������
  void  InorderVisit(Tree *tree)
 {
      StackInfo *info;
      Tree      *node;
//�����ڵ�����ջ��
      info=CreateStackInfo();
//      addStack(info,tree);
//��ʼ����
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
      printf("***********�����������*******************\n");
      free(info);
   }
//�������
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
      printf("********�����������************\n");
      free(info);
  }
//********************************************************************
  int main(int argc,char *argv[])
 {
      Tree *tree=CreateTree(MAX_SIZE);

      printf("���������:\n");
      InorderVisit(tree);
      printf("���������:\n");
      LevelVisit(tree);
  
      return 0;
  }