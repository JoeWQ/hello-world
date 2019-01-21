//2013��4��6��15:07:05
//��N����֮��Ѱ�Ҿ���(ŷ����þ���)����ĵ��
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>

  #define   E_INF    0xFFFFFFFF
//�������ṹ��ʾ
  typedef  struct  _Point
 {
        int      x;
        int      y;
  }Point;
//һЩ�м����ݽṹ
  typedef  struct  _XYPoint
 {
//�����Ѿ����ڵĵ��X��Y����
        int       xy;
//��¼�õ������
        int       index;
  }XPoint;
//�Ե�������򰴵��ĳһƫ���������
  static  void  adjust(XYPoint   *pxy,int  parent,int  size)
 {
        int         child,tmp;
        XYPoint     key;

        key=pxy[parent];
        tmp=key.xy;
        for(child=parent<<1; child<=size;   )
       {
              if(child<size && pxy[child].xy < pxy[child+1].xy)
                      ++child;
              if(tmp >= pxy[child].xy)
                      break;
              else
                      pxy[parent]=pxy[child];

              parent=child;
              child<<=1;
        }
        pxy[parent]=key;
  }
//�������㷨
  static  void  heap_sort(XYPoint  *pxy,int  size)
 {
        int         x,y,parent,i;
        XYPoint     tmp;
//�Զ�������ĵ���
        for(parent=size>>1;parent ;--parent)
                 adjust(pxy,parent,size);
//�������������
        for(i=size; i ;    )
       {
                tmp=pxy[i];
                pxy[i]=pxy[1];
                pxy[1]=tmp;

                adjust(pxy,1,--i);
        }
  }
//Ѱ��������
  void   least_distance(Point  *point,int  size)
 {
        XYPoint   *xpoint,*ypoint;
//p1,p2��¼�ŷ����㷨�У����߾�����С����ĵ��(��point�е�����)����pp���¼�����յ���̵�Ծ���
        Point     p1,p2,pp;
        int       len=size+1;
        int       i,j,k,m;
        double    disc,xm;//xm�Ƿֽ��ߣ�min��¼�ŵ�֮�����С����
        double    *min;
         

        xpoint=(XYPoint  *)malloc(sizeof(XYPoint)*len);
        ypoint=(XYPoint  *)malloc(sizeof(XYPoint)*len);
        *min=(double *)malloc(sizeof(double)*(1+(size>>1)));
//���Ʋ���
        for(x=0,y=1;x<size;++x,++y)
       {
               xpoint[y].xy=point[x].x;
               ypoint[y].xy=point[x].y;
               xpoint[y].index=ypoint[y].index=point[x].index;
        }
//�����ǵ���������
        heap_sort(xpoint,size);
        heap_sort(ypoint,size);
//һ���ǲ��÷��η�������ʽ�Ϻ͹鲢���������
//��Ϊ��i=2ʱ������Ƚ����⣬����Ҫ�������������
//���� min �Ĺ�����һ�����μ�¼
        k=0
        for(i=1;i<size;i+=2)
       {
              j=xpoint[i].index;
              m=xpoint[i+1].index;
              disc=point[j].x-point[m].x;
              xm=point[j].y-point[m].y;
              min[k++]=sqrt(disc*disc+xm*xm);
        }
//���size������
        if(size & 0x 1)
              min[k++]=E_INF;
//������һ���ϲ��Ĺ���
        for(i
               