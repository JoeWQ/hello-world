//改进后的迷宫算法实现
//注意，使用 这个迷宫算法 并不能使所寻找到的路径都是最短路径
//2014年1月18日9:40:21
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
//参数重置
  void   walk_path::reset(  )
 {
           track.clean();
           memcpy(mark,maze,sizeof(bool)*row*column);
 }
// 重新设置参数,注意，作为这个函数调用的假设，walk_path 对象 只用在一个 游戏中，切地图是不变的，如果不满这个条件，下面的代码必须被重写
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
//查找 可行路径，但是这个路径不一定是 最短路径
    bool    walk_path::search_path( struct   Point   *from,struct   Point  *to,ArrayList<Point>  *trace)
   {
           LinkedList<Point>   *pc=&track;
           struct    Point         *p=NULL;
           struct    Point         *q =NULL;
           struct    Point         cache[4];     //保存被选中的临时节点
           int                          weight[4];   //权值的计算
           if( from->x == to->x && from->y == to->y )
                   return false;
           int         dx = (to->x - from->x) >= 0 ? 1: -1;
           int         dy = (to->y - from->y )>=0 ? 1: -1;
           int         x,y;
           int         idx,i;
//将 起点加入队列
		   Point    *fp=(Point *)malloc(sizeof(Point));
		   fp->x=from->x;
		   fp->y =from->y;
           pc->addLast( fp );
//将起始 方格 标记为已经占用
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
//对上下左右四个方向 进行搜索,但是搜索 的次序 根据 目标点 和 原点 的相对位置 动态决定
                   x = p->x + dx;
                   y = p->y + dy;
//如果在  水平方向 的 方格 可用
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
//如果以上条件都不满足，则将已经删除掉的节点所占用的内存 释放掉
                if(   idx   )
               {
//下面的 计算相当于 A*算法中 f(n) 函数
                          for( i=0;i<idx;++i   )
                         {
//增加权值，当 x,y本身 很小的时候，效果不是很明显
                                   x = to->x -cache[i].x;
                                   y = to->y - cache[i].y;
                                   weight[i] = (int)sqrt( double(x * x + y * y));
                          }
                          x = 0x7FFFFFFF;
                          y = -1;
//查找最小权值，并记录预制相对应的 索引
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
//当这个方格被占领的时候，做出标记
                        mark[q->x * column +q->y] = true;
                        pc->addLast( p );
                        pc->addLast( q );
                }
                else
                           free( p );
          }
//如果 路径是可以达到的,执行数据的拷贝
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