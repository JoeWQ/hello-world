/*
  *@aim:�������,���ɵݹ��½��﷨������
  *@date:2015-10-07 12:36:40
  */
  package    inter;
  import     lexer.Type;
  
  public    class    Seq   extends    Stamt
 {
//�������
               private       Stamt     stamt1;
               private       Stamt     stamt2;
//
               public    Seq(Stamt   _stamt1,Stamt    _stamt2)
              {
                          this.stamt1=_stamt1;
                          this.stamt2=_stamt2;
               }
//��������ַ����
               public     void      gen(int   _after,int   _before)
              {
                           if(stamt1!=Stamt.Null && stamt2!=Stamt.Null)
                          {
                                       int     label=new_label();
                                       stamt1.gen(label,_before);
                                       emit_label(label);
                                       stamt2.gen(_after,label);
                           }
                           else if(stamt1 != Stamt.Null)
                                       stamt1.gen(_after,_before);
                           else if(stamt2 != Stamt.Null)
                                       stamt2.gen(_after,_before);
//�����ǿ����ʲôҲ������
               }
  }