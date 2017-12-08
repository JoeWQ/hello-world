//2013/1/10/14:36
//��С 쳲������ѵ���ز������Ͷ������ȣ�쳲������ѵĲ�������ʹ���ӵģ���Ϊ���Ľṹ�Ƚ���ɢ
//�����������в���������ƽ̯�����ϣ���������һ��������ʱ�俪������������
  #include<stdio.h>
  #include<stdlib.h>
/*********************************************/
  typedef  struct  _FibBeap
 {
        int         key;
//��¼�������ڳ�Ϊ���������ӽ���������Ƿ�ʧȥ�˺��ӽ��
        int         mark;
//��¼���Ķ�
        int         degree;
//ָ�򸸽���ָ��
        struct     _FibBeap   *parent;
//ָ���ӽ���ָ��
        struct     _FibBeap   *child;
//left,rightά����һ��˫��ѭ������
        struct     _FibBeap   *left;
        struct     _FibBeap   *right;
  }FibBeap;
//����쳲������ѵ�ͷ�ṹ
  typedef  struct  _FibBeapHeader
 {
//��¼쳲������ѵĸ���㣬�༴��С����㣬�����������ѵ�����
        struct  _FibBeap     *minrt;
        int                  count;
  }FibBeapHeader;

/************************************************/
//�ϲ�����������ͬ�ȵĽ��,ʹb��Ϊa��һ���ӽ��
  static  void  union_2_fib_beap(FibBeap *a,FibBeap *b);
//������С�����,���Ƿ���֮����Ȼ�ϲ���һ������
  static  void  split_fib_beap(FibBeapHeader  *);
//�����ӽ��
  static  void  process_child(FibBeap  *,FibBeapHeader *);
//��֦����
  static  void  cut_fib_beap(FibBeapHeader *,FibBeap *);
//���Խ����ں����
  static  void  print_node(FibBeapHeader *);
//��������������Ķ���(����ȡ��)
  static  int    lg2(int  lg)
 {
       int  i=0;
       while( lg>>=1 )
            ++i;
       return i;
  }
//�ϲ�����쳲�������,�����������������쳲������Ѿ���Ϊ��
  void  union_fib_beap(FibBeapHeader  *hfa,FibBeapHeader  *hfb)
 {
        FibBeap  *a,*b,*ar,*bt;
//ע��ϲ���������ʱ��һ��Ҫ�����Ҫ�⿪�Ǹ�����Ҫ�޸��Ǹ�������������׳���
        a=hfa->minrt;
        b=hfb->minrt;

        ar=a->left;
        bt=b->left;

        ar->right=b;
        b->left=ar;

        a->left=bt;
        bt->right=a;

        hfa->count+=hfb->count;
        hfb->count=0;
        hfb->minrt=NULL;
//�޸���С�����
        if(a->key>b->key)
             hfa->minrt=b;
  }
//��һ��쳲��������в���һ�����
  FibBeap  *insert_fib_beap(FibBeapHeader  *hf,int  key)
 {
        FibBeap   *f=(FibBeap  *)malloc(sizeof(FibBeap));
        FibBeap   *a,*r;
        f->key=key;
        f->mark=0;
        f->degree=0;
        f->parent=NULL;
        f->child=NULL;
//�޸�ָ��
        a=hf->minrt;
        if(!  a )
       {
               hf->minrt=f;
               f->left=f;
               f->right=f;
        }
        else
       {
               r=a->right;
               a->right=f;
               f->left=a;
         
               f->right=r;
               r->left=f;
//�޸���С�����
              if(key<a->key)
                   hf->minrt=f;
        }
        ++hf->count;
        return f;
  }
//ɾ����С���/��������Ƚϸ��ӣ���Ϊ���е���������������Ӧ����ɵ���û����ɵĹ���
//ͳ�ƾ�����ͬ�ȵĸ����,vbuf��ָ���������Ҫ�󣬷�������Խ����Ϊ
  static  void  record_fib_beap(FibBeapHeader  *hf,FibBeap  **vbuf)
 {
        int      i=0;
        FibBeap   *a,*y,*t;
//ע�⣬����֮����ѡ�����ַ���������Ϊ��������������ĺ����У���С������ѡ������
        a=hf->minrt;
        t=a->right;
        a->right=NULL;
        y=t;
        while( y )
       {
              i=y->degree;
              y->left=NULL;
              t=y->right;
//ע�⣬�����һ��������ʹ�ýڵ��е�right������ ���������
              y->right=vbuf[i];
              vbuf[i]=y;
              y=t;
       }
  }
