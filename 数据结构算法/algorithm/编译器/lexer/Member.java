/*
  *@aim:�ṹ��ĳ�Ա����
  *@date:2015��10��27��16:52:34
  *@author:
  */
  package     lexer;
  
  public      class     Member
 {
//��Ա����
              public     final       String      name;
//��Ա������,��Ա�Ķ�������������Type�ֶ���
              public     final       Type        type;
//��Ա�ڽṹ���ڲ���ƫ��
              public     final       int          offset;
//��Ա�ڽṹ���е�˳��,��0��ʼ����
              public     final       int          seq;
//
              public     Member(String   _name,Type   _type,int   _offset,int    _seq)
             {
                              this.name=  _name;
                              this.type  =  _type;
                              this.offset=  _offset;
                              this.seq   =  _seq;
              }
  }