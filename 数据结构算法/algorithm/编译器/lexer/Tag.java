/*
  *@instruction:�ʷ���Ԫ����ö��
  */
  
    package    lexer;
    
    public    class   Tag
   {
//�ļ�������־
              public    static    final     int     EOF=0;
//����
              public    static    final      int    BASIC=256;//��������
//��ʶ��,����Ϊ������Ҳ������Ϊ������
              public    static    final      int    ID=257;
//���������
              public    static    final      int    AND=258;//&&
              public    static    final      int    OR=259;// ||
              public    static    final      int    NOT=260;// !,�����������������ͬ����������޶�����
              public    static    final      int    EQUAL=261;//==
              public    static    final      int    NE=262;//!=
              public    static    final      int    GE=263;//>=
              public    static    final      int    LE=264;//<=
              public    static    final      int    INDEX=265;//��������
//����������ʵ���в���ʹ��
              public    static    final      int    NEG=266;//ȡ��
              public    static    final      int    POV=267;//ȡ��
//��λ
              public    static    final      int    SHIFT_LEFT=268;//����
              public    static    final      int    SHIFT_RIGHT=269;//����
//ָ����ʽṹ������
              public    static    final      int    ACCESS_STRUCT=270;
//              public    static    final      int    DOT;
//���
              public    static    final      int    IF=274;//
              public    static    final      int    ELSE=275;
              public    static    final      int    WHILE=276;
              public    static    final      int    DO=277;
              public    static    final      int    BREAK=278;
              public    static    final      int    CONTINUE=279;
//�м����,��ʱ����
              public    static    final      int    TEMP=280;
//����
              public    static    final      int    TRUE=281;//true
              public    static    final      int    FALSE=282;//false
              public    static    final      int    NUM=283;//����
              public    static    final      int    FLOAT=284;//����
//�ַ�����
              public    static    final      int    CHAR=285;
//��������ĺ�����������
              public    static    final      int    VOID=286;
//��������
              public    static    final      int     FUNC=287;
//�������
              public    static    final      int     RETURN=288;
//ǿ������ת��
              public    static    final      int      CAST=289;
// ��������
              public    static    final      int      ARRAY=290;
//���ʽṹ��
              
//�ṹ������
              public    static    final      int      STRUCT=291;
//ָ������,��ָ
              public    static    final      int      POINTER=292;
//�ַ�������
              public    static   final       int      STRING=294;
//����ָ��
              public    static   final       int      FUNC_POINTER=295;
    }