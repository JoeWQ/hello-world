/*
  *@aim:ָ������
  *@date:2015-10-24 18:57:28
  *@author:�ҽ���
  */
  package      lexer;
  public    class    Pointer   extends    Type
 {
//�̶�����,�ַ���ָ��
              public     static     final     Pointer     CharPointer=new     Pointer(Type.Char);
//ָ����ָ�������
              public     final       Type      type;
//
              public      Pointer(Type     _type)
             {
//�ʷ���Ԫ ��ָ�����������+*,��������4,��ռ�ݵĿռ�4
                           super(_type+"*",Tag.POINTER,4,4);
                           this.type=_type;
              }
//�ж������Ƿ�ȼ�,�������ǵļ���,ÿ��������ȫ����ֻ��һ������
              public   static       boolean      compare_pointer(Pointer   p,Pointer   q)
             {
                           return     p==q;
              }
//
              public     String      toString()
             {
                           return     type+"*";
              }
  }