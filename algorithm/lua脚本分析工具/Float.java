/*
  *���㵥Ԫ
  */
  public     class      Float     extends     Token
 {
              public      final      float       value;
              public      Float(float    _value)
             {
                          super(Token.FLOAT);
                          this.value=_value;
              }
              public      String      toString()
             {
                          return   ""+value;
              }
  }