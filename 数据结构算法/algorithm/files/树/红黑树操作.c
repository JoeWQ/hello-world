//2012/12/3/15:50
//����һ�����ɹ��ĳ���
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
/******************************************************/
//������ɫ������ֵ�������ǵ����ݽṹ�����У�����ʹ��һ�����ε�ֵ��������ɫֵ(�����)
  #define  C_R    0x1  //��1�����ɫ��0�����ɫ
  #define  C_B    0x0

  typedef  struct  _Treerb
 {
//������ɫ���������ֶ��壬���������ǽ������Զ����µĲ������
//data
        int         data;
//�������ɫ
        short       lc;
//�ҽ�����ɫ
        short       rc;
//ָ����
        struct  _Treerb    *lchild;
        struct  _Treerb    *rchild;
  }Treerb;
//����װ����Ϣ�ṹ
  typedef  struct  _TreerbInfo
 {
//���������ĸ����
        struct  _Treerb  *root;
//��¼����Ĳ���
        int              rlayer;
//��¼�ڽ��Ĳ���
        int              blayer;
//��¼������Ľ����Ŀ
        int              nodes;
  }TreerbInfo;
  //********************************************************
    static  void  rotate_ll(Treerb *,Treerb *,Treerb *);
	static  void  rotate_lr(Treerb *,Treerb *,Treerb *);
	static  void  rotate_rl(Treerb *,Treerb *,Treerb *);
	static  void  rotate_rr(Treerb *,Treerb *,Treerb *);
/*********************************************************/
//ɾ������
/**********************************************************/
	static  find_next(Treerb *,Treerb **);
	int     removerb(TreerbInfo *,int);
/*******************************************************/
//���Ҳ���
  Treerb  *searchrb(TreerbInfo  *info,int data)
 {
        Treerb   *node=info->root;
        
        while( node )
       {
               if(data==node->data)
                    break;
               else if(data<node->data)
                    node=node->lchild;
               else
                    node=node->rchild;
        }
        return node;
  }
/************************************************************************/
  static  int  modify_colors(Treerb *p,Treerb *r)
 {
          int   flag=0;
//���rΪ�����
          if(! p) 
              flag=1;
//pΪ2���,�������һ�ֲ�ȷ���ԣ����������������ɾ���������ۣ�����
//�ų����ֲ�ȷ����
          else if( !p->lc &&  !p->rc)
         {
                flag=1;
                if(p->lchild==r)
                      p->lc=C_R;
                else
                      p->rc=C_R;
          }
//�����3���ĺ�ɫָ��ָ����
          else if(r==p->lchild && p->rc)
         {
                flag=1;
                p->lc=C_R;
          }
          else if(r==p->rchild && p->lc)
         {
                flag=1;
                p->rc=C_R;
          }
          return flag;
  }
