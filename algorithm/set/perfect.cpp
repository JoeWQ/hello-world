/*
  *2016-2-3 17:17:24
  *�ǵݹ��㷨������������
  */
 //#include<stack>
 #include<stdio.h>
    struct     Tree
   {
//��ǰ���
                int                              depth;
                int                              key;
                struct      Tree          *lchild;
                struct      Tree          *rchild;
                struct      Tree          *parent;
                Tree(int,int);
    };
//
    Tree::Tree(int   _depth,int   _key)
   {
               this->depth=_depth;
               this->key=_key;
               this->lchild=NULL;
               this->rchild=NULL;
               this->parent=NULL;
    }
//_depthΪ�������
//@request:depth>0
    Tree           *make_perfect_tree(int     depth)
   {
                Tree          *x,*y;
                int             _index=1;
                Tree            *root=new    Tree(depth,_index++);
                y=root;
                while(y)
               {
//��һ��,ֱ�ӽ���������,ֻ�����<0
                             while(y->depth>1 && !y->lchild)
                            {
                                          x=new   Tree(y->depth-1,_index++);
                                          y->lchild=x;
                                          x->parent=y;
                                          y=x;
                             }
//ת��������
                             if(y->depth>1 && !y->rchild)
                            {
                                         x=new   Tree(y->depth-1,_index++);
                                         y->rchild=x;
                                         x->parent=y;
                                         y=x;
                             }
                             else
                                         y=y->parent;
                }
                return     root;
    }
//
    void                 visit(Tree  *y)
   {
//����
                 if(   y->lchild  )
                            visit(y->lchild);
                 printf("%d    ",y->key);
                 if(y->rchild  )
                            visit(y->rchild);
    }
    int                main(int   argc,char   *argv[])
   {         
                Tree             *y=make_perfect_tree(4);
                printf("-----------------------\n");
                visit(y);
                return  0;
    }