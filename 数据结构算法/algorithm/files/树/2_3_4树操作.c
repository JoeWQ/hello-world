//2012/12/1/9:31
//2,3,4���Ĳ���
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define  M_INT    0x80000000
/*************************************************************/
//234���Ĳ�����23���Ĳ��������ƣ�������Զ��ԣ�����23���Ĳ���Ҫ��һЩ
  typedef  struct  _Tree234
 {
//����е�������
      int  ldata;
      int  mdata;
      int  rdata;
//ָ����
      struct  _Tree234   *lchild;  //������
      struct  _Tree234   *lmchild;//��������
      struct  _Tree234   *mrchild;//��������
      struct  _Tree234   *rchild;//������
  }Tree234;
  typedef  struct  _Tree234Info
 {
//ָ��234���ĸ�����ָ��
      struct  _Tree234   *root;
//��¼234���Ľ�����Ŀ
      int                nlen;
//��¼234�������������Ŀ
      int                dlen;
  }Tree234Info;
/***********************************************************/
   #include"234visit.c"
/************************************************************/
//234���Ĳ��Ҳ���
  Tree234  *search234(Tree234Info *,int);
/********************************************************/
//�Ͳ��������صĺ�������
  int  insert234(Tree234Info *,int );
//�����r(p�ĸ��ڵ�)��һ��2���ʱ���еķ��Ѳ���
  static  void  split2(Tree234 *r,Tree234 *p);
//�����r��һ��3���ʱ���еķ��Ҳ���
  static  void  split3(Tree234 *,Tree234 *);
//�����p�Ǹ����ʱ���еķ��Ѳ�������ʱ��Ҫ����info->root������
  static  void  split4(Tree234Info *info);
//��������ӵ������
  static  void  put_in(Tree234 *,int);
/**************************************************************************/
//��ɾ����صĺ�������
  static  void   union_root(Tree234 *);
  static  void   union2(Tree234 *,Tree234 *,Tree234 *);
  static  void   union3(Tree234 *,Tree234 *,Tree234 *);
  static  void   union4(Tree234 *,Tree234 *,Tree234 *);
//�ƹ��ܵĵ��Ȳ���
  static  void   union234(Tree234 *,Tree234 *,Tree234 *);
//�滻���Ժ���
  static  void   replace234(Tree234Info *,Tree234 *,int);
  int     remove234(Tree234Info *,int);
/***********************************************************************/
//���ҳɹ����򷵻�1�����򷵻�0
  Tree234  *search234(Tree234Info  *info,int data)
 {
        Tree234  *node=info->root;
        
        while( node )
       {
             if(node->ldata==data || node->mdata==data || node->rdata==data)
                     break;
             else if(data<node->ldata)
                    node=node->lchild;
             else if(node->mdata==M_INT  || data<node->mdata)
                    node=node->lmchild;
             else if(node->rdata==M_INT  || data<node->rdata)
                    node=node->mrchild;
             else
                    node=node->rchild;
        }
        return  node;
  }
//����2���
  static  void  split2(Tree234 *r,Tree234 *p)
 {
//���p��r��������
        Tree234 *tmp=(Tree234 *)malloc(sizeof(Tree234));
        tmp->rchild=NULL;
        tmp->mrchild=NULL;
        tmp->rdata=M_INT;
        tmp->mdata=M_INT;

        if(p==r->lchild)
       {
              printf("  *21*  ");
              r->mdata=r->ldata;
              r->ldata=p->mdata;
              tmp->ldata=p->rdata;
              p->mdata=M_INT;
              p->rdata=M_INT;

              r->mrchild=r->lmchild;
              r->lmchild=tmp;
              tmp->lchild=p->mrchild;
              tmp->lmchild=p->rchild;
              p->mrchild=NULL;
              p->rchild=NULL;
        }
        else// if(p==r->lmchild)
       {
              printf(" *22* ");
              r->mdata=p->mdata;
              p->mdata=M_INT;
              tmp->ldata=p->rdata;
              p->rdata=M_INT;
         
              tmp->lchild=p->mrchild;
              tmp->lmchild=p->rchild;
              r->mrchild=tmp;
              p->rchild=NULL;
              p->mrchild=NULL;
        }
        printf(" $222$  ");
  }
