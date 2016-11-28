//20113/1/7/14:17
//��С����Ѳ�������һ��������У����ǽ��������и����������ĶȵĴ�С�ϸ�صĽ�������
  #include<stdio.h>
  #include<stdlib.h>
  #define  INF_T   0x7FFFFFFF
//�������ѵ����ݽṹ
  typedef  struct  _Beap
 {
//������
        int               key;
//��¼���Ķ�
        int               degree;
//ָ�򸸽���ָ��
        struct  _Beap    *parent;
//ָ�����ֵܽ���ָ��
        struct  _Beap    *rsib;     
//ָ��������ָ��
        struct  _Beap    *child;  
  }Beap;
//�������ѵ�ͷ���Ľṹ
  typedef  struct  _BeapHeader
 {
//����ѵĸ�
        struct  _Beap    *root;
//��¼�������ѵĽ����Ŀ
        int              count;
  }BeapHeader;
//�ϲ��������
  static  void  union_2_node(Beap  *,Beap  *b);
//��ת����,����ʹ��Щ����ĸ�ָ��Ϊ��
  static  void  reverse_p_null_node(BeapHeader *);
//�ϲ����������,�����նȵĴ�С�����ϸ���������,ע�⣬������ֻ�ǽ��и������򣬵��������и��ĺϲ�
//���������治���в����ĺϷ��Լ��,��������ǰ������� ha,hb�������Ķ���Ѿ���Ϊ��
  void  beap_merge(BeapHeader  *ha,BeapHeader  *hb)
 {
//t��¼������������ѵĸ����
        Beap  *a,*b;
        Beap  *vbuf[32];
        int   k=0,i=0;
        a=ha->root;
        b=hb->root;
        while( a && b )
       {
//�����ʱ a�Ķ�С�ڵ���b���Ķ�,�ͽ�a����ǰ��
              if(a->degree<=b->degree)
             {
                     vbuf[k++]=a;
                     a=a->rsib;
              }
              else
             {
                     vbuf[k++]=b;
                     b=b->rsib;
              }
        }
        i=1;
        while(i<k)
       {
              vbuf[i-1]->rsib=vbuf[i];
              ++i;
        }
//ע������Ĵ���
        vbuf[i-1]->rsib=a?a:b;
        ha->root=vbuf[0];
        ha->count+=hb->count;
        hb->root=NULL;
        hb->count=0;
   }
//�ϲ�������о�����ͬ�ȵĸ����,������Ȼû�жԲ������м��
  void  beap_union(BeapHeader  *h)
 {
//aΪ��ǰ���,bΪa�ĺ�̽��,prevΪa��ǰ������aû��ǰ������prevΪ��
        Beap  *a,*b,*prev;
        prev=NULL;
        a=h->root;
        b=a->rsib;
//ѭ�����е�������a�ĺ�̲�Ϊ��
        while( b )
       {
                if(a->degree!=b->degree || (b->rsib && b->rsib->degree==b->degree))
               {
                      prev=a;
                      a=b;
                      b=b->rsib;
                }
                else if(a->key<=b->key)
               {
                      a->rsib=b->rsib;
                      union_2_node(a,b);
                      b=a->rsib;
                }
                else
               {
                      if(!  prev)
                           h->root=b;
                      else
                           prev->rsib=b;
                      union_2_node(b,a);
                      a=b;
                      b=b->rsib;
                }
         }
  }
//�ϲ����������,��b�ϲ���a��
  static void  union_2_node(Beap  *a,Beap  *b)
 {
//���Ƚ�a�Ķ�����һ
       b->rsib=NULL;
       ++a->degree;
       b->parent=a;
       b->rsib=a->child;
       a->child=b;
  }
//������С������С����ǰ������û��ǰ������prev��д��NULL,��prevΪNULL����д��.�����ʱ��O(ln(n))
  Beap  *find_min(BeapHeader  *h,Beap  **prev)
 {
//p��¼��aǰ��,b��¼����С�����,r��¼����С������ǰ��
       Beap  *a,*p,*b,*r;
//��ʼ������
       a=h->root;
       b=a;
       p=NULL;
       r=NULL;
       while( a )
      {
            if(a->key<=b->key)
           {
                 r=p;
                 b=a;
            }
            p=a;
            a=a->rsib;
       }
       if( prev )
            *prev=r;
       return b;
  }
//��һ��������в���һ�����
  Beap  *insert_beap(BeapHeader  *h,int key)
 {
      Beap  *p=(Beap  *)malloc(sizeof(Beap));
      p->key=key;
      p->parent=NULL;
      p->child=NULL;
      p->rsib=NULL;
      p->degree=0;

      p->rsib=h->root;
      h->root=p;
      ++h->count;
      beap_union(h);
      return p;
  }
