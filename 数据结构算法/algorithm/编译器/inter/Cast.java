/*
  *@aim:ǿ������ת��
  *@date:2015-10-21 16:25:59
  *@author:�ҽ���
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Float;
  import      lexer.Num;
  import      lexer.Char;
  import      lexer.Word;
  import      java.util.HashMap;
  public    class     Cast     extends    Expr
 {
//Ŀ������
              public     final       Type      aType;
//��ת�������ͱ��ʽ
              public            Expr      expr;
//
              public    Cast(Type    _type,Expr     _expr)
             {
                            super(Word.cast,_type);
                            this.aType=_type;
                            this.expr=_expr;
//���ͼ��,����������ʱ������ָ������,�ṹ��ת��
                            Integer        a=Type.priority.get(_type);
                            Integer        b=Type.priority.get(_expr.type);
//����ǻ�������,ֻ�в������Ͳ�����ת�������Ķ�����
                            boolean     match=false;
                            if( a!=null && b!=null)
                           {
                                             int     aValue=a.intValue();
                                             int     bValue=b.intValue();
                                             match=aValue>0 && bValue>0;
                            }
                            else if( _type!=Type.Void && _expr.type != Type.Void  )
                                            match=(_type != Type.Bool && _expr.type != Type.Bool) ||(_type==Type.Bool && _expr.type == Type.Bool);
                                        
                            if( ! match )
                                          error("syntax error:type '"+_expr.type+" can not cast to type '"+_type+"'.");
              }
//��������ַ�����Ҳ�
              public      Expr                 gen()
             {
                            expr=expr.reduce();
                            Expr     _expr=this.gen_constant();
                             if(_expr !=expr  )
                                         return        _expr;
                            return  this;
              }
//��ԼΪ��һ����
              public      Expr                reduce()
             {
                             expr=expr.reduce();
                             Expr      _expr;
                             _expr=this.gen_constant();
                             if(_expr  !=expr )
                                      return   _expr;
                             Temp    t=new   Temp(aType);
                             emit(t+"="+_expr);
                             return   t;
              }
              private       Expr      gen_constant()
             {
                            Expr     _expr=expr;
                            if( _expr  instanceof     Constant   )
                            {
                                           if( aType==Type.Float  )
                                          {
                                                        if(_expr.type==Type.Int )
                                                                  _expr=new    Constant((int)((Num)_expr.tok).value);
                                                        else if(_expr.type==Type.Char)
                                                                  _expr=new    Constant((int)((Char)_expr.tok).value);
                                           }
                                           else if( aType == Type.Int )
                                          {
                                                         if(_expr.type==Type.Char) 
                                                                 _expr=new   Constant((int)((Char)_expr.tok).value);
                                                         else if(_expr.type==Type.Float)
                                                                 _expr=new   Constant((int)((Float)_expr.tok).value);
                                           }
                                           else if(aType == Type.Float)
                                          {
                                                        if(_expr.type==Type.Float)
                                                                _expr=new    Constant((char)((Float)_expr.tok).value);
                                                        else if(_expr.type==Type.Int)
                                                                _expr=new    Constant((char)((Num)_expr.tok).value);
                                           }
                             }
                             return    _expr;
              }
              public     String    toString()
             {
                             return    "("+aType+ ")"+expr;
              }
  }
  