//����3���
  static  void  split3(Tree234 *r,Tree234 *p)
 {
//���p��r��������
        Tree234 *tmp=(Tree234 *)malloc(sizeof(Tree234));
        tmp->rchild=NULL;
        tmp->mrchild=NULL;
        tmp->rdata=M_INT;
        tmp->mdata=M_INT;
        
        if(p==r->lchild)
       {
             printf("  #31#  ");
             r->rdata=r->mdata;
             r->mdata=r->ldata;
             r->ldata=p->mdata;
             tmp->ldata=p->rdata;
             p->mdata=M_INT;
             p->rdata=M_INT;
             
             r->rchild=r->mrchild;
             r->mrchild=r->lmchild;
             r->lmchild=tmp;
             tmp->lchild=p->mrchild;
             tmp->lmchild=p->rchild;
             p->mrchild=NULL;
             p->rchild=NULL;
        }
        else if(p==r->lmchild)//�������������
       {
             printf("  #32#  ");
             r->rdata=r->mdata;
             r->mdata=p->mdata;
             p->mdata=M_INT;
             tmp->ldata=p->rdata;
             p->rdata=M_INT;
             
             r->rchild=r->mrchild;
             r->mrchild=tmp;
             tmp->lchild=p->mrchild;
             tmp->lmchild=p->rchild;
             p->mrchild=NULL;
             p->rchild=NULL;
        }
        else //�������������
       {
             tmp->ldata=p->rdata;
             tmp->lchild=p->mrchild;
             tmp->lmchild=p->rchild;
 
             r->rdata=p->mdata;
             r->rchild=tmp;
             p->rdata=M_INT;
             p->mdata=M_INT;
             p->rchild=NULL;
             p->mrchild=NULL;
        }
        printf("  $333$  ");
//ʣ�µ�һ���������Ŷ���ǵĶ�������ݽṹ�����в�����֣�����ʡ��
  }
//����4��㣬�������ֻ�ܷ����ڸ������
  static  void  split4(Tree234Info *info)
 {
       Tree234  *q=(Tree234 *)malloc(sizeof(Tree234));
       Tree234  *r=(Tree234 *)malloc(sizeof(Tree234));
       Tree234  *p=info->root;
//�����������������в��ָ��£�ʣ�µĲ���ΪҪ�õ���
       r->rdata=M_INT;
       r->mdata=M_INT;
       r->rchild=NULL;
       r->mrchild=NULL;

       q->rdata=M_INT;
       q->mdata=M_INT;
       q->rchild=NULL;
       q->mrchild=NULL;

       r->ldata=p->mdata;
       q->ldata=p->rdata;
       p->mdata=M_INT;
       p->rdata=M_INT;
//����ָ����
       r->lchild=p;
       r->lmchild=q;
       q->lchild=p->mrchild;
       q->lmchild=p->rchild;
       p->mrchild=NULL;
       p->rchild=NULL;
       info->root=r;
       printf(" #444#  ");
  }
       

