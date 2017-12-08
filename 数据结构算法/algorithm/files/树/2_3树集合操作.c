//2012/11/28/9:14
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define  M_INT    0x80000000
/**************************************************/
//����23���ṹ
  typedef  struct  _Tree23
 {
//��������
      int  ldata;
//��������
      int  rdata;
//����ָ����
      struct  _Tree23   *lchild;
      struct  _Tree23   *mchild;
      struct  _Tree23   *rchild;
  }Tree23;

  typedef  struct  _Tree23Info
 {
//��¼23���ĸ��ڵ�
      struct  _Tree23   *root;
//��¼����23���Ľ����Ŀ
      int               len;
  }Tree23Info;
//**********************************************************
  #include"23visit.c"
//**************************************************
//���ɹ��򷵻�ָ��ý���ָ��,���򷵻�NULL
  Tree23  *search23(Tree23Info *,int );
//*****************************************************
//����������صĺ�������
//��������������Ѿ������򷵻�0�����򷵻������ʵ�ʳ���
//�����ĺ������ĸ���㣬��Ž��Ļ�����,Ŀ������,ָ��������ʵ�ʳ��ȵ�ָ��,����ɹ�������1�����򷵻�0

  static  int  find_23_node(Tree23Info *,Tree23 **,int);
//��ֽ�����
  static  void  split_23_node(Tree23 *,Tree23 **,int *);
  int     insert23(Tree23Info *,int data);
/*****************************************************************/
//23����ɾ������
  int  remove23(Tree23Info  *,int );
//ɾ��������Ҫ�õ��ļ����������
//;��ת����
  static  void  rotate23(Tree23 *,Tree23 *,Tree23 *);
//�ϲ�����
  static  void  union23(Tree23 *,Tree23 *,Tree23 *);
//��Ų���
  static  void  put_int(Tree23 *,Tree23 *,int);
  
//*******************************************************************
  Tree23  *search23(Tree23Info  *info,int data)
 {
       Tree23  *node;
       
       node=info->root;
       while(node)
      {
            if(node->ldata==data || data==node->rdata)
                 break;
            else if(data<node->ldata)
                 node=node->lchild;
            else if(node->rdata==M_INT || data<node->rdata)
                 node=node->mchild;
            else
                 node=node->rchild;
       }
       return node;
  }
//���������
  int  insert23(Tree23Info  *info,int data)
 {
       Tree23  *p,*q,*tmp,*child=NULL;
       Tree23  *vbuf[32];
       int   len=0,i=0;
//�����Ϊ��
       if( !info->root)
      {
            tmp=(Tree23 *)malloc(sizeof(Tree23));
            tmp->ldata=data;
            tmp->rdata=M_INT;
            tmp->lchild=NULL;
            tmp->mchild=NULL;
            tmp->rchild=NULL;
            info->root=tmp;
            info->len=1;
            return 1;
       }
       len=find_23_node(info,vbuf,data); 

//�����������0�����ʾĿ�����Ѿ����ڣ�����ʧ��
       if( ! len)
      {
            printf("�����Ľ��%d�Ѿ����ڣ��˴β������ʧ��!\n",data);
            return 0;
       }
       q=NULL;
       ++info->len;
       while(--len>=0)
      {
            p=vbuf[len];
//�����2��㣬��ֱ�Ӳ���
            if(p->rdata==M_INT)
           {
//���Ĵ洢�����ǣ�ldata<rdata,������һ�����ж��Ǳ����
                 if(p->ldata>data)
                { 
                      p->rdata=p->ldata;
                      p->rchild=p->mchild;
                      p->mchild=q;
                      p->ldata=data; 
                 }
                 else
                {
                      p->rdata=data;
                      p->rchild=q;
                 }
                 return 1;
            }
//�����3��㣬���Ƚ��в�ֲ���
            else
           {
                 split_23_node(p,&q,&data);
//����Ѿ������˸����,�������װ����ֱ���˳�ѭ��
                 if(p==info->root)
                {
                      tmp=(Tree23 *)malloc(sizeof(Tree23));
                      tmp->ldata=data;
                      tmp->rdata=M_INT;
                      tmp->lchild=p;
                      tmp->mchild=q;
                      tmp->rchild=NULL;
                      info->root=tmp;
                      return 1;
                 }
            }
       }
       return 1;
  }
//*************************************************************************
  static int  find_23_node(Tree23Info *info,Tree23 **vbuf,int data)
 {
       int  len=0;
       Tree23 *node=info->root;
       
       while(node)
      {
             vbuf[len++]=node;
             if(data==node->ldata || data==node->rdata)
            {
                  len=0;
                  break;
             }
             else if(data<node->ldata)
                  node=node->lchild;
             else if(node->rdata==M_INT || data<node->rdata)
                  node=node->mchild;
             else
                  node=node->rchild;
       }
       return len;
  }
