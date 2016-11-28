/*
  *@aim:求树的深度
  *@date:2015-12-17 17:16:08
  *@author:狄建彬
  */
#include<stack>
#include<stdio.h>
//
  struct      Tree
 {
                int                           key;
                struct        Tree     *parent;
                struct        Tree     *lchild,*rchild;
                Tree(Tree    *,Tree *,Tree *);
                Tree();
                ~Tree();
  };
  Tree::Tree()
 {
                 this->parent=NULL;
                 this->lchild=NULL;
                 this->rchild=NULL;
  }
  Tree::Tree(Tree    *_parent,Tree   *_lchild,Tree  *_rchild)
 {
                this->parent=_parent;
                this->lchild=_lchild;
                this->rchild=_rchild;
  }
  Tree::~Tree()
 {
 
  }
//求树的深度
  int                tree_depth(Tree      *root)
 {
                 int              depth=0;
                 std::stack<int>           flag;
                 std::stack<Tree *>      tree;
                 Tree           *y=root;
//注意flag中不会有连续的1但是会有连续的0
                 while( y   ||   tree.size() )
                {
                               while(   y )
                              {
//左分支入栈,并同时做上标志
                                              tree.push(y);
                                              y=y->lchild;
                                              flag.push(0);
                               }
//假设已经入栈完毕,此时可以肯定y==NULL
                               if( ! flag.top()  )//如果是左分支,此时可以肯定
                              {
                                              y=tree.top()->rchild;
//标记将要处理右分支
                                              flag.pop();
                                              flag.push(1);
                               }
                               else//此时可以肯定,最后处理的树节点已经没有了左右子结点&&y==NULL
                              {
                                              if(depth<tree.size())
                                                          depth=tree.size();
                                              tree.pop();
                                              flag.pop();
                               }
                 }
                 return    depth;
  }
  Tree            *gen_tree(int  left,int  right)
 {
                Tree       *lchild=NULL;
               Tree        *rchild=NULL;
               
               if( left )
                        lchild=new     Tree();
               if(right)
                        rchild=new     Tree();
               return          new     Tree(NULL,lchild,rchild);
  }
  //
    int          main(int   argc,char   *argv[])
   {
               Tree             *root=NULL;
               Tree             *lchild,*y;
               Tree             *rchild;
               
               root=gen_tree(1,1);
               y=root;
               lchild=y->lchild;
               lchild->lchild=gen_tree(0,1);
               rchild=lchild->lchild->rchild;
               rchild->lchild=new   Tree(rchild,NULL,NULL);
               
               rchild=gen_tree(1,0);
               lchild->rchild=rchild;
               
               rchild->lchild->rchild=new    Tree();
               
               y->rchild->rchild=new    Tree();
               
               printf("depth is:%d\n",tree_depth(root));
               return  0;
    }