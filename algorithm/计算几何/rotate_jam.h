/*
  *@aim:最小凸多边形,旋转卡壳算法C++实现
  *date:2015-5-12
  */
  #ifndef    __ROTATE_JAM_H__
  #define   __ROTATE_JAM_H__
  #include<vector>
  struct       Point
  {
  //顶点的坐标，注意这里我们将统一使用标准正交坐标系
                float            x,y;
  };
   class    RotateJam
   {
         private:
                 Point              *m_points;
                 int                    m_size;
 //每个顶点所对应的极坐标,数组的长度等于m_size
                 float               *m_angles;
//存放计算后结果的数组，长度<=m_size
                 std::vector<Point   *>         m_results;
          private:
                 RotateJam(RotateJam  &);
          public:
//输入内容，顶点坐标的集合，长度
//@request:size>=3,且不要有重复的顶点坐标
                  RotateJam(Point     *points,int   size);
                  ~RotateJam();
//预处理                  
                  void             preprocess();
//求解结果
                  void             resolve();
//获取结果，函数将不会对数组的长度做检查,并且会将数组的真是长度写入输入的参数中
                  void             result(Point       *point,int     *size);
   };
  #endif
  