//��������ͬ�ȵĸ�����������������γ�һ�������ĸ���
  static  void  consolate_fib_beap(FibBeapHeader  *hf,FibBeap  **vbuf,int len)
 {
       FibBeap  *y,*t,*r;
       FibBeap  *rt=hf->minrt;  //��¼��С�����
       int   i;

       t=NULL,r=NULL;
       for(i=0;i<=len;++i)
      {
//�ϲ�����
            y=vbuf[i];
            vbuf[i]=NULL;
            while( y )
           {
                  t=y->right;
                  if(! t )
                 {
                     vbuf[i]=y;
                     break;
                  }
                  r=t->right;
//ע�������һ������
                  y->right=NULL;
                  t->right=NULL;
//���Կ���һ�£����������������ֵͬ����С�ģ������Ƿ�������Ҫ�޸�hf->minrt��ֵ ������
                  if(y->key<=t->key)
                 {
                      union_2_fib_beap(y,t);
//ע�⣬���ﲢ������������Խ����Ϊ����Ϊ쳲������ѵ������Ѿ���֤������������ᷢ��
                      y->right=vbuf[i+1];
                      vbuf[i+1]=y;
//��¼�����,��һ���������ȥ��ӦΪ���漰���ظ�����С������ѡ��
                      if(y->key==rt->key)
                            rt=y;
                  }
                  else
                 {
                      union_2_fib_beap(t,y);
                      t->right=vbuf[i+1];
                      vbuf[i+1]=t;
                  }
                  y=r;
            }
       }
       hf->minrt=rt;
  }
  FibBeap   *remove_fib_beap_min(FibBeapHeader  *hf)
 {
       FibBeap   *a,*y,*r,*tmp;
//�������������Ϊ�˺ϲ���������Ҫ������
       FibBeap   **vbuf;
       int       i,len;
       a=hf->minrt;
       if(!  a )
      {
             printf("ɾ������쳲����������Ѿ�Ϊ��!\n");
             return NULL;
       }
//tmp��¼����С�����,����Ϊ����ֵ��Ӧ�ñ����Ᵽ��
       tmp=a;
       --hf->count;
//�����ֻʣ���һ����㣬��������кϲ�����������ֱ�ӷ���
       if(! hf->count)
          return tmp;
//����С���������к��ӽ����ѳ��������ڴ˺ϲ���������
       split_fib_beap(hf);
//ע������Ĵ��룬���ǲ�ȡ���ÿռ任ʱ��Ĳ���
       len=lg2(hf->count)+1;

       vbuf=(FibBeap **)malloc(sizeof(FibBeap *)*(len+1));
//��ʼ�������
       for(i=0;i<=len;++i)
           vbuf[i]=NULL;
//����ͳ����Ϣ
       record_fib_beap(hf,vbuf);
//���������ϲ�������ͬ�ȵĸ����
       consolate_fib_beap(hf,vbuf,len);
//���Ĳ������Ѿ���ɢ�ĸ����ϲ���һ��˫��ѭ������
//r��¼��ѭ���������ǰ�˵Ľ��
//y��¼�ŵ�ǰ����ǰ��
       r=NULL;  
       y=NULL;  
//a��¼�ŵ�ǰ�Ľ��
       for(i=0;i<=len;++i)
      {
              a=vbuf[i];
              if(  a  )
             {
                   if(! r )
                        r=a;
                   else
                  {
                        y->right=a;
                        a->left=y;
                   }
                   y=a;
              }
        }
        r->left=y;
        y->right=r;
        free(vbuf);
        return tmp;
   }
//�ϲ��������,��b�ϲ���a��
  static  void  union_2_fib_beap(FibBeap  *a,FibBeap *b)
 {
        FibBeap  *y=a->child;
        FibBeap  *x;
        ++a->degree;
//������
        b->mark=0;
//��b�ϲ���a�ĺ��ӽ����
        b->parent=a;
        if(! y)
       {
              a->child=b;
              b->right=b;
              b->left=b;
        }
        else
       {
              x=y->left;
              b->right=y;
              y->left=b;
              b->left=x;
              x->right=b;
        }
  }
//������С�����,������������õ�ǰ�������:��С������Ѿ���������
  static  void  split_fib_beap(FibBeapHeader  *fa)
 {
        FibBeap        *a,*r,*t;
        FibBeapHeader  hfc,*fb=&hfc;
//�ȷ���
        a=fa->minrt;
        r=a->right;
//���ֻʣһ�������
        if(a==r)
             process_child(r->child,fa);
        else
       {
             fb->minrt=NULL;
             fb->count=0;
//ȥ����� a
             t=a->left;
             t->right=r;
             r->left=t;
             process_child(t,fa);
             process_child(a->child,fb);
//���������������ִ�кϲ�������� 
             if(fa->minrt && fb->minrt)
                  union_fib_beap(fa,fb);
        }
//Ϊ�����ݵ���˽���������������С�����Ķ��ӽڵ���ΪNULL
       a->child=NULL;
  }
  static  void  process_child(FibBeap  *child,FibBeapHeader  *ha)
 {
       FibBeap  *r,*t,*p;
       
       if(! child)
             ha->minrt=NULL;
       else
      {
             t=child->right;
             child->right=NULL;
//������С����㣬�ҽ����ӽڵ����Ӧ���������޸�
             p=t;
             r=t;
             while( r )
            {
                  r->parent=NULL;
                  r->mark=0;
                  if(p->key>r->key)
                      p=r;
                  r=r->right;
             }
             ha->minrt=p;
             child->right=t;
       }
   }
