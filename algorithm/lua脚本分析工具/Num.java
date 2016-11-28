/*
  *整数单元
  *2016-1-7 16:44:14
  */
   public     class      Num     extends     Token
  {
               public      final       int     value;
               public      Num(int   _value)
              {
                           super(Token.NUM);
                           this.value=_value;
               }
               public      String    toString()
              {
                           return     ""+value;
               }
   }