//2013��4��2��17:04:58
//��N�����У��������ǵ���С͹�������
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>
  #include"ջ�͵������.c"

//���������ĵ��
  #define   POINT_MUT(p1,p2)     ((p2->x-p1->x)*(p2->y-p1->y)) 
//���㼫����,q���p�Ļ���(���� ����ȷ�еĽǶ�)
//ע�⣬��Ϊ��Ļ�ϵ��������ճ�ʹ�õ�ָ������ϵ���źܴ������
  static  float   arc_local(Point  *p,Point  *q)
 {
       float   arc=0.0;
       float   x=0.0,y=0.0;
//���q��p���������򣬴�ʱq�ļ���Ӧ�ô���PI/2
       if(q->x<p->x)
      {
              x=(float)(p->x-q->x);
              y=(float)(p->y-q->y);
              arc=(float)(x/sqrt(x*x+y*y)+1);
       }
       else
      {
              x=(float)(q->x-p->x);
              y=(float)(p->y-q->y);
              arc=(float)(y/sqrt(x*x+y*y));
       }
       return arc;
  }
//������С͹�������(Graham �㷨ʵ��)
  void   GrahamScan(Point   *point,int  size,StackHeader  *h)
 {
       float   *arc;
       int     i,k,j=0;
       Point   *p,*q,*t,tpp;
//��Ҫʹ�õ������ݽ��г�ʼ��    
       h->point=(int  *)malloc(sizeof(int)*size);
       h->size=size;
       h->index=0;
       arc=(float *)malloc(sizeof(float)*size);
//Ѱ��������ĵ�����
       k=0;
       q=point;
       for(i=1;i<size;++i)
      {
             if(point[i].y>q->y)
            {
                   k=i;
                   q=&point[i];
             }
             else if(point[i].y==q->y && point[i].x<q->x)
            {
                   k=i;
                   q=&point[i];
             }
       }
//�����ǽ�������ĵ�ժ����
       tpp=point[k];
       --size;
       for(i=k;i<size;++i)
            point[i]=point[i+1];
       point[size]=tpp;
       p=&tpp;
//���ݵ�ü��ǶԵ�������������
       for(i=0;i<size;++i)
            arc[i]=arc_local(p,point+i);
       SortPoint(point-1,arc-1,size);
/*
       printf("����󣬵������˳��Ϊ:\n");
       for(i=0;i<size;++i)
      {
              printf("%d-->x:%d,y:%d \n",i,point[i].x,point[i].y);
       }
*/

//�����ǽ���ѭ���ĳ�ʼ�׶�
       push(h,size);
       push(h,0);
       push(h,1);

       for(i=2;i<size;++i)
      {
             t=point+i;
//             printf("��ǰԪ�ص� i:%d  x:%d,y:%d\n",i,t->x,t->y);
             GetTop(h,&k);
//             printf("վ��Ԫ��Ϊ:%d : x:%d,y:%d \n",k,point[k].x,point[k].y);
             do
            {
                  NextTop(h,&k);
                  p=&point[k];
                  GetTop(h,&j);
                  q=&point[j];
                  printf("p: %d  ,q:  %d   \n",k,j);
//ע������Ĳ�˲���,�ڼ������ʾ������ϵ�У�����ʵ�ʵĵѿ�������ϵ�պ��෴
                  if(((q->x-p->x)*(t->y-q->y)-(t->x-q->x)*(q->y-p->y))>=0)
                           pop(h,&k);
                  else
                           break;
              }while(h->index);
              push(h,i);
       }
  }
//
  int  main(int argc,char  *argv[])
 {
       Point   point[10]={{5,20},{10,18},{8,10},{24,16},{18,14},{11,0},{7,5}};
       int     i,k=0,len=7;
       StackHeader   hStack,*h=&hStack;

       printf("����󣬵��˳��Ϊ:\n");
       GrahamScan(point,len,h);

       printf("��ʣ��ĵ��У���Ϊ͹����εĶ�����:\n");
//ע������ȡ��ջ�е�Ԫ�صķ�ʽ
       for(i=0;i<h->index;++i)
      {
              k=h->point[i];
              printf("����%d:  x:%d,y:%d  \n",k,point[k].x,point[k].y);
       }
       return 0;
  }