//������Ĳ������(�Զ����µĲ���),�������Ҫ�漰�ܶ�Ķ��⺯������
  int  insertrb(TreerbInfo  *info,int data)
 {
       Treerb   *gp,*p,*r,*q;
       int      flag=0,modify=0;

       if(! info->root)
      {
             p=(Treerb *)malloc(sizeof(Treerb));
             p->data=data;
             p->lchild=NULL; 
             p->rchild=NULL;
//�ӽ��һ��Ⱦ�ɺ�ɫ
             p->lc=C_B;
             p->rc=C_B;
             info->root=p;
             return 1;
       }
//pΪr�ĸ���㣬gpΪr���游���
       gp=NULL,p=NULL,q=NULL;;
       r=info->root;
       
       while( r )
      {
             if(r->lchild && r->rchild && r->lc && r->rc)//�����һ��4��㣬������������в�ֲ���
            {
//�������ֵĽ���Ǹ���㣬������һ��2���Ķ��ӽ�㣬���߱�һ��3���ָ����ֻ��Ҫ�޸���ɫ����
                   r->lc=C_B;
                   r->rc=C_B;
                   modify=modify_colors(p,r);
////���������ͻ���������ת����
                   if(!modify && p && gp)
                  {
                        if(gp->lchild==p)
                       {
                              if(p->lchild==r) 
                                   rotate_ll(gp,p,r);
                              else
                             {
                                   rotate_lr(gp,p,r);
                                   p=r;
                              }
                        }
                        else
                       {
                              if(p->lchild==r)
                             {
                                   rotate_rl(gp,p,r);
                                   p=r;
                              }
                              else
                                   rotate_rr(gp,p,r);
                        }
                        if(gp==info->root)
                              info->root=p;
                        else
                       {
                             if(q->lchild==gp)
                                   q->lchild=p;
                             else
                                   q->rchild=p;
                        }
                        gp=p;
                        p=r;
                   }
                   else
                  {
                       q=gp;
                       gp=p; 
                       p=r;
                   }
              }
              else
             {
                   q=gp;
                   gp=p;
                   p=r;
              }
              if(data==r->data)
             {
                   flag=1;
                   break;
              }
              else  if(data<r->data)
                   r=r->lchild;
              else
                   r=r->rchild;
       }
       if(! flag)
      {
              r=(Treerb *)malloc(sizeof(Treerb));
              r->data=data;
              r->lchild=NULL;
              r->rchild=NULL;
              r->lc=C_B;
              r->rc=C_B;
              if(data<p->data)
             {
                    p->lchild=r;
                    p->lc=C_R;
              }
              else
             {
                    p->rchild=r;
                    p->rc=C_R;
              }
              ++info->nodes;
        }
       return !flag;
  }
//��ת����
  static  void  rotate_ll(Treerb *gp,Treerb *p,Treerb *r)//LL��ת
 {
        gp->lchild=p->rchild;
        p->rchild=gp;

        p->lc=C_R;
        p->rc=C_R;
        gp->lc=C_B;
  }
//LR��ת
  static  void  rotate_lr(Treerb  *gp,Treerb *p,Treerb *r)
 {
        p->rchild=r->lchild;
        gp->lchild=r->rchild;
        r->lchild=p;
        r->rchild=gp;

        r->lc=C_R;
        r->rc=C_R;
        gp->lc=C_B;
        p->rc=C_B;
  }
//RL������ת
  static  void  rotate_rl(Treerb *gp,Treerb  *p,Treerb *r)
 {
       gp->rchild=r->lchild;
       p->lchild=r->rchild;
       r->rchild=p;
       r->lchild=gp;
 
       r->lc=C_R;
       r->rc=C_R;
       p->lc=C_B;
       gp->rc=C_B;
  }
//RR��ת
  static  void  rotate_rr(Treerb *gp,Treerb *p,Treerb *r)
 {
       gp->rchild=p->lchild;
       p->lchild=gp;

       gp->rc=C_B;
       p->lc=C_R;
       p->rc=C_R;
  }
