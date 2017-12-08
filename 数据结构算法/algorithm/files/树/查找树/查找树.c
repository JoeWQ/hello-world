//���ڲ�����(һ����ʽ������)�Ĳ���
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
//���ڲ���������ز�������
  Tree  *CreateSearchTree(int *,int);
//�����в���ڵ�
  int   insert_node(Tree  *,int);
//�����в��Ҹ����ļ�ֵ�Ƿ����
  Tree  *search_node(Tree  *,int);
//��һ������Ĳ��Ҳ���
//  Tree  *modified_search(Tree *,int);
//ɾ�������ļ�ֵ����Ӧ�Ľڵ�
  int  remove_node(Tree **,int);
//���������������нڵ�
  void  visit_tree(Tree *);
  
  #ifndef  TREE_CONTAINED
     #include  "tree.c"
  #endif
//��ʼ�����Ľڵ�
  void  init(Tree *node)
 {
      node->data=0x80000000;
      node->parent=NULL;
      node->lchild=NULL;
      node->rchild=NULL;
  }
//���ݸ����ļ�ֵ����һ�ò�����
  Tree  *CreateSearchTree(int  *key,int len)
 {
     Tree  *root;
     int   i;

     if(len<=0)
       return NULL;
//�Ƚ������ڵ�
     root=(Tree *)malloc(sizeof(Tree));
     init(root);
     root->data=key[0];
//��ʼ��һ�����������ֶ�������������
     for(i=1;i<len;++i)
         insert_node(root,key[i]);
     return root;
  }

//�����в���һ���ڵ�
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
//��������
         tmp->lchild=node;
     }
     else
    {
         tmp->rchild=node;
         node->parent=tmp;
     }
     return 1;
  }
//���Ҹ����ļ�ֵ�Ƿ��ж�Ӧ�Ľڵ����
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
//ɾ�������ļ�ֵ����Ӧ�Ľڵ�,ע��ɾ�������ϵĸ�����,�������ʱһ��Ҫ����
  int  remove_node(Tree  **root,int key)
 {
      Tree  *node=*root;
      Tree  *tmp=node;
      Tree  *parent;
//     node=root;
//���ҽ�Ҫ��ɾ���Ľڵ�,node�ڵ���Ϊ��ɾ���ڵ�ĸ��ڵ㣬��tmp��Ϊ��ɾ���ڵ�
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
//���û���ҵ�Ҫ��ɾ���Ľڵ�,���˳�
       if(!node)
           return 0;
//����ҵ��Ľڵ��Ǹ��ڵ�
       if(!node->parent)
      {
//�������������Ϊ�գ��������������������ֵ�ڵ�.ע�������ֵ�ڵ�Ķ�һ��Ϊ0��1
           if(node->lchild)
          {
               tmp=node->lchild;
               while(tmp->rchild)
                   tmp=tmp->rchild;
//���ѡ�еĽڵ��Ǹ��ڵ�������

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
//���ҵ��Ľڵ���Ϊ���ڵ㣬��ʼ���¹���������
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
//��Ϊ�Ѿ�֪���˸��ڵ��������Ϊ�գ�����ʣ�µĲ����ͼ�����
                if(tmp->rchild)
                   tmp->rchild->parent=parent;
                tmp->parent=NULL;
                tmp->rchild=node->rchild;
                tmp->lchild=NULL;
                free(node);
                (*root)=tmp;
                return 1;
//ʣ�µ�һ���Ƕ���ģ�д����ֻ��Ϊ��ʹ�߼��Ͽ�����������һЩ
             }
             else
            {
//                printf("004");
                free(node);
                (*root)=NULL;
                return 1;
             }
       }
//���Ŀ��ڵ㲻�Ǹ��ڵ�
//��ʼѰ��Ŀ��ڵ�����������ֵ�ڵ�
      if(node->lchild)
     {
           tmp=node->lchild;
           while(tmp->rchild)
               tmp=tmp->rchild;
           if(tmp==node->lchild)
          {
//               printf("005");
               parent=node->parent;
//�����ɾ���Ľڵ����ҽڵ�
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
//��������ɾ���Ľڵ㲻�Ǳ�ɾ�ڵ���ӽڵ�
           parent=tmp->parent;
           parent->rchild=tmp->lchild;
           if(tmp->lchild)
               tmp->lchild->parent=parent;
           parent=node->parent;
//���ֱ�ɾ���Ľڵ�����ڵ㻹���ҽڵ�
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
//��Ϊ�Ѿ�ȷ��Ŀ��ڵ���������������ˣ��������˺ܶ����
            if(tmp==node->rchild)
           {
//                 printf("007");
                 parent=node->parent;
//���ֱ�ɾ�����������ҽڵ�
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
      printf("�����Ԫ��Ϊ:\n");
      for(i=0;i<MAX_SIZE;++i)
     {
          ary[i]=rand();
          printf("%d  ",ary[i]);
      }
      putchar('\n');
      root=CreateSearchTree(ary,MAX_SIZE);
	  if(!root)
		  printf("-------\n");
      printf("����������������������:\n");
      VisitTree(root);
      if(search_node(root,ary[5]))
     {
          printf("�Ѿ��ɹ�����Ԫ��ary[5]:%d��λ��!\n",ary[5]);
      }
      else
     {
          printf("���ź���û�в��ҵ�Ҫ�ҵ�Ԫ��,����ƵĲ��������ϸ�!\n");
      }
      printf("���ڿ�ʼɾ�����е�Ԫ��\n");
      for(i=0;i<MAX_SIZE;++i)
     {
          printf("��%d�α���������,���ڲ���Ԫ��:%d\n",i,ary[i]);
          printf("ɾ��Ԫ��ǰ:�����������Ϊ:\n");
          VisitTree(root);
          printf("ɾ��������Ϊ:\n");
          if(!remove_node(&root,ary[i]))
               printf("��%dɾ��Ԫ��ʧ��!\n");
          VisitTree(root);
// printf("$$$"); 
          printf("-----------------------------------------------------------\n");
      }
      if(!root)
     {
          printf("��ϲ���Ѿ��ɹ���ɾ�������е�Ԫ����!\n");
      }
      else
     {
          printf("���ź�������δ��ɾ�������е�Ԫ�أ�����ƵĲ��������ϸ�!\n");
      }
//      printf("�ٴ��������:\n")
  }