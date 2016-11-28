//线索二叉树的遍历
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define MAX_SIZE   16
//定义树的数据结构  
  typedef struct _Tree
 {
      int  data;
      int  index;
//线索标记
      int  ltchild;
      int  rtchild;
      struct  _Tree  *lchild;
      struct  _Tree  *rchild;
  }Tree;

//********************************************
  Tree  *CreateTree(int);
  void  inorder(Tree *);
  Tree  *find_next_inorder_node(Tree *);
  void  insert_rchild(Tree *,Tree *);
  void  insert_lchild(Tree *,Tree *);

//**************************************************
//初始化树的节点
  void  init(Tree *node,int index)
 {
      node->data=rand();
      node->index=index;
      node->rtchild=0;
      node->ltchild=0;
      node->lchild=NULL;
      node->rchild=NULL;
  }
//**************************************************
  Tree *CreateTree(int limit)
 {
      Tree *tree,*lchild,*rchild,*tmp;
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
      tmp=lchild;
//叶节点线索化3
      tmp->ltchild=0x80000000;
      tmp->lchild=NULL;

      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->lchild->rchild=rchild;
//叶节点线索化4
      tmp=tree->lchild->rchild;
      tmp->ltchild=1;
      tmp->rtchild=1;
      tmp->lchild=tree->lchild;
      tmp->rchild=tree;
   
      lchild=(Tree *)malloc(sizeof(Tree));
      init(lchild,i++);
      tree->rchild->lchild=lchild;
//叶节点线索化5
      tmp=tree->rchild->lchild;
      tmp->ltchild=1;
      tmp->rtchild=1;
      tmp->lchild=tree;
      tmp->rchild=tree->rchild;

      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->rchild->rchild=rchild;
//叶节点线索化6
      tmp=tree->rchild->rchild;
      tmp->ltchild=1;
      tmp->rtchild=1;
      tmp->lchild=tree->rchild;
      tmp->rchild=NULL;
//第四层(非完整的)
      lchild=tree->lchild->lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      lchild->rchild=rchild;
//叶节点线索化7
      tmp=tree->lchild->lchild->rchild;
      tmp->ltchild=1;
      tmp->rtchild=0x80000000;
      tmp->lchild=tree->lchild->lchild;
      tmp->rchild=tree->lchild;

      return tree;
  }

//寻找节点的中序遍历后继节点
  Tree  *find_next_inorder_node(Tree *node)
 {
      Tree *tmp;
      tmp=node->rchild;
//如果当前节点有右子树,继续遍历
      if(!node->rtchild && tmp)
     {
          while(!tmp->ltchild)
             tmp=tmp->lchild;
      }
      return tmp;
  }
//寻找下一个节点的前驱节点
  Tree  *find_prev_node(Tree *tree)
 {
      Tree *tmp=tree,*node=NULL;
      Tree *root=tree;
//将给定的节点看做是一棵树的根节点,从该树的最左下端叶节点开始遍历
      while(root && !root->ltchild)
         root=root->lchild;
      while(root)
     {
         node=find_next_inorder_node(root);
         if(node==tree)
            return root;
         root=node;
      }
      return NULL;
  }   
//中序遍历树
  void  inorder(Tree *root)
 {
      Tree  *node=root;
//找到最左下端的节点
      while(!node->ltchild)
          node=node->lchild;
      while(node)
     {
          printf("data:%4d , index:%2d \n",node->data,node->index);
          node=find_next_inorder_node(node);
      }
     printf("*************************枚举完毕*******************************\n");
   }
//向线索二叉树中插入右节点,注意，这里没有数据的合法性检查
  void  insert_rchild(Tree *parent,Tree *child)
 {
      Tree  *tmp;
      child->rchild=parent->rchild;
      child->ltchild=1;
      child->lchild=parent;
      child->rtchild=parent->rtchild;
      parent->rtchild=0;
      parent->rchild=child;
      if(!child->rtchild)
     {
         tmp=find_next_inorder_node(child);
         if(tmp)
           tmp->lchild=child;
      }
  }
//向线索二叉树中插入左节点,注意，寻找左边节点的下一个要访问的节点的方法
//和寻找右边节点的下一个要访问的节点的方法是不同的
  void insert_lchild(Tree *parent,Tree *child)
 {
      Tree  *tmp;
      tmp=parent->lchild;
      child->lchild=tmp;
      child->ltchild=parent->ltchild;
//被插入的子节点的右指针一定是一个线索
      child->rtchild=1;
      child->rchild=parent;
      parent->lchild=child;
      parent->ltchild=0;
//如果原来父节点的左指针不是线索
      if(!child->ltchild)
     {
         tmp->rchild=child;
      }
  }

//********************************************************************
  int main(int argc,char *argv[])
 {
      Tree *parent,*child;
      Tree *tree=CreateTree(MAX_SIZE);
      printf("构造树完毕!\n");
      parent=tree;
      while(!parent->ltchild)
        parent=parent->lchild;

      printf("中序遍历树:\n");
      inorder(tree);

      printf("向生成的树插入一个左节点,结果如下:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,8);
      insert_lchild(parent,child);
      inorder(tree);

      printf("再次向同一个位置插入一个左节点,结果如下:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,9);
      insert_lchild(parent,child);
      inorder(tree);
//*****************************************************
      printf("------------------------------------------------------\n");
      printf("向生成的树插入一个右节点:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,10);
      insert_rchild(parent,child);
      inorder(tree);

      printf("再次向同一个节点插入一个右节点:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,11);
      insert_rchild(parent,child);
      inorder(tree);

      return 0;
  }