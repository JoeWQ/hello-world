//�������������ز���������������ݵ����㷨����
//2012/11/2/19:03
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
//***************************************************
//����������������ݽṹ
  typedef  struct  _Tree
 {
//������
       int  data;
//flag��ȡֵֻ��Ϊ1����0��Ϊ0��ʾ�ڽ���ɾ������ʱȡ�������еĽ�㣬����ȡ�������еĽ��
       int  flag;
//ָ�򸸽��ָ��
       struct  _Tree  *parent;
//ָ������ӵ�ָ��
       struct  _Tree  *lchild;
//ָ���Ҷ��ӵ�ָ��
       struct  _Tree  *rchild;
  }Tree;
//�������������Ϣ�ṹ
  typedef  struct  _TreeInfo
 {
//��¼������������Ŀ
       int  nodes;
//��¼���ĸ��ڵ�
       struct  _Tree  *root;
  }TreeInfo;
//�ø��������鴴��һ������������
  void  CreateTree(TreeInfo *,int  *,int);
//��������һ�����ݲ��뵽������������
  int  insert(TreeInfo *,int);
//Ѱ��һ�������ĺ�̽��
  Tree  *find_next(Tree *);
//Ѱ��һ�������ĺ�̽ڵ�
  Tree  *find_prev(Tree  *);
//�����Ը����Ľ��Ϊ������������СԪ�ؽ��
  Tree  *find_min(Tree  *);
//�����Ը����Ľ��Ϊ�������������Ԫ�ؽ��
  Tree  *find_max(Tree  *);
//ɾ�����еĽ��

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
//�������������Ԫ�ػ�û�������г��֣������ɹ�������ʧ��
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
//���Һ�̽��
  Tree  *find_next(Tree  *node)
 {
       Tree  *tmp=NULL;
//�������������������Ϊ��     
       if(node->rchild)
             return  find_min(node->rchild);
//������������Ƚ���н���Ѱ��
       tmp=node->parent;
       while(tmp  &&  tmp->rchild==node)
      {
             node=tmp;
             tmp=tmp->parent;
       }
       return tmp;
  }
//���Ҹ�������ǰ�����
  Tree  *find_prev(Tree  *node)
 {
       Tree  *tmp;
//�������������Ϊ�գ�����ǰ������������������
       if(node->lchild)
            return  find_max(node->lchild);
//����������������н��в���
       tmp=node->parent;
       while(tmp && tmp->lchild==node)
      {
            node=tmp;
            tmp=tmp->parent;
       }
       return tmp;
  }
//�����Ը������Ϊ������������СԪ��
  Tree  *find_min(Tree  *root)
 {
      while(root->lchild)
          root=root->lchild;
      
      return  root;
  }
//�����Ը������Ϊ�������������Ԫ��
  Tree  *find_max(Tree  *root)
 {
      while(root->rchild)
          root=root->rchild;

      return  root;
  }
//****************************��ɾ����صĲ���************************************
  static void  remove_with_single(TreeInfo *info,Tree  *node)
 {
       Tree  *parent,*tmp;

       if(node->lchild)
      {
//�����ɾ���Ľ�㲻�Ǹ����
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
//��������ýڵ�û���ӽ��
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
//���node->flag��ֵΪ0����ɾ���������еĽ��,����ɾ���������еĽ�㣬
//�������ܱ��ִ��µ�ƽ��
       if(! node->flag)
      {
//            printf(" 000  ");
            tmp=find_prev(node);
//�����ɾ���Ľ�㲻�Ǹ����
//����������һ���жϺ���Ҫ��ע��!
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
      else   //��������������Ѱ��Ŀ����
     {
//           printf(" UUU ");
           tmp=find_next(node);
           parent=node->parent;
           if(tmp!=node->rchild)
          {
                child=tmp->rchild;//ע�⣬��һ����tmp�������������
                tmp->parent->lchild=child;
                if(child)
                   child->parent=tmp->parent;
//��ʼ����ָ���ع�
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
//ɾ���������������ͬ��Ԫ�ؽ��,���ɹ�����1�����򷵻�0
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
//�������Ҳ��ɹ�����ֱ�ӷ���
      if(! r)
          return 0;
//���Ŀ����ֻ��һ���ӽ��
      if(!node->lchild || !node->rchild)
     {
//             printf(" & ");
             remove_with_single(info,node);
//             printf("& \n");
      }
//����Ŀ�����������ӽڵ�
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

      printf("\n��ʼ��������������...\n");
      CreateTree(&info,data,16);
      node=info.root;

      while(node->lchild)
          node=node->lchild;
      printf("�����Ժ�̵ķ�ʽ���������������Ľ��...\n");

      while(node)
     {
           printf("  %d  ",node->data);
           node=find_next(node);
      }
      printf("\n");
      node=info.root;
  
      while(node->rchild)
           node=node->rchild;

      printf("������ǰ���ķ�ʽ���������������еĽ��...\n");
      while(node)
     {
           printf("  %d  ",node->data);
           node=find_prev(node);
      }
      printf("\n");
      printf("���ڿ�ʼɾ�����Ԫ��!\n");
      for(i=0;i<16;++i)
     {
          printf("��ʼɾ��Ԫ��%d \n",data[i]);
          remove_node(&info,data[i]);
      }
      return  0;
  }
      

      