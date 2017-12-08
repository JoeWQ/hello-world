//2013年4月2日21:47:50
//为Graham 算法而设计的栈和 点的排序
 
  typedef  struct  _Point
 {
        int     x;
        int     y;
  }Point;

//栈的头信息
  typedef  struct  _StackHeader
 {
//使用数组实现的栈
        int                *point;
//记录数组的总尺寸
        int                size;
//记录当前栈的容量(新加的元素所应填入的索引)
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
//从栈中弹出元素
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
//获取栈顶元素
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
//下面是对所输入的点进行排序/堆排序(降序排序)
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
                   else if(fkey==arc[child] && pkey.x < point[child].x) //x坐标大的往后面排
                          point[parent]=point[child]; 
                   else    
                          break;   
                   parent=child;
                   child<<=1;
         }
         arc[parent]=fkey;
         point[parent]=pkey;
  }
//对点进行依据 它们的相对极角 排序/切记，不要直接使用指针，也不要引用point[0],或者arc[0]
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