//*****************************************************************************
  static  void  split_23_node(Tree23 *p,Tree23 **q,int *data)
 {
       Tree23  *tmp,*child=NULL,*a=NULL;
       int     mid=0,max=0;
//���ǵ�����ָ��ĵ�Ч������ֱ��ʹ��һ��ָ��
//����Сֵд����p�У���ѡ���м�ֵ
       if(p->ldata>*data)
      {
           mid=p->ldata;
           p->ldata=*data;
           max=p->rdata;
       }
       else
      {
           if(p->rdata<*data)
          {
               mid=p->rdata;
               max=*data;
           }
           else
          {
               mid=*data;
               max=p->rdata;
           }
       }
       p->rdata=M_INT;
       tmp=(Tree23 *)malloc(sizeof(Tree23));
       tmp->ldata=max;
       tmp->rdata=M_INT;
       tmp->mchild=NULL;
       tmp->rchild=NULL;
       tmp->lchild=NULL;
       *data=mid;

//       printf("��%d,��%d,С%d",max,mid,p->ldata);
       if(! *q)
            *q=tmp;
       else
      {
//ע�⣬��һ�������ǳ���Ҫ�����ȱ����������info->len����ֵ�ǳ����ʱ�򣬾ͻ���ַǳ����Բ���Ĵ���
           if(p->mchild->ldata>(*q)->ldata)//�������������������򽻻�����
          {
                 a=p->mchild;
                 p->mchild=*q;
                 *q=a;
           }
           child=p->rchild;
           p->rchild=NULL;
           if(max<(*q)->ldata)
          {
                tmp->lchild=child;
                tmp->mchild=*q;
//                printf(" 1:��%d:��%d:��%d",child->ldata,max,(*q)->ldata);
           }
           else
          {
                tmp->lchild=*q;
                tmp->mchild=child;
//                printf(" 2:��%d:��%d:��:%d",(*q)->ldata,max,child->ldata);
           }
           *q=tmp;
       }
  }
//����0�����ʾ����ʧ�ܣ�������ҳɹ���������·�������������н��д��vbuf��
//index�з��ص��Ǳ����ҵ�Ŀ����vbuf�����ڵ����±�����
  static  int  modified_search23(Tree23Info *info,int data,Tree23 **vbuf,int *index)
 {
       Tree23  *node;
       int     len=0;
       int     flag=0;

       node=info->root;
       while(node)
      {
             vbuf[len++]=node;
//��û�в��ҵ�Ŀ������ʱ����һ�ֲ��ԣ��ڲ��ҵ����ٲ�����һ�ֲ���
             if(data==node->ldata || data==node->rdata)
            {
                  *index=len-1;//ע����һ������
                  flag=1;
                  if(data==node->ldata)//ѡȡ�������е����ֵ
                       node=node->lchild;
                  else
                       node=node->mchild;//ѡȡ�����������ֵ
                  while( node )
                 {
                       vbuf[len++]=node;
                       if(node->rdata==M_INT)
                             node=node->mchild;
                       else
                             node=node->rchild;
                  }
                  goto label;
              }
              else if(data<node->ldata)
                  node=node->lchild;
              else if(node->rdata==M_INT || data<node->rdata)
                  node=node->mchild;
              else
                  node=node->rchild;
       }
//�������û�гɹ���ֱ�ӷ���0�����򷵻������ʵ�ʳ���
     label:
       return flag? len:0;
  }
//�����p�е������ƶ���r��
  static  void  put_in(Tree23 *r,Tree23 *p,int data)
 {
       if(r==p)//���Ŀ�����Ѿ���Ҷ���
      {
             if(r->rdata==data)
                  r->rdata=M_INT;
             else
            {
                  r->ldata=r->rdata;
                  r->rdata=M_INT;
             }
       }
       else
      {
             if(r->ldata==data)
            {
                  if(p->rdata!=M_INT)//�жϽ��p�����������
                 {
                        r->ldata=p->rdata;
                        p->rdata=M_INT;
                  }
                  else
                 {
                        r->ldata=p->ldata;
                        p->ldata=M_INT;
                 }
            }
            else
           {
                  if(p->rdata!=M_INT)
                 {
                       r->rdata=p->rdata;
                       p->rdata=M_INT;
                  }
                  else
                 {
                      r->rdata=p->ldata;
                      p->ldata=M_INT;
                 }
           }
      }
  }
//ɾ������
  int  remove23(Tree23Info  *info,int data)
 {
       Tree23   *p,*q,*r;
       Tree23   *vbuf[32];
       int      len,index=0;

       if(! info->root)
      {
             printf("ɾ������2_3���Ѿ�Ϊ��!\n");
             return 0;
       }
       len=modified_search23(info,data,vbuf,&index);
//����ʧ�ܷ���0
       if(! len)
      {
             printf("���ź���������������%d������!\n",data);
             return 0;
       }
//Ѱ��һ��Ҷ��㣬��������һ���������滻�����p�е�Ŀ��������
       r=vbuf[index];
       p=vbuf[--len];
//ɾ�����r�е�������
       put_in(r,p,data);
//����ѭ������
       q=NULL;
       while(p->ldata==M_INT && p->rdata==M_INT && p!=info->root)
      {
              if(! len)//����Ѿ�������ڵ㣬��ֱ���˳�
                   break;
              r=vbuf[--len];//p�ĸ����
              if(p==r->lchild)
                   q=r->mchild;
              else if(p==r->mchild)
                   q=r->lchild;
              else
                   q=r->mchild;
//������q��һ������㣬�������ת������������кϲ�����
              if(q->rdata!=M_INT)
                   rotate23(r,p,q); 
              else
                   union23(r,p,q);
              p=r;
       }
//���p���������������pһ���Ǹ��ڵ�
       if(p->rdata==M_INT && p->ldata==M_INT)
      {
             info->root=p->lchild;
             free(p);
       }
    return 1;
  }
