//关于查找树(一种链式二叉树)的操作
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  
  #define  MAX_SIZE   8
  
  typedef struct  _Tree
 {
     int  data;
     struct  _Tree  *parent;
     struct  _Tree  *lchild;
     struct  _Tree  *rchild;
  }Tree;
//关于查找树的相关操作方法
  Tree  *CreateSearchTree(int *,int);
//向树中插入节点
  int   insert_node(Tree  *,int);
//向树中查找给定的键值是否存在
  Tree  *search_node(Tree  *,int);
//另一种特殊的查找操作
//  Tree  *modified_search(Tree *,int);
//删除给定的键值所对应的节点
  int  remove_node(Tree **,int);
//遍历查找树的所有节点
  void  visit_tree(Tree *);
  
  #ifndef  TREE_CONTAINED
     #include  "tree.c"
  #endif
//初始化树的节点
  void  init(Tree *node)
 {
      node->data=0x80000000;
      node->parent=NULL;
      node->lchild=NULL;
      node->rchild=NULL;
  }
//根据给定的键值创建一棵查找树
  Tree  *CreateSearchTree(int  *key,int len)
 {
     Tree  *root;
     int   i;

     if(len<=0)
       return NULL;
//先建立根节点
     root=(Tree *)malloc(sizeof(Tree));
     init(root);
     root->data=key[0];
//开始以一种正常化的手段来建立查找树
     for(i=1;i<len;++i)
         insert_node(root,key[i]);
     return root;
  }

//向树中插入一个节点
  int  insert_node(Tree *root,int key)
 {
      
     Tree  *tmp=NULL,*node;
     node=root;
     while(node)
    {
        tmp=node;
        if(key>node->data)
            node=node->rchild;
        else if(key<node->data)
            node=node->lchild;
        else
            break;
     }
     if(node && node->data==key)
         return 0;
     node=(Tree *)malloc(sizeof(Tree));
     init(node);
     node->data=key;
     if(key<tmp->data)
    {
         node->parent=tmp;
//交换索引
         tmp->lchild=node;
     }
     else
    {
         tmp->rchild=node;
         node->parent=tmp;
     }
     return 1;
  }
//查找给定的键值是否有对应的节点存在
  Tree  *search_node(Tree *root,int key)
 {
     Tree  *node;
     node=root;
     while(node)
    {
        if(key>node->data)
            node=node->rchild;
        else if(key<node->data)
            node=node->lchild;
        else
            return node;
     }
     return NULL;
  }
