//�����������ı���
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define MAX_SIZE   16
//�����������ݽṹ  
  typedef struct _Tree
 {
      int  data;
      int  index;
//�������
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
//��ʼ�����Ľڵ�
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
      tmp=lchild;
//Ҷ�ڵ�������3
      tmp->ltchild=0x80000000;
      tmp->lchild=NULL;

      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->lchild->rchild=rchild;
//Ҷ�ڵ�������4
      tmp=tree->lchild->rchild;
      tmp->ltchild=1;
      tmp->rtchild=1;
      tmp->lchild=tree->lchild;
      tmp->rchild=tree;
   
      lchild=(Tree *)malloc(sizeof(Tree));
      init(lchild,i++);
      tree->rchild->lchild=lchild;
//Ҷ�ڵ�������5
      tmp=tree->rchild->lchild;
      tmp->ltchild=1;
      tmp->rtchild=1;
      tmp->lchild=tree;
      tmp->rchild=tree->rchild;

      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      tree->rchild->rchild=rchild;
//Ҷ�ڵ�������6
      tmp=tree->rchild->rchild;
      tmp->ltchild=1;
      tmp->rtchild=1;
      tmp->lchild=tree->rchild;
      tmp->rchild=NULL;
//���Ĳ�(��������)
      lchild=tree->lchild->lchild;
      rchild=(Tree *)malloc(sizeof(Tree));
      init(rchild,i++);
      lchild->rchild=rchild;
//Ҷ�ڵ�������7
      tmp=tree->lchild->lchild->rchild;
      tmp->ltchild=1;
      tmp->rtchild=0x80000000;
      tmp->lchild=tree->lchild->lchild;
      tmp->rchild=tree->lchild;

      return tree;
  }

//Ѱ�ҽڵ�����������̽ڵ�
  Tree  *find_next_inorder_node(Tree *node)
 {
      Tree *tmp;
      tmp=node->rchild;
//�����ǰ�ڵ���������,��������
      if(!node->rtchild && tmp)
     {
          while(!tmp->ltchild)
             tmp=tmp->lchild;
      }
      return tmp;
  }
//Ѱ����һ���ڵ��ǰ���ڵ�
  Tree  *find_prev_node(Tree *tree)
 {
      Tree *tmp=tree,*node=NULL;
      Tree *root=tree;
//�������Ľڵ㿴����һ�����ĸ��ڵ�,�Ӹ����������¶�Ҷ�ڵ㿪ʼ����
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
//���������
  void  inorder(Tree *root)
 {
      Tree  *node=root;
//�ҵ������¶˵Ľڵ�
      while(!node->ltchild)
          node=node->lchild;
      while(node)
     {
          printf("data:%4d , index:%2d \n",node->data,node->index);
          node=find_next_inorder_node(node);
      }
     printf("*************************ö�����*******************************\n");
   }
//�������������в����ҽڵ�,ע�⣬����û�����ݵĺϷ��Լ��
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
//�������������в�����ڵ�,ע�⣬Ѱ����߽ڵ����һ��Ҫ���ʵĽڵ�ķ���
//��Ѱ���ұ߽ڵ����һ��Ҫ���ʵĽڵ�ķ����ǲ�ͬ��
  void insert_lchild(Tree *parent,Tree *child)
 {
      Tree  *tmp;
      tmp=parent->lchild;
      child->lchild=tmp;
      child->ltchild=parent->ltchild;
//��������ӽڵ����ָ��һ����һ������
      child->rtchild=1;
      child->rchild=parent;
      parent->lchild=child;
      parent->ltchild=0;
//���ԭ�����ڵ����ָ�벻������
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
      printf("���������!\n");
      parent=tree;
      while(!parent->ltchild)
        parent=parent->lchild;

      printf("���������:\n");
      inorder(tree);

      printf("�����ɵ�������һ����ڵ�,�������:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,8);
      insert_lchild(parent,child);
      inorder(tree);

      printf("�ٴ���ͬһ��λ�ò���һ����ڵ�,�������:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,9);
      insert_lchild(parent,child);
      inorder(tree);
//*****************************************************
      printf("------------------------------------------------------\n");
      printf("�����ɵ�������һ���ҽڵ�:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,10);
      insert_rchild(parent,child);
      inorder(tree);

      printf("�ٴ���ͬһ���ڵ����һ���ҽڵ�:\n");
      child=(Tree *)malloc(sizeof(Tree));
      init(child,11);
      insert_rchild(parent,child);
      inorder(tree);

      return 0;
  }