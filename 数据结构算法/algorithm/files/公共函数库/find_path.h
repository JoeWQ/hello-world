//�Թ����
   #ifndef   __FIND_PATH_H_
   #define  __FIND_PATH_H_

//����Թ�����ʱ ��Ҫ�õ��Ĺ���
   #include"LinkedList.h"
   #include"point_path.h"
   #include"ArrayList.h"
   struct    Maze;
  class    walk_path
 {
      private:
//��ǰ �Թ��� ��Ⱥ͸߶�
          int      row,column;
//�����Թ� �Ĳ�������
          bool    *maze;
//��־
          bool    *mark;
//˫�˶���
          LinkedList<Point>    track;
    public:
          walk_path( struct  Maze  * );
          ~walk_path();
// ���ֲ�������
          void      reset();
          void      set_maze( struct  Maze *  );
//�������������� ��Ӧ�� ��ⷽ��,������ڿ���·�����򷵻� �棬���򷵻�false
//�ڵ������������ʱ�� �����յ㲻����ͬ
//�����ص�·�� ������ ��㣬���ǰ������յ�
          bool      search_path(  struct  Point  *from,struct   Point  *to,ArrayList<Point>  *);
   private:
//�� ���ڵķ��� ���� ����ѡ��
 //         void      do_some_choice();
 };
  #endif