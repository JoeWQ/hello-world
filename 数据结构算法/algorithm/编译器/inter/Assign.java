/*
  *@aim:��ֵ���
  *@date:2015-10-07 11:32:08
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Word;
  import      lexer.Type;
  import      java.util.HashMap;
  public      class     Assign     extends     Expr
 {
//��ʶ��
              private      Expr           id;
              private      Expr          expr;
              
              public       Assign(Expr   _id,Expr    _expr)
             {
                           super(Word.assign,_expr.type);
                           this.id=_id;
                           this.expr=_expr;
//���ʽ���
                           if( !(_id  instanceof  Id) && !(_id instanceof  Value)  )
                                        error("assign  object must be  Id  or  AccessStruct,but gived is "+_id);
//���ͼ��
                           if( !this.check(_id.type,_expr.type))
                                       error("syntax error:no compatible  type to assign,want type '"+id.type+"',but gived is '"+_expr.type+"' ");
              }
//���ͼ��
             private        boolean     check(Type   p1,Type  p2)
            {
                          Integer       ap=Type.priority.get(p1);
                          Integer       bp=Type.priority.get(p2);
                          boolean     match=false;
                          if(ap!=null && bp!=null)
                         {
                                      int    aValue=ap.intValue();
                                      int    bValue=bp.intValue();
                                      match=(aValue>0 && bValue>0 && aValue>=bValue)||( aValue==0 && bValue==0);
                          }
//������뾫ȷ��ƥ��
                          if( !match   )
                                     match=p1.equalWith(p2);
                          return   match;
             }
//��������ַ����
              public    Expr     gen()
             {
//����ұ���һ����ֵ���,��Ҫ���⴦��
                           Expr    x=null;
                         //  System.out.println("Assign Object:"+expr);
                           if( (expr  instanceof   Assign) || (expr instanceof  AssignArray) || (expr instanceof   AssignStruct))  
                                       x=expr.reduce();
                           else
                                       x=expr.gen();
                           emit(id.gen()+"="+x.toString());
                           return   x;
              }
//����ֵ�����ԼΪ��һ�ı���,����������ھ��и����õı��ʽ�лᱻʹ��
//ע��reduce��gen�����Ĳ�֮ͬ��,�����Ϊ���ʽ��һ����,��������ͻᱻ����
              public     Expr      reduce()
             {
//�������ı��ʽ��ͬ,��ֵ���ʽ�Ǿ��и����õ�,�����Ϊһ�����ʽ��һ����,��ֵ�Ľ��Ҳ���Բ�������
                          Expr      x=expr.reduce();
                          emit(id.gen()+"="+x);
                          return   x;
              }
//���س�������п���,ע����Ϊ��ֵ������и�����,��������������ʵ����һЩ����
              public     Expr      recduceConstant()
             {
                          return   this;
              }
              public    String    toString()
             {
                           return     id+" = "+expr.toString();
              }
  }