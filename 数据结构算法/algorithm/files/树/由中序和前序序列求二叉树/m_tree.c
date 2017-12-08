//为二叉树的操作提供可访问的接口操作
//注意，文件中必须包含有<stdio.h> <stdlib.h> <time.h>
//定义堆栈的数据结构
  #define   TREE_CONTAINED  1
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
  void  VisitTree(Tree *);
  StackInfo  *CreateStackInfo();
  void  addStack(StackInfo *,Tree *);
  Tree *removeStack(StackInfo *);
  int   IsStackEmpty(StackInfo *);
//********************************************
  void (*callback)(Tree *);
//中序遍历树
  void  VisitTree(Tree *tree)
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
          tree=node->rchild;
          callback(node);
      }
      printf("***********中序遍历结束*******************\n");
      free(info);
   }
//判断栈是否为空
  int IsStackEmpty(StackInfo *info)
 {
     return !info->len;
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
//前序遍历
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
      printf("前序遍历结束!\n");
  }