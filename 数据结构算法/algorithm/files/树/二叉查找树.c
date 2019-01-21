//二叉查找树的相关操作，这个程序依据的是算法导论
//2012/11/2/19:03
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
//***************************************************
//定义树结点的相关数据结构
  typedef  struct  _Tree
 {
//数据域
       int  data;
//flag的取值只能为1或者0，为0表示在进行删除操作时取左子树中的结点，否则取右子树中的结点
       int  flag;
//指向父结点指针
       struct  _Tree  *parent;
//指向左儿子的指针
       struct  _Tree  *lchild;
//指向右儿子的指针
       struct  _Tree  *rchild;
  }Tree;
//定义树的相关信息结构
  typedef  struct  _TreeInfo
 {
//记录整个树结点的数目
       int  nodes;
//记录树的根节点
       struct  _Tree  *root;
  }TreeInfo;
//用给定的数组创建一个二叉排序树
  void  CreateTree(TreeInfo *,int  *,int);
//将给定的一个数据插入到二叉排序树中
  int  insert(TreeInfo *,int);
//寻找一个树结点的后继结点
  Tree  *find_next(Tree *);
//寻找一个树结点的后继节点
  Tree  *find_prev(Tree  *);
//查找以给定的结点为根结点的树的最小元素结点
  Tree  *find_min(Tree  *);
//查找以给定的结点为根结点的树的最大元素结点
  Tree  *find_max(Tree  *);
//删除树中的结点

  void  CreateTree(TreeInfo *info,int *digit,int n)
 {
      int  i;
      info->nodes=n;
      info->root=NULL;
      
      for(i=0;i<n;++i)
         insert(info,digit[i]);
  }
//************************************************************
  int  insert(TreeInfo *info,int data)
 {
      Tree  *node,*tmp;
      int   flag=0;
      tmp=info->root;
      node=NULL;
      while(tmp)
     {
           node=tmp;
           if(data>tmp->data)
               tmp=tmp->rchild;
           else if(data<tmp->data)
               tmp=tmp->lchild;
           else
          {
               flag=1;
               break;
           }
      }
//如果给定的数据元素还没有在树中出现，则插入成功，否则失败
      if(! flag)
     {
           tmp=(Tree *)malloc(sizeof(Tree));
           tmp->data=data;
           tmp->flag=0;
           tmp->parent=node;
           tmp->lchild=NULL;
           tmp->rchild=NULL;

           if(info->root)
          {
                
               if(data>node->data)
                    node->rchild=tmp;
               else
                    node->lchild=tmp;
           }
           else
               info->root=tmp;
           return 1;
      }
      return 0;
  }
//******************************************************************
//查找后继结点
  Tree  *find_next(Tree  *node)
 {
       Tree  *tmp=NULL;
//如果给定结点的右子树不为空     
       if(node->rchild)
             return  find_min(node->rchild);
//否则就在其祖先结点中进行寻找
       tmp=node->parent;
       while(tmp  &&  tmp->rchild==node)
      {
             node=tmp;
             tmp=tmp->parent;
       }
       return tmp;
  }
//查找给定结点的前驱结点
  Tree  *find_prev(Tree  *node)
 {
       Tree  *tmp;
//如果其左子树不为空，则其前驱结点就在其左子树中
       if(node->lchild)
            return  find_max(node->lchild);
//否则就在其右子树中进行查找
       tmp=node->parent;
       while(tmp && tmp->lchild==node)
      {
            node=tmp;
            tmp=tmp->parent;
       }
       return tmp;
  }
//查找以给定结点为根结点的树的最小元素
  Tree  *find_min(Tree  *root)
 {
      while(root->lchild)
          root=root->lchild;
      
      return  root;
  }
//查找以给定结点为根结点的树的最大元素
  Tree  *find_max(Tree  *root)
 {
      while(root->rchild)
          root=root->rchild;

      return  root;
  }
//****************************和删除相关的操作************************************
  static void  remove_with_single(TreeInfo *info,Tree  *node)
 {
       Tree  *parent,*tmp;

       if(node->lchild)
      {
//如果被删除的结点不是根结点
           tmp=node->lchild;
           if(node!=info->root)
          {
                parent=node->parent;
                tmp->parent=parent;

                if(parent->lchild==node)
                     parent->lchild=tmp;
                else
                     parent->rchild=tmp;
           }
           else
          {
                info->root=tmp;
                tmp->parent=NULL;
           }
        }
       else if(node->rchild)
      {
           tmp=node->rchild;
           if(node!=info->root)
          {
                parent=node->parent;
                tmp->parent=parent;
                if(parent->lchild==node)
                    parent->lchild=tmp;
                else
                    parent->rchild=tmp;
            }
            else
           {
                info->root=tmp;
                tmp->parent=NULL;
            }
       }
//否则，如果该节点没有子结点
       else
      {
            parent=node->parent;
            if(node!=info->root)
           {
                 if(parent->lchild==node)
                      parent->lchild=NULL;
                 else
                      parent->rchild=NULL;
            }
            else
                info->root=NULL;
       }
  }
