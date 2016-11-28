//��������ͺ������������������֮���Ӧ�Ķ�����
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
//***************************************
  typedef struct  _Tree
 {
     int  data;
//��¼�Ըýڵ���ԣ����������õ��ַ���,������dada����
     short  le;
//��¼�Ըýڵ���ԣ����������õ��ַ���
     short  re;
//��¼�Ըø��ڵ���ԣ����õ��ַ���
     int  len;
//��¼�����ʵĽڵ��е��ַ��������ַ���������Ӧ��λ��
     int  start;
     int  end;
     struct  _Tree  *parent;
     struct  _Tree  *lchild;
     struct  _Tree  *rchild;
  }Tree;
  Tree  *CreateTree(char *,char *);
  #ifndef  TREE_CONTAINED
    #include "m_tree.c"
  #endif
//����ڵ�ĳ�ʼ��
  void  init(Tree  *node)
 {
      node->data=0;
      node->le=0;
	  node->re=0;
      node->len=0; 
//start,end��¼����һ�����������и��ڵ������
      node->start=0;
      node->end=0;
      node->parent=NULL;
      node->lchild=NULL;
      node->rchild=NULL;
   }
//
//��������ͺ����ı������������֮���Ӧ�Ķ�����,ע������ĺ���û�н����ϸ�Ĳ������,����
//ֻҪ����ȷ�Ĳ������룬���ܲ�����֮��Ӧ����ȷ���
  Tree  *CreateTree(char *preorder,char  *inorder)
 {
//�����ַ����ĳ���
      int  inlen,prelen;
      int  data,i,k,count;
      Tree  *root=NULL,*tmp,*parent;

      inlen=strlen(inorder);
      prelen=strlen(preorder);
      if(!inlen || !prelen || inlen!=prelen)
     {
          printf("���������������ϸ��֤!\n");
          return  NULL;
      }
      root=(Tree  *)malloc(sizeof(Tree));
      init(root);
      data=preorder[0];
      root->data=data;
      for(i=0;i<inlen;++i)
     {
         if(inorder[i]==data)
            break;
      }
      root->start=0;
      root->end=i;
      root->le=i;
      root->re=inlen-i-1;
//��ʼ�������ڵ������
      parent=root;
//      printf("&&&&\n");
      printf("root:start:%d,end:%d,le:%d,re:%d,data:%c,end:%d\n",root->start,root->end,root->le,root->re,root->data,root->end);
      for(i=1;i<inlen;++i)
     {
          
          if(!parent->lchild && parent->le)
         {
              printf("111\n");
              tmp=(Tree *)malloc(sizeof(Tree));
              init(tmp);
              data=preorder[i];
              tmp->data=data;
              tmp->parent=parent;
              parent->lchild=tmp;
              tmp->start=i;
              for(count=parent->le,k=parent->end-parent->le;count;++k,--count)
                  if(inorder[k]==data)
                       break;
              tmp->end=k;
              tmp->le=parent->le-count;
              tmp->re=count-1;

printf("lchild:%x, rchild:%x,le:%d,re:%d ,data:%c,end:%d\n",tmp->lchild,tmp->lchild,tmp->le,tmp->re,tmp->data,tmp->end);
              if(tmp->le || tmp->re )
                 parent=tmp;
           }
           else if(!parent->rchild && parent->re)
          {
              printf("222\n");
              tmp=(Tree *)malloc(sizeof(Tree));
              init(tmp);
              tmp->parent=parent;
              parent->rchild=tmp;
              tmp->start=i;
              data=preorder[i];     
              tmp->data=data;
    //          tmp->end=parent->end;
              for(count=parent->re,k=parent->end+1;count;++k,--count)
                   if(preorder[k]==data)
                        break;
              tmp->end=k;
              tmp->le=parent->re-count;
              tmp->re=count-1;

printf("lchild:%x, rchild:%x,le:%d,re:%d ,data:%c,end:%d\n",tmp->lchild,tmp->lchild,tmp->le,tmp->re,tmp->data,tmp->end);
              if(tmp->le || tmp->re)
                 parent=tmp;
            }
            else
           {
              printf("&&&&\n");
               --i;
               parent=parent->parent;
            }
       }
    return  root;
  }
//�ͷŽڵ�
  void  free_node(Tree *node)
 {
      free(node);
  }
//��ӡ���
  void  print_node(Tree  *node)
 {
      printf("data:%4c , lchild:%8x ,rchild:%8x ,parent:%8x,addr:%8x\n",node->data,node->lchild,node->rchild,node->parent,node);
  }

  int main(int argc,char *argv[])
 {
      Tree  *root;
      char  *preorder="ABCDEFG";
      char  *inorder="CBEDAFG";
      callback=print_node;

	    printf("��ʼ����������!\n");
      root=CreateTree(preorder,inorder);
      printf("ǰ������������:\n");
      Preorder(root);
      printf("������������������������ʾ:\n");
      VisitTree(root);

      printf("�ͷŽڵ�:\n");
      callback=free_node;
      VisitTree(root);
      return 0;
  }             