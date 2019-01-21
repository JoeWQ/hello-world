//Ϊ�������Ĳ����ṩ�ɷ��ʵĽӿڲ���
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
  void  VisitTree(Tree *);
  StackInfo  *CreateStackInfo();
  void  addStack(StackInfo *,Tree *);
  Tree *removeStack(StackInfo *);
  int   IsStackEmpty(StackInfo *);
//********************************************
  void (*callback)(Tree *);
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
          tree=node->rchild;
          callback(node);
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
//ǰ�����
  void  Preorder(Tree  *root)
 {
      StackInfo  *info;
      Tree       *node;
      info=CreateStackInfo();
      node=root;
      while(!IsStackEmpty(info) || node)
     {
           while(node)
          {
               callback(node);
               addStack(info,node);
               node=node->lchild;
           }
           node=removeStack(info);
//           callback(node);
           node=node->rchild;
       }
      printf("ǰ���������!\n");
  }