//......................................................
  static  void  remove_with_d(TreeInfo *info,Tree *node)
 {
       Tree  *parent,*tmp;
       Tree  *child;
//如果node->flag的值为0，则删除左子树中的结点,否则删除右子树中的结点，
//这样就能保持大致的平衡
       if(! node->flag)
      {
//            printf(" 000  ");
            tmp=find_prev(node);
//如果被删除的结点不是根结点
//接下来的这一步判断很重要，注意!
            parent=node->parent;
            if(tmp!=node->lchild)
           {
                child=tmp->lchild;
                tmp->parent->rchild=child;
                if(child)
                    child->parent=tmp->parent;

                tmp->rchild=node->rchild;                     
                node->rchild->parent=tmp;
                tmp->lchild=node->lchild;
                node->lchild->parent=tmp;
             }
             else
            {
                  tmp->rchild=node->rchild;
                  node->rchild->parent=tmp;
             }
             tmp->parent=parent;
             if(node!=info->root)
            {
                  if(node==parent->lchild)
                       parent->lchild=tmp;
                  else
                       parent->rchild=tmp;
             }
             else
                  info->root=tmp;
             tmp->flag=1;
//             printf(" 010 \n");
      }
      else   //否则，在右子树中寻找目标结点
     {
//           printf(" UUU ");
           tmp=find_next(node);
           parent=node->parent;
           if(tmp!=node->rchild)
          {
                child=tmp->rchild;//注意，这一步，tmp不可能有左儿子
                tmp->parent->lchild=child;
                if(child)
                   child->parent=tmp->parent;
//开始进行指针重构
                 tmp->rchild=node->rchild;
                 node->rchild->parent=tmp;
                 tmp->lchild=node->lchild;
                 node->lchild->parent=tmp;
           }
           else
          {
                 tmp->lchild=node->lchild;
                 node->lchild->parent=tmp;
           }
           tmp->parent=parent;
           if(node!=info->root)
          {
                 if(parent->lchild==node)
                      parent->lchild=tmp;
                 else
                      parent->rchild=tmp;
           }
           else
                info->root=tmp;
          tmp->flag=0;
       }
  }
//删除与给定的数据相同的元素结点,若成功返回1，否则返回0
  int  remove_node(TreeInfo  *info,int data)
 {
      int   r=0;
      Tree  *node;
    
      node=info->root;
      while(node)
     {
           if(data>node->data)
                node=node->rchild;
           else if(data<node->data)
                node=node->lchild;
           else
          {
                r=1;
                break;
           }
      }
//若果查找不成功，则直接返回
      if(! r)
          return 0;
//如果目标结点只有一个子结点
      if(!node->lchild || !node->rchild)
     {
//             printf(" & ");
             remove_with_single(info,node);
//             printf("& \n");
      }
//否则，目标结点右两个子节点
      else
     {
//             printf(" $");
             remove_with_d(info,node);
//             printf(" $ \n");
      }
      --info->nodes;
      free(node);
      return 1;
  }   
  int  main(int argc,char *argv[])
 {
      int  data[16];
      int  i=0;
      TreeInfo  info;
      Tree      *node;
 
      i=time(NULL);
      srand(i);
      for(i=0;i<16;++i)
           data[i]=rand();

      for(i=0;i<16;++i)
          printf("  %d  ",data[i]);

      printf("\n开始创建二叉排序树...\n");
      CreateTree(&info,data,16);
      node=info.root;

      while(node->lchild)
          node=node->lchild;
      printf("依次以后继的方式遍历二叉排序树的结点...\n");

      while(node)
     {
           printf("  %d  ",node->data);
           node=find_next(node);
      }
      printf("\n");
      node=info.root;
  
      while(node->rchild)
           node=node->rchild;

      printf("依次以前驱的方式遍历二叉排序树中的结点...\n");
      while(node)
     {
           printf("  %d  ",node->data);
           node=find_prev(node);
      }
      printf("\n");
      printf("现在开始删除结点元素!\n");
      for(i=0;i<16;++i)
     {
          printf("开始删除元素%d \n",data[i]);
          remove_node(&info,data[i]);
      }
      return  0;
  }
      

      