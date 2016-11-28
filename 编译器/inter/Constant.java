/*
  *@aim:�������ʽ����,��������/����������
  *@date:2015/10/6
  */
  package    inter;
  import    lexer.Word;
  import    lexer.Type;
  import    lexer.Token;
  import    lexer.Float;
  import    lexer.Num;
  import    lexer.Char;
  import    lexer.CString;
  import    lexer.Pointer;
 //����,��������,�ַ���,��������,�ַ�������
  public      class       Constant   extends    Expr
 {
//����������
               public     Constant(float    value)
              {
                           super(new    Float(value),Type.Float);
               }
//����
               public    Constant(int    value)
              {
                           super(new    Num(value),Type.Int);
               }
//�ַ�����
               public     Constant(char   value)
              {
                           super(new   Char(value),Type.Char);
               }
//�ַ�������
               public     Constant(String    _string )
              {
                          super(new   CString(_string),Pointer.CharPointer);
               }
               public    Constant(Token  tok,Type type)
              {
                           super(tok,type);
               }
               public     void     jumping(int   tport,int   fport)
              {
//���µ����ʵ���Ͼ���Expr jumping�����ļ�,ȥ���˲���ָ��,��ʵ�ʵ���������޹�
//����do while���,��if/while����п϶����ᷢ����ת
                           if(this==Constant.True  && tport!=0)
                                       emit("jmp    L"+tport);
//����if /while���
                           else if(this==Constant.False && fport!=0)
                                       emit("jmp   L"+fport);
               }
//������������
               public     static    final      Constant     True=new    Constant(Word._true,Type.Bool);
               public     static    final      Constant     False=new    Constant(Word._false,Type.Bool);
  }