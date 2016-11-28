//2012/11/8/19:05
//�������������ز���
//*���������������������С�������ѵĿ��ٺϲ��������Լ�֧�ֵ��������ȼ�����
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
/************************************************/
//�����������������ݽṹ,�������������С�����
  typedef  struct  _LTree
 {
//������
       int  key;
//��¼�Ըý��Ϊ������������б��
       int  shortest;
//����
       struct  _LTree  *lchild;
       struct  _LTree  *rchild;
  }LTree;
//����洢������ĸ�����������ݽṹ
  typedef  struct  _LTreeInfo
 {
       struct  _LTree  *root;
       int     length;
  }LTreeInfo;
//���������ز���
  void  insertNode(LTreeInfo *,int );
//ɾ����Сֵ���
  int   removeRoot(LTreeInfo *,int *);
//��������������������кϲ�
  void  union2LTree(LTreeInfo  *,LTreeInfo *);
//����һ�������
  void  CreateLTree(int *,int,LTreeInfo *);
/*************************************************************/
  void  CreateLTree(int *input,int len,LTreeInfo *info)
 {
        int        i;
        for(i=0;i<len;++i)
            insertNode(info,*input++);
  }
//ɾ�������
  int  removeRoot(LTreeInfo *info,int *min)
 {
       LTree  *tmp=NULL;
       LTreeInfo  binfo;

       if(info->root)
      {
            tmp=info->root;
            printf("%x\n",tmp);
            *min=tmp->key;
            --info->length;
            if(! tmp->lchild)
                info->root=NULL;
            else if(tmp->rchild)
           {
                printf("***\n");
                info->root=tmp->lchild;
                binfo.root=tmp->rchild;
                binfo.length=0;
//                printf("^^a->key:%x,b->key:%x^^\n",tmp->lchild,tmp->rchild);
                union2LTree(info,&binfo);
            }
            else  
                info->root=tmp->lchild;
            free(tmp);
//ע�������һ�������ͷ����ڴ�֮��tmp->lchild,/rchild�е�ֵ���ᱻ�ı䣬��ϸ������
//�����ǣ����ͷŵ��ڴ治Ҫ��������
//            printf("###%x,###%x \n",tmp->lchild,tmp->rchild);
            return 1;
       }
      return 0;
  }
//�ϲ�������С������������д��ainfo����Ӧָ�����У����Һϲ�����ȻΪһ���������
  void  union2LTree(LTreeInfo *ainfo,LTreeInfo *binfo)
 {
      LTree  *a,*b,*tmp;
//      LTree  *p,*q;
//�������һ�㲻�ᳬ��32,
      LTree  *queue[32];
      int    len=0;
//aʼ�մ�����С�����ĸ���㣬bΪ�ϴ������ĸ����     
      a=ainfo->root;
      b=binfo->root;
//���a>b���ͽ����������
//      printf("^^a->key:%x,b->key:%x^^\n",a,b);
      if(a->key>b->key)
     {
          tmp=a;
          a=b;
          b=tmp;
      }
//һ�¿�ʼ������Ϣ��ͳ��
     while( a )
    {
          if(a->key>b->key)
         {
              tmp=a;
              a=b;
              b=tmp;
          }
          queue[len++]=a;
          a=a->rchild;
     }
//ѭ��֮��b������������յ���a�����Ҷ˵������ĸ����
//�������ĩ�˵��������ָ��

     while(--len>=0)
    {
          a=queue[len];
          if(! a->lchild)
               a->lchild=b;
          else if(a->lchild->shortest<b->shortest)
         {
               a->rchild=a->lchild;
               a->lchild=b;
          }
          else
         {
               a->rchild=b;
               a->shortest=b->shortest+1;
          }
          b=a;
     }
     ainfo->root=a;
     ainfo->length+=binfo->length;
     binfo->root=NULL;
     binfo->length=0;
  }
//�����в���һ��Ԫ��
  void  insertNode(LTreeInfo *info,int key)
 {
      LTreeInfo  tmp;
      LTree      *a;

	  a=(LTree *)malloc(sizeof(LTree));
      a->lchild=NULL;
      a->rchild=NULL;
      a->key=key;
      a->shortest=0;

      ++info->length;
      if(! info->root)
          info->root=a;
      else
     {
          tmp.length=0;
          tmp.root=a;
          union2LTree(info,&tmp);
      }
  }
//���Գ������
  int  main(int argc,char *argv[])
 {
      LTreeInfo  ainfo,binfo;
      int        akey[6]={2,7,13,80,50,11}; 
      int        bkey[8]={20,18,5,9,8,12,10,15};
      int        len1=6,len2=8;
      int        i=0,j=0;
       
//      j=time(NULL);
//      srand(0x137FD);
      printf("akey�����е�ֵ:\n");
      for(i=0;i<len1;++i)
            printf("  %d  ",akey[i]);
      printf("\n");
      printf("����bkey�е�ֵ:\n");
      for(i=0;i<len2;++i)
            printf("  %d  ",bkey[i]);
      printf("\n");

      ainfo.root=NULL;
      binfo.root=NULL;
      ainfo.length=0;
      binfo.length=0;

      printf("��ʼΪakey���������������\n");
      CreateLTree(akey,len1,&ainfo);

      printf("��ʼΪbkey���������...\n");
      CreateLTree(bkey,len2,&binfo);

      printf("��ʼ������������ϲ�...\n");
      union2LTree(&ainfo,&binfo);
      printf("��ʼ����ؽ�Ԫ��ɾ��...\n");
      i=1;
      while(ainfo.root)
     {
          removeRoot(&ainfo,&j);
          printf("��%d��Ԫ���� %d \n",i++,j);
      }
      return 0;
  }

          