/*
  *@instruction:�����ʷ���Ԫ
  */
   package     lexer;
   
   public    class    Num   extends    Token
  {
             public     final     int     value;
             
             public    Num(int    _value)
            {
                         super(Tag.NUM);
                         this.value=_value;
             }
             public    String    toString()
            {
                         return   ""+this.value;
             }
   }