//����ɹ����򷵻�1�����򷵻�0
  int  insert234(Tree234Info  *info,int data)
 {
       Tree234  *p,*q,*r;
       int      flag=0;
//�ȴӸ��ڵ��ж�
       if(! info->root)
      {
             p=(Tree234 *)malloc(sizeof(Tree234));
             p->ldata=data;
             p->mdata=M_INT;
             p->rdata=M_INT;
             p->lchild=NULL;
             p->lmchild=NULL;
             p->mrchild=NULL;
             p->rchild=NULL;
             info->root=p;
             info->nlen=1;
             info->dlen=1;
             return 1;
       }
//��ʼ����ѭ����ǰϦ
       if(info->root->rdata!=M_INT) //������������һ��4��㣬��ֱ�ӷ���
      {
             split4(info);
             info->nlen+=2;
       }
//��ʼ����ѭ��
       r=NULL;
       q=NULL;
       p=info->root;
       while( p )
      {
            if(p->rdata!=M_INT)//���p��4���,����з��Ѳ���
           {
                 if(r->mdata!=M_INT)//�����yige 3���
                      split3(r,p);
                 else
                      split2(r,p);
                 ++info->nlen;
                 if(p!=r->lchild && p!=r->lmchild &&p!=r->mrchild)
                         printf("  @@@  ");
                 p=r;
            }
            r=p;
            q=p;
//��234���ķ�֧���в���
            if(p->ldata==data || p->mdata==data || p->rdata==data)
           {
                  flag=1;
                  break;
            }
            else if(data<p->ldata)
                  p=p->lchild;
            else if(p->mdata==M_INT || data<p->mdata)
                  p=p->lmchild;
            else if(p->rdata==M_INT || data<p->rdata)
                  p=p->mrchild;
            else
                  p=p->rchild;
       }
//�������ʧ�ܣ���ֱ�ӽ���������ӽ����q��
      if(! flag )
     {
           ++info->dlen;
           put_in(q,data);
      }
      return !flag;
  }
//������ݵ�Ҷ�����
  static  void  put_in(Tree234 *q,int data)
 {
        if(data<q->ldata)
       {
             q->rdata=q->mdata;
             q->mdata=q->ldata;
             q->ldata=data;
        }
        else if(q->mdata==M_INT || data<q->mdata)
       {
             q->rdata=q->mdata;
             q->mdata=data;
       }
       else
             q->rdata=data;
  }
/*************************ɾ������**********************************/
//�ϲ�2��������������������ձ���,�����Ѿ�����pΪһ��2���
  static  void  union2(Tree234 *r,Tree234 *p,Tree234 *q)
 {
//�����Ѿ�����qΪһ��2���ʱ,��ֱ�Ӱ�rΪ4�ڵ�ķ�ʽ�ϲ����
         if(p==r->lchild)
        {
               p->mdata=r->ldata;
               p->rdata=q->ldata;
               r->ldata=r->mdata;
               r->mdata=r->rdata;
               r->rdata=M_INT;
                     
               p->mrchild=q->lchild;
               p->rchild=q->lmchild;
               r->lmchild=r->mrchild;
               r->mrchild=r->rchild;
               r->rchild=NULL;
               free(q);
          }
          else if(p==r->lmchild)//���pΪr����������
         {
               q->mdata=r->ldata;
               q->rdata=p->ldata;
               r->ldata=r->mdata;
               r->mdata=r->rdata;
               r->rdata=M_INT;
                     
               q->mrchild=p->lchild;
               q->rchild=p->lmchild;
               r->lmchild=r->mrchild;
               r->mrchild=r->rchild;
               r->rchild=NULL;
               free(p);
          }
          else if(p==r->mrchild)//���pΪr����������
         {
               q->mdata=r->mdata;
               q->rdata=p->ldata;
               r->mdata=r->rdata;
               r->rdata=M_INT;
       
               q->mrchild=p->lchild;
               q->rchild=p->lmchild;
               r->mrchild=r->rchild;
               r->rchild=NULL;
               free(p);
          }
          else if(p==r->rchild)
         {
               q->mdata=r->rdata;
               q->rdata=p->ldata;
               r->rdata=M_INT;
               q->mrchild=p->lchild;
               q->rchild=p->lmchild;
               r->rchild=NULL;
               free(p);
         }
  }
