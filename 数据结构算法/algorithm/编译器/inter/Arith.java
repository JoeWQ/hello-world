/*
  *@aim:��ѧ˫Ŀ�����
  *@�������������ͬ,����ֻ�ṩ�����Ĵ������ɣ�����ʹ�ñ��������Ż�����,
  *@��ʹ�þ�����������
  *@date:2015/10/6
  */
  package    inter;
  import     lexer.Type;
  import     lexer.Word;
  import     lexer.Token;
  
  public    class    Arith    extends    Op
 {
 //�����ӱ��ʽ
            Expr        left_expr;
            Expr        right_expr;
 //
            public     Arith(Token   tok,Expr    _left,Expr   _right)
           {
                         super(tok,null);
                         this.left_expr=_left;
                         this.right_expr=_right;
//����Ƿ��ǿɽ�����ѧ���������
                         if( (this.type=Type.maxType(_left.type,_right.type))==null  )
                                     error("syntax error,Arith type is not match.want 'int' or 'char' ,but gived is: "+_left.type+" and "+_right.type);
//�Ա���ʱ������з���
            }
//�Ƿ���Թ�ԼΪ����,��������򷵻س������ʽ���򷵻�����,������Ҫ�����Ӻ���
            public          Expr           reduceConstant()
           {
                          return   this;
            }
//��������ַ����
            public     Expr       gen()
           {
                        return    new     Arith(this.tok,left_expr.reduce(),right_expr.reduce());//��Լ�ɼ򻯵��ӱ��ʽ
            }
            public     String     toString()
           {
                    //    throw   new   Error("invalide  operate");
                        return     left_expr.toString()+this.tok.toString()+right_expr.toString();
            }
  }