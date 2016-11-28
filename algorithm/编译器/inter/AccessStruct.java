/*
  *@aim:���ʽṹ��,�����õ���ʽ,
  *@date:2015-10-28 18:42:50
  *@author:�ҽ���
  */
  package    inter;
  import     lexer.Struct;
  import     lexer.Type;
  import     lexer.Pointer;
  import     lexer.Member;
  import     lexer.Word;
 //
  public       class        AccessStruct    extends    Expr
 {
//ע����ʽṹ�������ַ�ʽ,��һ��ָ�����,����ǵ�ŷ���
//���ַ��ʵ����ȼ�����ͬ��,�������
 //�ṹ������������������е�
               private      Expr              id;
//���ʵĳ�Ա�����ƫ�Ƽ���,���������ķ�������
               private      Expr              index;
//_type:Ҫ���ʵ�����,
//               private      Type              type;
//_structĿ��ṹ��
//_index:����Ҫ���ʵĽ��ݵ���Ե�ַ����,_index���һ����һ����������,����Ҫ����
               public       AccessStruct(Expr    _id,Expr   _index,Type   _type)
              {
                                 super(Word.access_struct,_type);
//�����ж�,_id����Ϊһ���ṹ�����,����Ϊһ��ָ��ṹ���ָ��
                                if(! (_id.type   instanceof   Struct))
                                               error("syntax error:"+_id+" must be struct type,but gived is "+_id.type);
//���ʳ�Ա��·��
                                 if(!( _index.type==Type.Int))
                                               error("syntax error:access struct member must be through integer   constant,but gived "+_index);
                                 this.id=_id;
                                 this.index=_index;
               }
//�����Ҳ����
               public     Expr       gen()
              {
//����ṹ����ָ�����ɵ�
                                if(  id   instanceof    Value )
                                             return     new     AccessStructByPointer(((Value)id).expr,index.reduce(),type);

                                id=id.reduce();
                                index=index.reduce();
                                return  this;
               }
//��ԼΪ��һ�ı���
               public           Expr                reduce()
              {
                               Expr   _expr=this.gen();
                               Temp    t=new     Temp(this.type);
//�����ʶ����һ���ṹ�����
                               emit(t.type+"\t\t"+t+"="+_expr);
                               return        t;
              }
              public        String     toString()
             {
                             return     id+"["+index+"]";
              }
  }