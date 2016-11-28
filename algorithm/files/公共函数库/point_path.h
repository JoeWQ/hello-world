//2014Äê1ÔÂ17ÈÕ17:34:20
//
   #ifndef   __POINT_PATH_H
   #define  __POINT_PATH_H
  struct    Point
 {
          int      x;
          int      y;
  };
  struct    PointSequence
 {
         struct   Point    **trace;
         int                     size;
 };
  #endif