//��ת����,��ʹ��Щ���ĸ�ָ��Ϊ��
  static  void  reverse_p_null_node(BeapHeader *ha)
 {
      Beap  *a,*b,*p;
      a=ha->root;
      b=NULL;
      p=NULL;
      
      while( a )
     {
           a->parent=NULL;
           p=b;
           b=a;
           a=a->rsib;
           b->rsib=p;
      }
      ha->root=b;
  }
//����С�������ɾ����Сֵ���
  Beap  *remove_min(BeapHeader *ha)
 {
      Beap  *a,*b,*prev=NULL,*tmp;
      BeapHeader  hbc,*hb=&hbc;
       
      a=ha->root;
      if(! a)
            return NULL;
      --ha->count;
      hb->count=0;
      hb->root=NULL;
//bΪ���ҵ�����С���,����С����ǰ��
      b=find_min(ha,&prev);
      tmp=b;
//�����ҵĽ���Ƿ��ǵ�һ�����
      if(! prev)//��ʱa==b
     {
           ha->root=b->rsib;
           hb->root=b->child;
           b->rsib=NULL;
      }
      else
     {
           prev->rsib=b->rsib;
           b->rsib=NULL;
           hb->root=b->child;
      }
//����hb�еĶ���ѵĸ����,��ת������ʹ��Щ���ĸ�ָ��Ϊ��
      reverse_p_null_node(hb);
//�ж�����������Ƿ�Ϊ��
      if(!ha->root)
     {
           ha->root=hb->root;
           hb->root=NULL;
      }
      else if(hb->root)
     {
          beap_merge(ha,hb);
          beap_union(ha);
      }
      return tmp;
  }
//�ؼ��ּ�ֵ����,���ؼ��ּ���������ֵ
  int  decrease_key(Beap *a,int key)
 {
      Beap  *p;
      
      if(a->key<key)
     {
            printf("������ֵ���ܴ��ڽ�㱾����ӵ�еĹؼ���ֵ\n");
            return 0;
      }
      a->key=key;
      p=a->parent;
//ʵ���ϣ��������ѭ�����Խ����ݽ�����һ��֮�ھͿ������
      while( p && p->key>a->key )
     {
//��������
            key=p->key;
            p->key=a->key;
            a->key=key;
//һֱð��������ֱ��ѭ���������ܳ���
            a=p;
            p=p->parent;
      }
      return 1;
  }
//ɾ������һ�����
  int  remove_node(BeapHeader  *h,Beap  *y)
 {
      Beap  *x;
      if( !h->root)
           return 0;
//***************************************************
//ע������Ĵ���
      x=find_min(h,NULL);
      decrease_key(y,x->key-1);
      x=remove_min(h);
      free(x);
      return 1;
  }
//******************************************************************
  int  main(int  argc,char *argv[])
 {
       BeapHeader    hdc,*ha=&hdc;
       Beap          *p;
       Beap          *insert_b[256];
       int           vbuf[256];
       int           size1=256,i,len=64;

       printf("��ʼ������1......\n");
       srand(0x7C8F9B); 
       for(i=0;i<size1;++i)
      {
             vbuf[i]=rand();
             printf(" %d  ",vbuf[i]);
             if(!(i & 0x3))
                 printf("\n");
       }
//...
       printf("���������.......\n");
       ha->root=NULL;
       ha->count=0;
       for(i=0;i<size1;++i)
           insert_b[i]=insert_beap(ha,vbuf[i]);
       printf("\n�������.....\n");
       printf("\n��ʼִ��ɾ����СԪ��....\n");
       for(i=0;i<len;++i)
      {
            p=remove_min(ha);
            printf(" %d:  %d \n",i,p->key);
            free(p);
       }
       printf("\n*********************ִ�м�ֵ����*********************************\n");
       for(i=len,len=128;i<len;++i)
      {
              vbuf[i]=rand()%997;
              decrease_key(insert_b[i],vbuf[i]);
       }
       printf("\n*********************�ٴ�ִ��ɾ������******************************\n");
       for(i=len>>1;i<len;++i)
      {
              p=remove_min(ha);
              printf("%d : %d \n",i,p->key);
              free(p);
       }
       printf("\n*********************2��ɾ������**************************************\n");
       for(i=len;i<size1;++i)
      {
              p=remove_min(ha);
              printf(" %d  :  %d  \n",i,p->key);
              free(p);
       }
       printf("\n*********************ɾ���������*************************************\n");
       return 0;
  }