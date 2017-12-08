//2013��4��2��21:47:50
//ΪGraham �㷨����Ƶ�ջ�� �������
 
  typedef  struct  _Point
 {
        int     x;
        int     y;
  }Point;

//ջ��ͷ��Ϣ
  typedef  struct  _StackHeader
 {
//ʹ������ʵ�ֵ�ջ
        int                *point;
//��¼������ܳߴ�
        int                size;
//��¼��ǰջ������(�¼ӵ�Ԫ����Ӧ���������)
        int                index;
  }StackHeader;

  int   push(StackHeader  *h,int  point_index)
 {
        int   flag=0;
        if(h->index<h->size)
       {
               h->point[h->index++]=point_index;
               ++flag;
        }
        return flag;
  }
//��ջ�е���Ԫ��
  int  pop(StackHeader  *h,int *p)
 {
        int  flag=1;
        *p=0x70000000;
        if( h->index>0 )
              *p=h->point[--h->index];
        else
             flag=0;
        return flag;
  }
  int   NextTop(StackHeader  *h,int  *p)
 {
        int   flag=1;
        *p=0x70000000;
        if(h->index>1)
              *p=h->point[h->index-2];
        else
              flag=0;
        return flag;
  }
//��ȡջ��Ԫ��
  int   GetTop(StackHeader  *h,int *p)
 {
        int  flag=1;
        *p=0x70000000;
        if( h->index )
              *p=h->point[h->index-1];
        else
              flag=0;
        return flag;
  }
//�����Ƕ�������ĵ��������/������(��������)
  static void   adjust(Point  *point,float  *arc,int  parent,int  size)
 {
         int        child;
         Point      pkey;
         float     fkey;

         pkey=point[parent];
         fkey=arc[parent];
         for(child=parent<<1; child<=size;   )
        {
                   if(child<size && arc[child]<arc[child+1])
                          ++child;
                   if(fkey<arc[child])
                  {
                          arc[parent]=arc[child];
                          point[parent]=point[child];
                   }
                   else if(fkey==arc[child] && pkey.x < point[child].x) //x��������������
                          point[parent]=point[child]; 
                   else    
                          break;   
                   parent=child;
                   child<<=1;
         }
         arc[parent]=fkey;
         point[parent]=pkey;
  }
//�Ե�������� ���ǵ���Լ��� ����/�мǣ���Ҫֱ��ʹ��ָ�룬Ҳ��Ҫ����point[0],����arc[0]
  void   SortPoint(Point  *point,float  *arc,int  size)
 {
         int       i;
         Point     tpp;
         float     tf;
 
         for(i=size>>1; i ;--i)
               adjust(point,arc,i,size);
         for(  i=size; i>1;    )
        {
                 tpp=point[1];
                 point[1]=point[i];
                 point[i]=tpp;

                 tf=arc[1];
                 arc[1]=arc[i];
                 arc[i]=tf;

                 adjust(point,arc,1,--i);
         }
  }