/*
  *@aim:ָ��ӷ�
  *@date:2015-10-28 17:15:56
  *@author:�ҽ���
  */
  package    inter;
  import     lexer.Type;
  import     lexer.Pointer;
  import     lexer.Struct;
  import     lexer.Num;
  import     lexer.Char;
  import     lexer.Token;
  import     lexer.Word;
  import     lexer.Array;
//
  public        class     PointerAdd    extends    Expr
 {
//ָ��ӷ��������ӱ��ʽ
               protected       Expr         left;
                protected      Expr         right;
//
               public     PointerAdd(Expr   _left,Expr   _right)
              {
                              super(Word.add,Type.Int);
//�Ա��ʽ���,����leftΪָ������rightΪ��������,���߷�����,����Ҫ����
                             boolean       match=false;
                             left=_left;
                             right=_right;
                             if(_left.type==Type.Int || _left.type==Type.Char)
                            {
                                            match=(_right.type instanceof Pointer)||(_right.type instanceof Array);
                                            left=_right;
                                            right=_left;
                             }
                             else if(_right.type==Type.Int || _right.type==Type.Char)
                                            match=(_left.type instanceof Pointer)||(_left.type instanceof Array);
                             if(!match)
                                        error("syntax error:pointer type usage error,cannot apply pointer operator to type '"+_left.type+"'  and  '"+"' "+_right.type);
                            this.left=_left;
                            this.right=_right;
//�ı�����
                             this.type=left.type;
               }
//�����Ҳ����,����һ����ʱָ������
               public      Expr      gen()
              {
//�����µı��ʽ
                          left=left.reduce();
                          right=right.reduce();
                          return   this;
               }
//��������ַ����,������ʱ���Ż�,������һ���汾
               public      Expr        reduce()
              {
                           this.gen();
                           Temp    t=new    Temp(left.type);
                           int             offset=0;
                           int             width=0;
//��������ָ�� 
                           if( left.type  instanceof  Pointer)
                                       width=((Pointer)left.type).type.width;
                           else
                                       width=((Array)left.type).type.width;
//��Ҫ���ǻ���һ�γ˷�
                          if( right  instanceof   Constant  )
                         {
                                          Constant     n=(Constant)right;
                                          if(right.type  == Type.Int)
                                                    offset=((Num)n.tok).value;
                                          else
                                                    offset=((Char)n.tok).value;
                                          emit(t+"="+left+"+"+offset*width);
                          }
                          else
                         {
                                         Temp    m=new   Temp(Type.Int);
                                         emit(m+"="+width+"*"+right);
                                         emit(t+"="+left+"+"+m);
                          }
                           return     t;
               }
//�����ĺ�����
               public      String    toString()
              {
                            return     left+"+"+right+"*"+left.type.width;
               }
  }