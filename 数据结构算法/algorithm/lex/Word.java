/*
  *�ʷ���Ԫ
  *2016-1-7 16:41:57
  */
  public     class     Word   extends    Token
 {
              public        final   String       property;
//�ʷ�����
              public         static     final      Word     index=new     Word("id",Tag.INDEX);
              public       Word(String   _property,int  _id)
             {
                           super(_id);
                           this.property=_property;
              }
              
              public       String    toString()
             {
                           return        property;
              }
  }