/*
  *@aim:��С͹�����,��ת�����㷨C++ʵ��
  *date:2015-5-12
  */
  #ifndef    __ROTATE_JAM_H__
  #define   __ROTATE_JAM_H__
  #include<vector>
  struct       Point
  {
  //��������꣬ע���������ǽ�ͳһʹ�ñ�׼��������ϵ
                float            x,y;
  };
   class    RotateJam
   {
         private:
                 Point              *m_points;
                 int                    m_size;
 //ÿ����������Ӧ�ļ�����,����ĳ��ȵ���m_size
                 float               *m_angles;
//��ż�����������飬����<=m_size
                 std::vector<Point   *>         m_results;
          private:
                 RotateJam(RotateJam  &);
          public:
//�������ݣ���������ļ��ϣ�����
//@request:size>=3,�Ҳ�Ҫ���ظ��Ķ�������
                  RotateJam(Point     *points,int   size);
                  ~RotateJam();
//Ԥ����                  
                  void             preprocess();
//�����
                  void             resolve();
//��ȡ��������������������ĳ��������,���һὫ��������ǳ���д������Ĳ�����
                  void             result(Point       *point,int     *size);
   };
  #endif
  