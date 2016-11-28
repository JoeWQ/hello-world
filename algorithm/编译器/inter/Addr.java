/*
  *@aim:ȡ��ַ�����
  *@date:2015-10-28 11:36:56
  *@author:�ҽ���
  *@date:2015-11-6 15:12:29
  *@aim:�����������������ָ�����������������ı��ʽ�������﷨����
  */
  package    inter;
  import    lexer.Type;
  import    lexer.Pointer;
  import    lexer.Word;
  public      class    Addr    extends    Op
 {
             public       Expr        expr;
             public       Addr(Expr     _expr)
            {
                            super(Word.addr,_expr.type);
//���ȡ��ַ�������Ŀ������,�����Ǳ�ʶ��,���߿������ɱ�ʶ���Ķ���
                           if( !(_expr   instanceof    Id)  && !( _expr instanceof Access) && !(_expr instanceof AccessStruct) && !(_expr instanceof AccessStructByPointer) && !(_expr  instanceof  Value))
                                        error("syntax error:'&' operator can only operate identifier or array or struct member  variable,but gived is :"+_expr);
                           this.expr=_expr;
                           this.type=new      Pointer(_expr.type);
             }
//�����Ҳ����
             public      Expr      gen()
            {
//���Ŀ����ȡ���ݱ��ʽ
 //                         System.out.println("Addr gen():"+expr);
                          if( expr  instanceof   Value)
                                     return    ((Value)expr).expr.gen();
                          else
                                    expr=expr.gen();
                          return   this;
             }
//��ԼΪ��һ�ı���
            public     Expr       reduce()
           {
//ע�����ǵ�Լ������,ÿһ�ֹ���������ȫ����ֻ����һ������
                         Temp       t=new     Temp(new    Pointer(expr.type));
                         Expr         _expr=null;
                         if(  expr   instanceof   Value )
                                         _expr=((Value)expr).expr.reduce();
                         else
                                        _expr=expr.reduce();
                         emit(t.type+"\t"+t+"="+_expr);
                         return    t;
            }
            public    String    toString()
           {
                         return     "&"+expr;
            }
  }