//��ת����,rΪp,q�ĸ��ڵ㣬��p,qΪ�ֵܽڵ�
  static  void  rotate23(Tree23  *r,Tree23 *p,Tree23 *q)
 {
//���pΪr��������,��ôqһ��Ϊr��������
       if(p==r->lchild)
      {
             p->ldata=r->ldata;
             r->ldata=q->ldata;
             q->ldata=q->rdata;
             q->rdata=M_INT;

             p->mchild=q->lchild;
             q->lchild=q->mchild;
             q->mchild=q->rchild;
             q->rchild=NULL;
       }
//���pΪr������������ôqΪr��������
       else if(p==r->mchild)
      {
             p->ldata=r->ldata;
             r->ldata=q->rdata;
             q->rdata=M_INT;
      
             p->mchild=p->lchild;
             p->lchild=q->rchild;
             q->rchild=NULL;
       }
       else if(p==r->rchild)
      {
             p->ldata=r->rdata;
             r->rdata=q->rdata;
             q->rdata=M_INT;
             
             p->mchild=p->lchild;
             p->lchild=q->rchild;
             q->rchild=NULL;
       }
  }
//�ϲ���������������ĸ�����ҩ�Ƚϸߣ���Ϊ��Ҫ���ֵ�����Ƚ϶�
  static  void  union23(Tree23 *r,Tree23 *p,Tree23 *q)
 {
       if(p==r->lchild)
      {
             if(r->rdata==M_INT)
            {
                  p->ldata=r->ldata;
                  p->rdata=q->ldata;
                  r->ldata=M_INT;
                  r->mchild=NULL;
                  p->mchild=q->lchild;
                  p->rchild=q->mchild;
             }
             else
            {
                  p->ldata=r->ldata;
                  p->rdata=q->ldata;
                  r->ldata=r->rdata;
                  r->rdata=M_INT;
                  p->mchild=q->lchild;
                  p->rchild=q->mchild;
                  r->mchild=r->rchild;
                  r->rchild=NULL;
             }
             free(q);
       }
       else if(p==r->mchild)
      {
             if(r->rdata==M_INT)
            {
                  q->rdata=r->ldata;
                  q->rchild=p->lchild;
                  r->ldata=M_INT;
                  r->mchild=NULL;
             }
             else
            {
                  q->rdata=r->ldata;
                  q->rchild=p->lchild;
                  r->ldata=r->rdata;
                  r->rdata=M_INT;
                  r->mchild=r->rchild;
                  r->rchild=NULL;
             }
             free(p);
       }
       else if(p==r->rchild)
      {
             q->rdata=r->rdata;
             r->rdata=M_INT;
             r->rchild=NULL;
             q->rchild=p->lchild;
             free(p);
       }
  }
/***********************************************************/
  int  main(int argc,char *argv[])
 {
      int  vbuf[64];//={40,20,10,80,70,30,60};
      int  len,seed,j=0,i;
      Tree23Info  info;

      seed=(int)time(NULL);
      srand(seed);
      info.len=0;
      info.root=NULL;
 
      len=64;
      seed=0;
      printf("���������Ϊ:\n");
      for(i=0;i<len;++i)
     {
          vbuf[i]=rand(); 
          printf(" %d  ",vbuf[i]);
          if(insert23(&info,vbuf[i]))
               printf("\n%d����ɹ�!\n",vbuf[i]);
          if(! (i & 0xF))
              printf("\n");
          //��������2,3��
//          dvisit23(&info);
//          printf("\n***********************************************************\n");
      }
/*******************************************************************/
      printf("*******************************��ʼִ�в��Ҳ���:********************************\n");
      for(i=0;i<len;++i)
     {
           if(search23(&info,vbuf[i]))
                printf("\n%d���ҳɹ�!\n",vbuf[i]);
           else
                printf("\n%d����ʧ��!\n",vbuf[i]);
      }
//��������2,3��
//      dvisit23(&info);
      printf("���濪ʼִ��ɾ������:\n");
      for(i=len-1;i>=0;--i)
     {
            if(remove23(&info,vbuf[i]))
                 printf("ɾ�����%d�ɹ�!\n",vbuf[i]);
            else
                 printf("ɾ�����%dʧ��!\n",vbuf[i]);
      }
      return 0;
  }