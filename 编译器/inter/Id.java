/*
  *@aim:��ʶ��
  *@date:2015/10/6
  */
  package    inter;
  import      lexer.Word;
  import      lexer.Type;
  public      class     Id    extends   Expr
 {
//ȫ�ֱ�ʾ,����������λ��
               public     static      final        int         StaticArea=0;//λ�ھ�̬��
//λ��ջ֡���������βε�����,Ҳ���Ƿ��ص�ַ������
               public     static      final        int         StackTop=1;
//λ��ջ֡������,���ջ֡��ʱ����
               public     static      final        int         StaticBottom=2;
 //offset:��Ե�ַ
 //��Ϊ�ʷ���Ԫ�Ĵ��غ�����
               public      final       int     offset;
               public      Id(Word   word,Type   type,int   _offset)
              {
                            super(word,type);
                            this.offset=_offset;
               }
  }