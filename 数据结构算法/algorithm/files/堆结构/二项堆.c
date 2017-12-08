//2012/11/16/19:55
//����ѵ���ز���:���룬ɾ�����ϲ�����
//����ѵ�����Ҫ��;���ǿ��Խ�һ�������Ĵ��۷�̯����һ��������������Խ�ɾ������
//�Ĵ��۷�̯���������
/***************��������в������ǹ�����С����ѵ�******************/
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
/**********************************************/
  typedef  struct  _Beap
 {
//����������
       int  data;
//���Ķ�
       int  degree;
//���Ķ��ӽ��
       struct  _Beap   *child;
//�����������ֵܽ��
       struct  _Beap   *left;
       struct  _Beap   *right;
  }Beap;
//Ϊ�˷���Ѷ���ԵĲ���������ļ�¼����ѵ���ص���Ϣ�ṹ
  typedef  struct  _BeapInfo
 {
//��¼�͸���������ӵ��ֵܽ�����Ŀ
       int             len;
//��¼ָ�����ѵ���С������ָ��
       struct  _Beap   *root;
  }BeapInfo;
//Ϊ��ִ�кϲ�������ר����������ݽṹ
  typedef  struct  _Link
 {
       struct  _Beap  *root;
       struct  _Line  *next;
  };
  typedef  struct  _DegreeInfo
 {
       struct  _Link    *front;
       struct  _Link    *rear;
  }DegreeInfo;
/*********************************************************************/
  void  insert_item(BeapInfo  *,int );
//ɾ������ѵĸ���㣬���ɹ�����1�����򷵻�0
  int   remove_root(BeapInfo  *,int *);
//�ϲ����������
  void  union2beap(BeapInfo *,BeapInfo *);
  static  void  UnionBeap(BeapInfo *);
/**********************************************************************/
  void  insert_item(BeapInfo  *info,int data)
 {
       Beap  *tmp;
       Beap  *rear;

       tmp=(Beap *)malloc(sizeof(Beap));
       tmp->data=data;
       tmp->child=NULL;
       tmp->left=NULL;
       tmp->right=NULL;
       tmp->degree=0;
//��������Ϊ�գ���ֱ�Ӳ���
       ++info->len;
       if(! info->root)
      {
            info->root=tmp;
            tmp->left=tmp;
            tmp->right=tmp;
       }
       else
      {
//�Ƚϸ����Ĺؼ��ֵ�ֵ��С
            if(data<info->root->data)  //���������������С���Ѵ��ڵĶ���ѵĸ�����ֵ
           {
                  data=info->root->data;
                  info->root->data=tmp->data;
                  tmp->data=data;
            }
//���Ѿ������õĽ����뵽����ѵ���������
            rear=info->root->left;
            tmp->right=info->root;
            tmp->left=rear;
            rear->right=tmp;
            info->root->left=tmp;
//ʣ�µĹ����Ǻϲ��Ѿ����ڵ���
           UnionBeap(info);
      }
  }
//�ϲ����������
  void  union2beap(BeapInfo  *ainfo,BeapInfo *binfo)
 {
       Beap  *arear,*brear;

       arear=ainfo->root->left;
       brear=binfo->root->left;
       arear->right=brear;
       brear->left=arear;
       ainfo->root->left=binfo->root;
       binfo->root->right=ainfo->root;
//��������ѵ���С�����
       ainfo->len+=binfo->len;
       if(ainfo->root->data>binfo->root->data)
            ainfo->root=binfo->root;
       binfo->root=NULL;
       binfo->len=0;
  }
//ɾ�������
  int  remove_root(BeapInfo  *info,int  *min)
 {
      Beap  *tmp,*p;
      Beap  *left,*right;
      Beap  *child,*rear;

      if(! info->root)
     {
           printf("ɾ�������쳣�������Ķ�����Ѿ�Ϊ��\n");
           *min=0xFFFFFFFF;
           return 0;
      }
      *min=info->root->data;
//��������ֻ��һ�������
      --info->len;
      if(info->root==info->root->left)
     {
           child=info->root->child;
           free(info->root);
           if(! child)
          {
                info->root=NULL;
                return 1;
           }
           else
          {
//Ѱ����С���
                p=child->right;
                tmp=child;
                while(p!=child)
               {
                     if(p->data<tmp->data)
                         tmp=p;
                     p=p->right;
                }
                info->root=tmp;
                return 1;
           }
      }
//�������ѵĸ������Ŀ����1,���Ƚ���ɾ���Ķ���ѵĸ����Ķ��ӽڵ������������㴮������
      else
     {
           child=info->root->child;
           rear=child->left;
           right=info->root->right;
           left=info->root->left;
    
           left->right=child;
           child->left=left;
           rear->right=right;
           right->left=rear;
//��ʼѰ����С���
           tmp=left;
           p=left->right;
           while(p!=left)
          {
                if(p->data<tmp->data)
                     tmp=p;
                p=p->right;
           }
           free(info->root);
           info->root=tmp;
     }
//     printf("  &&&  ");
     UnionBeap(info);
     return 1;
  }
