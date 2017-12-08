//**Ϊ�������Ĳ����ṩ�ɷ��ʵĽӿڲ���
//ע�⣬�ļ��б��������<stdio.h> <stdlib.h> <time.h>
//�����ջ�����ݽṹ
  #define   TREE_CONTAINED  1
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
  Tree  *CreateTree(int);
  void  VisitTree(Tree *);
  StackInfo  *CreateStackInfo();
  void  addStack(StackInfo *,Tree *);
  Tree *removeStack(StackInfo *);
  int   IsStackEmpty(StackInfo *);
//********************************************
//���������
  void  VisitTree(Tree *tree)
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
          printf("data:%4d,lchild:%8u ,rchild:%8u ,˫��:%8u,��ַ:%8u\n",node->data,node->lchild,node->rchild,node->parent,node);
          tree=node->rchild;
      }
      printf("***********�����������*******************\n");
      free(info);
   }
//�ж�ջ�Ƿ�Ϊ��
  int IsStackEmpty(StackInfo *info)
 {
     return !info->len;
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