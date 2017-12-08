//迷宫求解
   #ifndef   __FIND_PATH_H_
   #define  __FIND_PATH_H_

//求解迷宫问题时 所要用到的工具
   #include"LinkedList.h"
   #include"point_path.h"
   #include"ArrayList.h"
   struct    Maze;
  class    walk_path
 {
      private:
//当前 迷宫的 宽度和高度
          int      row,column;
//代表迷宫 的布尔数组
          bool    *maze;
//标志
          bool    *mark;
//双端队列
          LinkedList<Point>    track;
    public:
          walk_path( struct  Maze  * );
          ~walk_path();
// 各种参数重置
          void      reset();
          void      set_maze( struct  Maze *  );
//给定参数，返回 对应的 求解方案,如果存在可行路径，则返回 真，否则返回false
//在调用这个方法的时候 起点和终点不能相同
//所返回的路径 不包括 起点，但是包括了终点
          bool      search_path(  struct  Point  *from,struct   Point  *to,ArrayList<Point>  *);
   private:
//在 所在的方格 四周 做出选择
 //         void      do_some_choice();
 };
  #endif