//删除给定的键值所对应的节点,注意删除操作上的复杂性,考虑情况时一定要谨慎
  int  remove_node(Tree  **root,int key)
 {
      Tree  *node=*root;
      Tree  *tmp=node;
      Tree  *parent;
//     node=root;
//查找将要被删除的节点,node节点作为被删除节点的父节点，而tmp作为被删除节点
      while(node)
     {
          if(key>node->data)
              node=node->rchild;
          else if(key<node->data)
              node=node->lchild;
          else
              break;
       }
//      printf("&");
//如果没有找到要被删除的节点,就退出
       if(!node)
           return 0;
//如果找到的节点是根节点
       if(!node->parent)
      {
//如果其左子树不为空，就搜索其左子树的最大值节点.注意其最大值节点的度一定为0或1
           if(node->lchild)
          {
               tmp=node->lchild;
               while(tmp->rchild)
                   tmp=tmp->rchild;
//如果选中的节点是根节点的左儿子

               if(tmp==node->lchild)
              {
 //                 printf("000");  
                  tmp->rchild=node->rchild;
                  if(node->rchild)
                     node->rchild->parent=tmp;
                  tmp->parent=NULL;
                  *root=tmp;                
                  free(node);
                  return 1;
               }
//               printf("001");
               parent=tmp->parent;
               parent->rchild=tmp->lchild;
//以找到的节点作为根节点，开始重新构建查找树
               if(tmp->lchild)
                   tmp->lchild->parent=parent;
               tmp->lchild=node->lchild;
               tmp->rchild=node->rchild;
               tmp->lchild->parent=tmp;
               tmp->parent=NULL;
               if(tmp->rchild)
                   tmp->rchild->parent=tmp;
               free(node);
               *root=tmp;
               return 1;
            }
            else if(node->rchild)
           {
                tmp=node->rchild;
                while(tmp->lchild)
                    tmp=tmp->lchild;
                if(tmp==node->rchild)
               {
//                   printf("002");
                   tmp->parent=NULL;
                   free(node);
                   (*root)=tmp;
                   return 1;
                }
 //               printf("003");
                parent=tmp->parent;
                parent->lchild=tmp->rchild;
//因为已经知道了根节点的左子树为空，所以剩下的操作就减少了
                if(tmp->rchild)
                   tmp->rchild->parent=parent;
                tmp->parent=NULL;
                tmp->rchild=node->rchild;
                tmp->lchild=NULL;
                free(node);
                (*root)=tmp;
                return 1;
//剩下的一部是多余的，写上它只是为了使逻辑上看起来更清晰一些
             }
             else
            {
//                printf("004");
                free(node);
                (*root)=NULL;
                return 1;
             }
       }
//如果目标节点不是根节点
//开始寻找目标节点的左子树最大值节点
      if(node->lchild)
     {
           tmp=node->lchild;
           while(tmp->rchild)
               tmp=tmp->rchild;
           if(tmp==node->lchild)
          {
//               printf("005");
               parent=node->parent;
//如果被删除的节点是右节点
               if(parent->rchild==node)
              {
                   parent->rchild=tmp;
                   tmp->parent=parent;
                   tmp->rchild=node->rchild;
                   if(node->rchild)
                       node->rchild->parent=tmp;
               }
               else
              {
                   parent->lchild=tmp;
                   tmp->parent=parent;
                   tmp->rchild=node->rchild;
                   if(node->rchild)
                      node->rchild->parent=tmp;
               }
               free(node);
               return 1;
            }
//如果替代被删除的节点不是被删节点的子节点
           parent=tmp->parent;
           parent->rchild=tmp->lchild;
           if(tmp->lchild)
               tmp->lchild->parent=parent;
           parent=node->parent;
//区分被删除的节点是左节点还是右节点
//           printf("006");
           if(node==parent->rchild)
          {
                parent->rchild=tmp;
                tmp->lchild=node->lchild;
                tmp->rchild=node->rchild;
                tmp->parent=parent;
             //   if(tmp->lchild)
                tmp->lchild->parent=tmp;
                if(tmp->rchild)
                   tmp->rchild->parent=tmp;
            }
            else
           { 
                parent->lchild=tmp;
                tmp->lchild=node->lchild;
                tmp->rchild=node->rchild;
                tmp->parent=parent;
                if(tmp->rchild)
                    tmp->rchild->parent=tmp;
                tmp->lchild->parent=tmp;
            }
            free(node);
            return 1;
       }
       else if(node->rchild)
      {
            tmp=node->rchild;
            while(tmp->lchild)
               tmp=tmp->lchild;
//因为已经确定目标节点的左子树不存在了，所以少了很多操作
            if(tmp==node->rchild)
           {
//                 printf("007");
                 parent=node->parent;
//区分被删除的是左还是右节点
                 if(parent->rchild==node)
                {
                      parent->rchild=tmp;
                      tmp->parent=parent;
                      tmp->lchild=NULL;
                 }
                 else
                {
                      parent->lchild=tmp;
                      tmp->parent=parent;
                      tmp->lchild=NULL;
                 }
//                 printf("&&&");
                 free(node);
//                 printf("###");
                 return 1;
            }
//            printf("008");
            parent=tmp->parent;
            parent->lchild=tmp->rchild;
            if(tmp->rchild)
                tmp->rchild->parent=parent;
            parent=node->parent;
            tmp->parent=parent;
            if(parent->rchild==node)
           {
                 parent->rchild=tmp;
                 tmp->rchild=node->rchild;
                 tmp->lchild=NULL;
                 tmp->rchild->parent=tmp;
            }
            else
           {
                 parent->lchild=tmp;
                 tmp->rchild=node->rchild;
                 tmp->lchild=NULL;
                 tmp->rchild->parent=tmp;
            }
            free(node);
            return 1;
       }
       else
      {
//            printf("009");
            parent=node->parent;
            if(parent->rchild==node)
                parent->rchild=NULL;
            else
                parent->lchild=NULL;
            free(node);
            return 1;
       }
//      printf("EEE");
      return 0; 
  }
  
  int main(int  argc,char  *argv[])
 {
      int  ary[MAX_SIZE];
      int  i,seed;
      Tree  *root;
      seed=10160302;
      srand(seed);
      printf("数组的元素为:\n");
      for(i=0;i<MAX_SIZE;++i)
     {
          ary[i]=rand();
          printf("%d  ",ary[i]);
      }
      putchar('\n');
      root=CreateSearchTree(ary,MAX_SIZE);
	  if(!root)
		  printf("-------\n");
      printf("查找树的中序遍历结果如下:\n");
      VisitTree(root);
      if(search_node(root,ary[5]))
     {
          printf("已经成功查找元素ary[5]:%d的位置!\n",ary[5]);
      }
      else
     {
          printf("很遗憾，没有查找到要找的元素,您设计的查找树不合格!\n");
      }
      printf("现在开始删除所有的元素\n");
      for(i=0;i<MAX_SIZE;++i)
     {
          printf("第%d次遍历查找树,现在查找元素:%d\n",i,ary[i]);
          printf("删除元素前:查找树的情况为:\n");
          VisitTree(root);
          printf("删除后的情况为:\n");
          if(!remove_node(&root,ary[i]))
               printf("第%d删除元素失败!\n");
          VisitTree(root);
// printf("$$$"); 
          printf("-----------------------------------------------------------\n");
      }
      if(!root)
     {
          printf("恭喜，已经成功第删除掉所有的元素了!\n");
      }
      else
     {
          printf("很遗憾，我们未能删除掉所有的元素，您设计的查找树不合格!\n");
      }
//      printf("再次中序遍历:\n")
  }