//ɾ������
  int  removerb(TreerbInfo  *info,int data)
 {
       Treerb  *r,*p,*q,*brt,*t;
       Treerb  *vbuf[32];
       int     len=0,flag=0;

       if(! info->root)
      {
             printf("ɾ���������󣬺�����Ѿ�Ϊ��!\n"); 
             return 0;
       }
//��������ĵ��ã���Ҫ������r�ĸ����������,��ˣ��������ĳһ���ֶμ�¼��r�ĸ���������
       r=info->root;
       p=NULL;
       q=NULL;
       brt=NULL;
       while( r )
      {
              p=r;
              if(data==r->data)
             {
                   flag=1;
                   break;
              }
              else if(data<r->data)
                   r=r->lchild;
              else
                   r=r->rchild;
       }
//���û���ҵ������������ֱ�ӷ���
       if(! flag)
            return 0;
           printf("  ***  ");
//���r�Ѿ���Ҷ��㣬��ֱ��ִ��ɾ������
           printf("  ###  %x",r);
       if(!r->lchild && !r->rchild)
      {
           if(r==info->root)
                 info->root=NULL;
           else
          {
                if(p->lchild==r)
               {
                     p->lchild=NULL;
                     p->lc=C_B;
               }
                else
               {
                     p->rc=C_B;
                     p->rchild=NULL;
                }
           }
           free(r);
           return 1;
        }
        len=find_next(r,vbuf);
        printf("  @@@  ");
//���볣��Ĵ������
        if(len>=3)
       {
              printf("   330  ");
              q=vbuf[--len];
              p=vbuf[--len];
              t=vbuf[--len];
              r->data=q->data;
              if( p->lc)//���Ϊ��ɫָ�룬��q�ض�ΪҶ���,����ֱ��ɾ��
             {
                   p->lc=C_B;
                   p->lchild=NULL;
              }
              else
             {
                   if( q->rchild)//��qΪ��ɫ��㣬������һ����ɫ������
                         p->lchild=q->rchild;
                   else if( p->rchild && p->rc)//���qֻ��һ��2���,�����ֵܽڵ���һ����ɫ���
                  {
                         brt=p->rchild;
                         p->rchild=brt->lchild;
                         p->lchild=NULL;
                         brt->lchild=p;

                         p->lc=C_B;
                         p->rc=C_B;
                         brt->lc=C_R;
                         if(t->lchild==p)
                             t->lchild=brt;
                         else
                             t->rchild=brt;
                   }
              }
              free(q);
              printf("  331  ");
         }
         else if(len==2)//��ʱ���ҷ�֧û��������
        {
              printf("  220  ");
              p=vbuf[--len];
              r->rchild=p->rchild;
              r->data=p->data;
              free(p);
              printf("  221  ");
         }
         else//������len����1�Ŀ���
        {
              printf("  000  ");
              if(! p)
             {
                 info->root=r->lchild;
              }
              else
             {
                  if(p->rchild==r)
                      p->rchild=r->lchild;
                  else
                      p->lchild=r->lchild;
              }
              free(r);
              printf("  001  ");
         }
     return 1;
  }
//���Һ���滻���,����ֵvbuf�������Ч����
  static int  find_next(Treerb  *r,Treerb **vbuf)
 {
        int  len=0;
    
        if(! r->rchild)
             return 0;
        vbuf[len++]=r;
        r=r->rchild;
        while(r)
       {
             vbuf[len++]=r;
             r=r->lchild;
        }
        return len;
  }
/**********************************************************************/
  int  main(int argc,char *argv[])
 {
        int   vbuf[256];//={50,10,75,92,5,85,90,7,40,9,30,80,60,70};
        int   len=16;
        int   seed,i;
        TreerbInfo   info;
        info.root=NULL;
        info.nodes=0;
        
        seed=time(NULL);
        srand(0x7C8F);
//        srand(seed);
        for(i=0;i<len;++i)
       {
             vbuf[i]=rand(); 
             printf("  %d  ",vbuf[i]);
             if(!(vbuf[i] & 0x7))
                  printf("\n");
        }

        printf("��ʼ���������:\n");
        for(i=0;i<len;++i)
       {
              if(insertrb(&info,vbuf[i]))
                   printf("%d����ɹ�!\n",vbuf[i]);
              else
                   printf("%d����ʧ��!\n",vbuf[i]);
        }
        printf("��ʼִ�в��Ҳ���:\n");
        for(i=0;i<len;++i)
       {
             if(searchrb(&info,vbuf[i]))
                  printf("%d���ҳɹ�!\n",vbuf[i]);
             else
                  printf("%d����ʧ��!\n",vbuf[i]);
       }
       printf("\n*******************************************************\n");
       printf("���濪ʼִ��ɾ������\n");
       for(i=0;i<len;++i)
      {
             if(removerb(&info,vbuf[i]))
                  printf("  %d  ɾ���ɹ�!\n",vbuf[i]);
             else
                  printf("  %d  ɾ��ʧ��!\n",vbuf[i]);
       }
        return 0;
  }