//�ϲ�3��㣬��ν��3��㣬��ָq�Ľ����Ŀ
  static  void  union3(Tree234 *r,Tree234 *p,Tree234 *q)
 {
          if(p==r->lchild)
         {
               p->mdata=r->ldata;
               r->ldata=q->ldata;
               q->ldata=q->mdata;
               q->mdata=M_INT;

               p->mrchild=q->lchild;
               q->lchild=q->lmchild;
               q->lmchild=q->mrchild;
               q->mrchild=NULL;
          }
          else if(p==r->lmchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->ldata;
               r->ldata=q->mdata;
               q->mdata=M_INT;
//�޸�ָ����               
               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->mrchild;
               q->mrchild=NULL;
          }
          else if(p==r->mrchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->mdata;
               r->mdata=q->mdata;
               q->mdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->mrchild;
               q->mrchild=NULL;
          }
          else if(p==r->rchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->rdata;
               r->rdata=q->mdata;
               q->mdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->mrchild;
               q->mrchild=NULL;
          }
  }
//�ϲ�4��㣬4��㼴q��㺬��3��������
  static  void  union4(Tree234 *r,Tree234 *p,Tree234 *q)
 {
          if(p==r->lchild)
         {
//���������ƶ�
               p->mdata=r->ldata;
               r->ldata=q->ldata;
               q->ldata=q->mdata;
               q->mdata=q->rdata;
               q->rdata=M_INT;

//ָ�����ƶ�
               p->mrchild=q->lchild;
               q->lchild=q->lmchild;
               q->lmchild=q->mrchild;
               q->mrchild=q->rchild;
               q->rchild=NULL;
          }
          else if(p==r->lmchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->ldata;
               r->ldata=q->rdata;
               q->rdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->rchild;
               q->rchild=NULL;
          }
          else if(p==r->mrchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->mdata;
               r->mdata=q->rdata;
               q->rdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->rchild;
               q->rchild=NULL;
          }
          else if(p==r->rchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->rdata;
               r->rdata=q->rdata;
               q->rdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->rchild;
               q->rchild=NULL;
          }
  }
//�ܵ��Ⱥ���
  static  void  union234(Tree234 *r,Tree234 *p,Tree234 *q)
 {
//����q����������ò�ͬ�ĺ���
          if(q->mdata==M_INT)
               union2(r,p,q);
          else if(q->rdata==M_INT)
               union3(r,p,q);
          else
               union4(r,p,q);
  }
//ɾ���������Ľӿں���
  int  remove234(Tree234Info *info,int data)
 {
        Tree234  *r,*p,*q;
        int      flag=0;

        if(! info->root)
       {
             printf("ɾ������,���Ѿ�Ϊ��!\n");
             return 0;
        }
        p=NULL;
        q=NULL;
//�Ƚ��и��ڵ㴦��
        if(info->root->mdata==M_INT)
              union_root(info->root);
        r=info->root;
//����ѭ������
        while( r )
       {
               if(data==r->ldata || data==r->mdata || data==r->rdata)
              {
                      p=NULL;
                      flag=1;
               }
               else if(data<r->ldata)
              {
                      p=r->lchild;
                      q=r->lmchild;
               }
               else if(r->mdata==M_INT || data<r->mdata)
              {
                      p=r->lmchild;
                      q=r->lchild;
               }
               else if(r->rdata==M_INT || data<r->rdata)
              {
                      p=r->mrchild;
                      q=r->lmchild;
               }
               else
              {       p=r->rchild;
                      q=r->mrchild;
               }
               if(! p)
                   break;
//����Ѿ����ҵ�Ŀ���㣬��ı�ִ�в���
               if( flag)
              {
                      replace234(info,r,data);
                      break;
               }
//����p�Ƿ���һ��2��㣬���ݲ�ͬ���������r��ֵ
               if(p->mdata!=M_INT)
                      r=p;
               else//����������£�����Ҫ�����²������ݽ�
                      union234(r,p,q);
       }
       return flag;
  }
