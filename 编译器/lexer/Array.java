/*
  *@aim:��������
  *@date:2015/10/6
  */
  package    lexer;
  public     class     Array   extends   Type
 {
//������Ԫ�ص���Ŀ
              public     final       int        size;
//����������ŵ�Ԫ�ص����ͣ�ע������Ϳ���ΪArray����,Ҳ���ǵݹ�����
              public     final       Type     type;
//_size:������Ԫ�ص���Ŀ
              public     Array(int   _size,Type   _type)
             {
//����Ķ�������Ϊ������Ԫ�صĶ�������
                           super("[]",Tag.INDEX,_size*_type.width,_type.alignWidth);
                           this.size=_size;
                           this.type=_type;
              }
              public     String      toString()
             {
                           return      type+"["+this.size+"]";
              }
//ͨ�ú���,���ں���������������ָ�븳ֵ��ʱ��,�ж������Ƿ��Ǽ��ݵ�
//�����ĺ�������������
//�������ǵļ���,�κ�һ���ǻ�������,��ȫ����ֻ���и��������,�����жϹ��̾Ϳ��Լ���ؼ���
             public      static      boolean       isCompatible(Array     left_value,Array     right_value)
            {
//����������������װ�صĶ���
 //                          Type      lp,rp;
//�ж�װ�ص������Ƿ�һ��
                           return        left_value.type==right_value.type;
             }
  }