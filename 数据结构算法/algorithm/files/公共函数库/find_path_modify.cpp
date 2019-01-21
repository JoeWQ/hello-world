//�Ľ�����Թ��㷨ʵ��
//ע�⣬ʹ�� ����Թ��㷨 ������ʹ��Ѱ�ҵ���·���������·��
//2014��1��18��9:40:21
   #include"find_path.h"
   #include<stdlib.h>
   #include<stdio.h>
   #include<string.h>
   //#include<math.h>
  #include"Enemy.h"
 //  #include"ArrayList.h"
//********************************************************
    walk_path::walk_path( struct  Maze  *m)
   {
             int     size = m->row * m->column *sizeof(bool);
             this->maze = ( bool *)malloc( size );
             this->mark = (bool *)malloc( size);
             memcpy(this->maze,m->maze,size);
             memcpy(this->mark,m->maze,size);

             this->row = m->row;
             this->column = m->column;
   }
   walk_path::~walk_path(  )
  {
            free( maze );
            free( mark );
  } 
//��������
  void   walk_path::reset(  )
 {
           track.clean();
           memcpy(mark,maze,sizeof(bool)*row*column);
 }
// �������ò���,ע�⣬��Ϊ����������õļ��裬walk_path ���� ֻ����һ�� ��Ϸ�У��е�ͼ�ǲ���ģ���������������������Ĵ�����뱻��д
  void    walk_path::set_maze(struct   Maze  *m)
 {
             int     size = m->row * m->column *sizeof(bool);
             if(   this->row * this->column != size )
            {
                    free( maze );
                    free( mark );
                    track.clean();
                    this->maze = ( bool *)malloc( size );
                    this->mark = (bool *)malloc( size);
                    this->row = m->row;
                    this->column = m->column;
                    memcpy(this->maze,m->maze,size);
                    memcpy(this->mark,m->maze,size);
            }
            else
           {
			        track.clean();
                    memcpy(this->mark,m->maze,size);
                    memcpy(this->maze,m->maze,size);
           }
 }
//���� ����·�����������·����һ���� ���·��
    bool    walk_path::search_path( struct   Point   *from,struct   Point  *to,ArrayList<Point>  *trace)
   {
           LinkedList<Point>   *pc=&track;
           struct    Point         *p=NULL;
           struct    Point         *q =NULL;
           struct    Point         cache[4];     //���汻ѡ�е���ʱ�ڵ�
           int                          weight[4];   //Ȩֵ�ļ���
           if( from->x == to->x && from->y == to->y )
                   return false;
           int         dx = (to->x - from->x) >= 0 ? 1: -1;
           int         dy = (to->y - from->y )>=0 ? 1: -1;
           int         x,y;
           int         idx,i;
//�� ���������
		   Point    *fp=(Point *)malloc(sizeof(Point));
		   fp->x=from->x;
		   fp->y =from->y;
           pc->addLast( fp );
//����ʼ ���� ���Ϊ�Ѿ�ռ��
           mark[from->x * column + from->y ] = true;
           while(  pc->getSize()  )
          {
                   idx = 0;
                   p = pc->removeLast();
                   if(  p->x == to->x && p->y == to->y  )
                  {
                             pc->addLast( p );
                             break;
                   }
//�����������ĸ����� ��������,�������� �Ĵ��� ���� Ŀ��� �� ԭ�� �����λ�� ��̬����
                   x = p->x + dx;
                   y = p->y + dy;
//�����  ˮƽ���� �� ���� ����
                   if( x>=0 && x< row && !mark[x * column + p->y]  )
                  {
                            cache[idx].x = x;
                            cache[idx].y = p->y;
                            ++idx;
                  }
                  if( y >=0 && y<column && !mark[p->x*column + y] )
                 {
                            cache[idx].x = p->x;
                            cache[idx].y = y;
                            ++idx;
                 }
                 x = p->x -dx;
                 y = p->y - dy;
                 if( x >=0 && x <row && !mark[x*column + p->y])
                {
                            cache[idx].x = x;
                            cache[idx].y = p->y;
                            ++idx;
                 }
                if( y>=0 && y < column && !mark[p->x*column + y] )
               {
                            cache[idx].x = p->x;
                            cache[idx].y = y;
                            ++idx;
                }
//������������������㣬���Ѿ�ɾ�����Ľڵ���ռ�õ��ڴ� �ͷŵ�
                if(   idx   )
               {
//����� �����൱�� A*�㷨�� f(n) ����
                          for( i=0;i<idx;++i   )
                         {
//����Ȩֵ���� x,y���� ��С��ʱ��Ч�����Ǻ�����
                                   x = to->x -cache[i].x;
                                   y = to->y - cache[i].y;
                                   weight[i] = (int)sqrt( double(x * x + y * y));
                          }
                          x = 0x7FFFFFFF;
                          y = -1;
//������СȨֵ������¼Ԥ�����Ӧ�� ����
                         for( i= 0 ;i< idx ;++i)
                        {
                                   if( weight[i] < x )
                                  {
                                          x = weight[i];
                                          y = i;
                                   }
                        }
                        q = (struct  Point  *)malloc(sizeof(struct  Point));
                        q->x = cache[y].x;
                        q->y = cache[y].y;
//���������ռ���ʱ���������
                        mark[q->x * column +q->y] = true;
                        pc->addLast( p );
                        pc->addLast( q );
                }
                else
                           free( p );
          }
//��� ·���ǿ��Դﵽ��,ִ�����ݵĿ���
		   pc->removeFirst();
         if(  pc->getSize() )
        {
			    pc->rewind();
                 while( p=pc->next() )
                {
                      trace->insert(p);
                 }
                 return  true;
         }

         return  false;
   }
#include"ArrayList.cpp"
#include"LinkedList.cpp"