//���Ѿ�ɢ�ҵĶ�������ºϲ�
//�����Ѿ�ȷ�����Ǹ����Ķ���ѵĸ��������С��㣬��������������ѭ���е�����
  static void  UnionBeap(BeapInfo  *info)
 {
      int   j,len;
      Beap  *p,*q,*tmp;
      Link  *link;
      DegreeInfo   degree[36];
//����ڵ�Ķ�
      j=info->len;
      len=0;
      while(j)
     {
           ++len;
           j>>=1;
      }
      ++len;
//��ʼ����������info������ص���Ϣ
      for(j=0;j<=len;++j)  //�������
     {
           degree[j].front=NULL;
           degree[j].rear=NULL;
      }
      p=info->root;
      do
     {
           j=p->degree;
           link=(Link *)malloc(sizeof(Link));
           link->root=p;

           if(! degree[j].front)
               degree[j].front=link;
           else
               degree[j].rear->next=link;
           degree[j].rear=link;
           p=p->right;
      }while(p!=info->root);
//��һ������ʼ�Ծ�����ͬ�ȵĸ������кϲ�
//�ȴ�С������кϲ�������Ҳ�����˶��α�������Ĳ���
      for(j=0;j<=len;++j)
     {
           if(degree[j].front)
              union_degree(degree,j);
      }
//���½���ʣ�µĸ����������������(ÿ������Ԫ�����������Ľ��֮��Ϊ1��
      p=NULL;
      q=NULL;
      for(j=0;j<=len;++j)
     {
           if(degree[i].front)
          {
                tmp=degree[i].front->root;
                if(! p)
               {
                    p=tmp
                    q=p;
                }
                else
               {
                    p->right=tmp;
                    tmp->left=p;
                    p=tmp;
                }
                free(degree[i].front);
          }
      }
      p->right=q;
      q->left=p;
  }
//�ϲ�������ͬ�ȵĸ����
  static  void  union_degree(DegreeInfo  *degree,int j)
 {
      Link  *link,*stf,*stc,*front;
      Beap  *p,*q,*child;
      
      front=degree[j].front;
      link=front->next;
      while(front && link)
     {
            p=front->root;
            q=link->root;
            if(p->data>q->data)
           {
                  child=p;
                  p=q;
                  q=child;
            }
            child=p->child;
            if(! child)
           {
                  q->right=q;
                  q->left=q;
                  p->child=q;
            }
            else
           {
                  q->right=child;
                  q->left=child->left;
                  child->left->right=q;
                  child->left=q;
            }
//���ºϲ��Ľ����뵽��һ������Ԫ������ָ�������
            stf=(Link *)malloc(sizeof(Link));
            stf->next=NULL;
            stf->root=p;
            if(! degree[j+1].front)
                 degree[j+1].front=stf;
            else
                 degree[j+1].rear->next=stf;
            degree[j+1].rear=stf;
            stf=link;
            stc=front;
            front=link->next;
            link=NULL;
            if(front)
                link=front->next;
            free(stf);
            free(stc);
       }
       if(front)
      {
            degree[j].front=front;
            degree[j].rear=front;
       }
       else
      {
            degree[j].front=NULL;
            degree[j].rear=NULL;
       }
  }
/***********************************************************/
  int  main(int argc,char *argv[])
 {
       BeapInfo  ainfo,binfo;
	   Beap  *p;
       int   i,j,seed;
       int   test[14]={8,10,3,5,4,6,15,30,7,9,16,12,20,7};
       
       seed=time(NULL);
       ainfo.len=0;
       ainfo.root=NULL;
       ainfo.rear=NULL;
       binfo.len=0;
       binfo.root=NULL;
       binfo.rear=NULL;
       
       printf("�ɲ���ʽ����һ���µĶ����...\n");
       for(i=0;i<10;++i)
      {
           printf(" ^^^ \n");
           insert_item(&ainfo,test[i]);
       }
       printf("�ٴ��򴴽��Ķ��в����µ�Ԫ��(�Դ����ѵ���ʽ)...\n");
       for(i=10;i<14;++i)
      {
            binfo.len=1;
            p=(Beap *)malloc(sizeof(Beap));
            p->data=test[i];
            p->child=NULL;
            p->left=NULL;
            p->right=NULL;
            p->degree=0;
            binfo.root=p;
            binfo.rear=p;
            union2beap(&ainfo,&binfo);
       }
//
      printf("��ʼִ��ɾ������...\n");
      for(i=0;i<14;++i)
     {
            remove_root(&ainfo,&seed);
            printf("��%d��Ԫ����:%d \n",i,seed);
      }
      return 0;
  }