/*
  *@aim:����������
  *@date:2015/10/6
  */
  package     inter;
  import       lexer.Token;
  import       lexer.Type;
  
  public     class    Op   extends    Expr
 {
//�������ı��ʽ�Ľ������������
              public     Op(Token   token,Type   type)
             {
                            super(token,type);
              }
//��������ַ����,��Լ�ɵ�һ����ʱ����
              public     Expr       reduce()
             {
                           Expr     x=this.gen();
                           if( !(x instanceof   Constant) )
                          {
                                   Temp    t=new    Temp(type);
                                   emit(t+"="+x);
                                   return    t;
                           }
                           return   x;
              }
  }