/********************************************************************/
//�滻���ĺ�������
  static  void  replace234(Tree234Info  *info,Tree234 *r,int data)
 {
        Tree234  *p,*q,*tmp=r;
        int      *value=NULL;
//���ȴ�������������
        if(r==info->root &&  !r->lchild)//���ֻ��һ�����
       {
              if(data==r->ldata && r->mdata==M_INT)
             {
                   info->root=NULL;
                   free(r);
                   return ;
              }
        }
        if(! r->lchild)//���r�Ѿ�ΪҶ���
       {
              if(data==r->ldata)
             {
                    r->ldata=r->mdata;
                    r->mdata=r->rdata;
              }
              else if(data==r->mdata)
                    r->mdata=r->rdata;
              r->rdata=M_INT;
              return;
        }
//��ʼ����ϲ���&���Ҳ���
        q=NULL;
        q=NULL;
        while( r)//ѭ������������Ҷ���
       {
              if(r->rdata!=M_INT)
             {
                    p=r->rchild;
                    q=r->mrchild;
              }
              else if(r->mdata!=M_INT)
             {
                    p=r->mrchild;
                    q=r->lmchild;
              }
              else
             {
                    p=r->lmchild;
                    q=r->lchild;
              }
              if(! p)
                   break;
//�ϲ�������
              if(p->mdata!=M_INT)
                    r=p;
              else
                    union234(r,p,q);
         }
         p=r;
         r=tmp;
//�滻������
         if(data==r->ldata)
               value=&r->ldata;
         else if(data==r->mdata)
               value=&r->mdata;
         else
               value=&r->rdata;
         if(p->rdata!=M_INT)
        {
               *value=p->rdata;
               p->rdata=M_INT;
         }
         else if(p->mdata!=M_INT)
        {
               *value=p->mdata;
               p->mdata=M_INT;
         }
//û����һ�����
  }
//�ϲ��������,�������ʽר��Ϊ���ڵ���Ƶģ������ı�r�� ֵ�����Բ��ô���Tree234Info���͵�ָ��
  static  void  union_root(Tree234 *r)
 {
         Tree234 *p,*q;
         
         if(! r->lchild || r->mdata!=M_INT)//���ֻ��һ�������߸��ڵ��Ѿ���3��4��㣬��ֱ���˳�
              return;
         p=r->lchild;
         q=r->lmchild;

         if(p->mdata!=M_INT || q->mdata!=M_INT)
                return ;
//�ϲ�������ʵ��
         r->mdata=r->ldata;
         r->rdata=q->ldata;
         r->ldata=p->ldata;
         r->lchild=p->lchild;
         r->lmchild=p->lmchild;
         r->mrchild=q->lchild;
         r->rchild=q->lmchild;

         free(p);
         free(q);
  }
         
/***********************************************************/
  int  main(int argc,char *argv[])
 {
       int  vbuf[128];
       int  len=128;
       int  i,seed;
       Tree234Info  info;

       seed=(int)time(NULL);
       srand(seed);
       info.nlen=0;
       info.dlen=0;
       info.root=NULL;
       
       printf("�������������:\n");
       for(i=0;i<len;++i)
      {
            vbuf[i]=rand();
            printf("  %d  ",vbuf[i]);
            if(!(i & 0x7))
                 printf("\n");
       }
       printf("���ڿ�ʼִ�в������:\n");
       for(i=0;i<len;++i)
      {
            if(insert234(&info,vbuf[i]))
                 printf("%d��������ɹ�!\n",vbuf[i]);
            else
                 printf("%d�������ʧ��!\n",vbuf[i]);
//            dvisit234(&info);
//            printf("********************************************\n");
       }

       printf("******************************************************\n");
/*
       printf("���ڿ�ʼִ�в��Ҳ���:\n");
       for(i=0;i<len;++i)
      {
            if(search234(&info,vbuf[i]))
                 printf("%d���ҳɹ�!\n",vbuf[i]);
            else
                 printf("%d����ʧ��!\n",vbuf[i]);
      }
*/
      printf("���ڿ�ʼִ��ɾ������:\n");
      for(i=0;i<len;++i)
     {
            if(remove234(&info,vbuf[i]))
                 printf("%dɾ���ɹ�!\n",vbuf[i]);
            else
                 printf("%dɾ��ʧ��!\n",vbuf[i]);
      }
      return 0;
  }