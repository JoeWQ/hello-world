//2012/12/19/11:44
//�ڴ�����㷨ʵ��
  #include<stdio.h>
//  #include<stdlib.h>
  #define   MAX_SIZE   8192
  typedef  unsigned  short  Word;
  typedef  unsigned  int    Dword;
/**************************************/
//ע�⣬���Ƿ����ڴ�����8�ֽ�Ϊ��λ��,�������ֻʹ���˱Ƚϼ򵥵��ڴ�������
//�ں��棬���ǽ���ʹ�ø��Ӹ��Ӷ���Ч���ڴ�������
  typedef  struct  _M_Alloc
 {
//��¼����ڴ��ǰһ���ڴ������
        Word    plink;
//��¼��һ���ڴ������(size*8),ͬʱ���3λҲ������������ʾ:��0λ��ʾʹ�����(1��ʾ�Ѿ�����,0��ʾ�Ѿ��ͷ�)
        Word    size;
//��¼��һ���ڴ������
        Word    nlink;
//��һ���ڴ�ı�ʾ��,��nlinkΪ0ʱ��ntag��ʹ��
        Word    tag;
  }M_Header;
//��¼�����ڴ����������ڴ�ͷ��Ϣ
  typedef  struct  _M_Header
 {
//��¼�ɹ�������ڴ���׵�ַ�����ֵһ������ʼ���������ᱻ�ı�
        char       *top;
//��¼�����ɹ�������ڴ�ĳߴ�
        int        size;
//��¼�Ѿ�������ڴ�Ƭ����
        int        seg;
//��¼���һ����������ڴ��ַ.Ҳ���������߽�����������ָ��ָ���Ƿ�Խ��
        char       *last;
  }M_Header;
//�ϲ���������Ƭ���˵��ڴ�
  static  void  union_m(M_Alloc *,int);
//���е��ڴ�ռ����һ��պ�����ҳ(8192�ֽ�)
  static  M_Header   mfirst,*first=NULL;
  static  char      vbuf[MAX_SIZE];
//�Զ����ڴ���� ����
  static  void  init_memory()
 {
        M_Alloc  *mal;
//first��ֵһ������ʼ���������ᱻ�ı�
        first=&mfirst;
        first->top=vbuf;
        first->last=(int *)(top+MAX_SIZE);
        first->seg=0;
        first->size=MAX_SIZE;
//Ϊ��һ���ڴ���г�ʼ��
        mal=(M_Alloc *)first->top;
        mal->plink=(Word)0;
// ��¼��һ��ռ�Ĵ�С���ͱ��(��Ч����û�б�ʹ��)
        mal->size=(Word)(MAX_SIZE>>3);
        mal->tag=(Word)(0x0);
        mal->nlink=(Word)0;
  }
  void   *mapply(int  size)
 {
       M_Alloc  *p,*q,*r,*t;
       int      j,k;
       k=size+8;
//����8�ֽڶ���
       ++first->seg;
       if(k & 0x7)
           k=k( & 0xFFFFFFF8)+8;
       p=first->top;
       for(  ;!p->nlink ;  )
      {
            j=p->size<<3;
            if(!(p->tag & 0x8000) &&(j>=k))//���p�������ڴ�ռ�û�б����룬�ҿռ��㹻
                 break;
            p=(M_Alloc  *)((char *)p+j);
       }
//�������ʧ��
       j=p->size<<3;
//�����ж��������������趨���ڳߴ�ռ���䷽ʽ�й�
       if((p->tag & 0x8000) || j<k)//������һ���ڴ���Ѿ�������,���߳ߴ粻��
      {
             printf("�ڴ�ռ䲻��,����ʧ��!\n");
             return NULl;
       }
//������뵽���ڴ�����ǰ���ͷŵ����ڴ�
       if(p->nlink)
      {
//�������ڴ����������ڴ�ĳߴ�Ĳ�ֵ������16����ô��ֻ�����ѱ�����ı�Ǽ���
            if(j-k<16)
                  p->tag|=0x8000;
            else
           {
//�����һ���ڴ���Ѿ���ʹ��
                 if(p->tag & 0x0080)
                {
 //�����p�����ŵ��ڴ��
                       q=(M_Alloc *)((char *)p+k);
                       r=(M_Alloc *)((char *)p+j);

                       p->size=k>>3;               //���ϳߴ�
                       p->tag=(Word)0x8000;        //���ϱ��
                       q->plink=k;
                       q->size=(j-k)>>3;
                       q->tag=(Word)(0x80);
                       
                       q->nlink=r->size<<3;
                       r->plink=(Word)(j-k);
                       return p;
                 }
                 else//����ִ�кϲ�����
                      union_m(p,k);
             }
        }
        else
       {
            p->size=k;
            p->tag=(Word)0x8000;
            p->nlink=(Word)(j-k);

            q=(M_Alloc *)((char *)p+k);
            q->plink=(Word)k;
            q->size=(Word)((j-k)>>3);
            q->tag=(Word)0x0;
            q->nlink=(Word)0;
        }
     return p;
  }
//��������ĵ���������p����һ���ڴ�����Ѿ����ͷŵģ�������ý������
  static  void  union_m(M_Alloc  *p,int k)
 {
       int       sum=0,j,n;
       M_Alloc   *q,*r,*t=NULL;

       j=p->size<<3;
       q=(M_Alloc *)((char *)p+k);
       r=(M_Alloc *)((char *)p+j);
       
       sum+=(j-k);
       t=r;
       for(  ;!r<first->last && ( r->tag & 0x8000) ; )//�ж��������������ڴ���ǿ��е�,��û�е���ĩβ
      {
               t=r;
               n=r->size<<3;
               sum+=n;
               r=(M_Alloc *)((char *)r+n);
       }
       p->size=(Word)(k>>3);
       p->tag=(Word)0x8000;
       p->nlink=(Word)sum;

       q->size=(Word)(sum>>3);
       q->plink=(Word)k;
       
       if(r>=first->last)
           r=t;
       if(r->nlink)//���û�е���ĩβ
      {

             r->plink=(Word)sum;
             q->tag=(Word)0x0080;
             q->nlink=(Word)(r->size<<3);

       }
       else
      {
             q->tag=(Word)0x0000;
             q->nlink=(Word)0;
       }
  }
//�ͷ��ڴ����
  int  free(void  *t)
 {
       M_Alloc  *q,*r,*p;
       int      j,k;

       p=(M_Alloc *)((char *)t-8);
       if(!(p->tag & 0x8000))
      {
          printf("����ڴ���Ѿ����ͷŹ���!\n");
          return 0;
       }
//��ʾ����ڴ��Ѿ����ͷ�
       p->tag&=0xFF;
       j=p->size<<3;
       q=(M_Alloc *)((char *)p+j);
       if(q<first->last)
      {
            
     