/*
  *@aim:���������
  *@date:2015-12-17 17:16:08
  *@author:�ҽ���
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
//���������
  int                tree_depth(Tree      *root)
 {
                 int              depth=0;
                 std::stack<int>           flag;
                 std::stack<Tree *>      tree;
                 Tree           *y=root;
//ע��flag�в�����������1���ǻ���������0
                 while( y   ||   tree.size() )
                {
                               while(   y )
                              {
//���֧��ջ,��ͬʱ���ϱ�־
                                              tree.push(y);
                                              y=y->lchild;
                                              flag.push(0);
                               }
//�����Ѿ���ջ���,��ʱ���Կ϶�y==NULL
                               if( ! flag.top()  )//��������֧,��ʱ���Կ϶�
                              {
                                              y=tree.top()->rchild;
//��ǽ�Ҫ�����ҷ�֧
                                              flag.pop();
                                              flag.push(1);
                               }
                               else//��ʱ���Կ϶�,���������ڵ��Ѿ�û���������ӽ��&&y==NULL
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