//��ֵ����,������ļ�ֵ �Ͷ�����еļ�ֵ������£��������кܶ�ط���һ��
//���е�����Ҫ��һ�㣬���������˱�� �޸�
  int  decrease_key(FibBeapHeader  *hf,FibBeap  *x,int key)
 {
        FibBeap    *p,*y;
        if(x->key<=key)
       {
              printf("������ֵ %d ���ܴ��ڽ��Ĺؼ���ֵ%d\n",key,x->key);
              return 0;
        }
        x->key=key;
        p=x->parent;
//����������������ļ�����֦����
        y=x;
       if(p && x->key<p->key)
      {
              cut_fib_beap(hf,x);
//ע��������߼�
              x=p;
              p=p->parent;
              while( p )
             {
                    if(! x->mark)
                   {
                          x->mark=1;
                          break;
                    }
                    else
                   {
                          cut_fib_beap(hf,x);
                          x=p;
                          p=p->parent;
                    }
              }
        }
      if(y->key<hf->minrt->key)
            hf->minrt=y;
       return 1;
  }
//��֦����
  static  void  cut_fib_beap(FibBeapHeader  *hf,FibBeap *x)
 {
        FibBeap  *p,*r,*t;
        FibBeap  *child;

//��һ�������x�����ĸ����Ĺ�ϵ
        p=x->parent;
        --p->degree;
        x->mark=0;
        x->parent=NULL;
        child=p->child;
//���ֻ��һ�����ӽ�㣬�ض���x
        if(child->right==child)
               p->child=NULL;
        else
       {
               r=x->right;
               t=x->left;
               r->left=t;
               t->right=r;
//ע�⣬�����һ��������
               if(child==x)
                     p->child=r;
        }
//�ڶ����⿪����ѭ����,Ȼ���ٺϲ�
        r=hf->minrt;
        t=r->right;

        r->right=x;
        x->left=r;
 
        x->right=t;
        t->left=x;
  }
//ɾ������һ�����,ɾ����������ʽ�������ڶ���ѣ���������������
  int  remove_fib_beap(FibBeapHeader *hf,FibBeap  *x)
 {
        FibBeap  *r;
      
        if(r=hf->minrt)
       {
             decrease_key(hf,x,r->key-1);
             r=remove_fib_beap_min(hf);
             free(r);
             return 1;
        }
        return 0;
  }
//��ӡ����������
  void  print_node(FibBeapHeader  *hf)
 {
        FibBeap  *r,*t,*p;
        int  i=0;
        r=hf->minrt;
        if(!  r)
           return;
        t=r->right;
        r->right=NULL;

        printf("____________________��ʼ______________________\n");
        p=t;
        while(  p )
       {
                 printf("%d------->%d  \n",i++,p->key);
                 p=p->right;
        }
        printf("++++++++++++++++++++����++++++++++++++++++++++++\n");
        r->right=t;
  }
//��������
  int  main(int  argc,char *argv[])
 {
       int  vbuf[256];
       int  size=128,i=0,len=64,j=32;
       
       FibBeap  *buf[245];
       FibBeap  *p;
       FibBeapHeader  hdc,*hf=&hdc;
       
       srand(0x7c8B);
       printf("��ʼ������.....\n");
       for(i=0;i<size;++i)
      {
             vbuf[i]=rand();
             printf("  %d  ",vbuf[i]);
             if(!(i & 0x3))
                 printf("\n");
       }
/**********************�������******************************/
       printf("���ڿ�ʼִ�в������............\n");
       hf->minrt=NULL;
       hf->count=0;
       for(i=0;i<size;++i)
             buf[i]=insert_fib_beap(hf,vbuf[i]);
       printf("********�����������***********\n");

       printf("**************������ɾ����СԪ�صķ�ʽɾ�����е���������Ԫ��*******\n");
/*
       for(i=0;i<len;++i)
      {
            p=remove_fib_beap_min(hf);
            printf("  %d--->  %d   \n",i,p->key);
            free(p);
       }
*/
       printf("\n**************************���ڿ�ʼ���м�ֵ����*****************************\n");
       for(i=len,len<<=1;i<len ;++i)
            decrease_key(hf,buf[i],j++);
       printf("**********************���ڲ��Լ�ֵ�����Ľ��*********************\n");
       for(i=0,len>>=1;i<size;++i)
      {
            p=remove_fib_beap_min(hf);
            printf(" %d ----->%d  \n",i,p->key);
       }
       return 0;
  }