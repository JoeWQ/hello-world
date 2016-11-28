#ifndef _Scanner_H_
#define _Scanner_H_

#include <string>
#include <fstream>
#include <deque>
#include <set>

using namespace std;

class Scanner
{
private:
    enum State	// ת��ͼ�е�״̬
    {
        START_STATE,		// ��ʼ״̬
        ID_STATE,			// ��ʶ��״̬
        INT_STATE,			// ������״̬
        CHAR_STATE,			// �ַ�״̬		
        CHAR_STATE_A,
        CHAR_STATE_B,
        CHAR_STATE_C,
        FLOAT_STATE,		// ������״̬
        D_FLOAT_STATE,		// �ӽ���С����ĸ�����״̬
        E_FLOAT_STATE,		// �ӽ���ѧ�������ĸ�����״̬
        STRING_STATE,		// �ַ���״̬
        S_STRING_STATE,		// ����ת���ַ����ַ���
        SYMBOL_STATE, 
        INCOMMENT_STATE,	// ע��״̬
        P_INCOMMENT_STATE,	// ��Ҫ����ע��״̬
        DONE_STATE,			// ����״̬
        ERROR_STATE			// ����״̬
    };

public:
    set<string> keyWords;
    set<string> symbols;
    enum TokenType
    {      
        KEY_WORD,
        ID,				// ��ʶ��
        INT,			// ��������
        BOOL,			// ��������
        CHAR,			// �ַ�
        STRING,			// �ַ���
        SYMBOL,         // �Ϸ��ķ���
        NONE,		    // ������
        ERROR,		    // ����
        ENDOFFILE	    // �ļ�����
    };
    struct Token
    {
        TokenType kind;				// Token������
        string lexeme;				// Token��ֵ
        unsigned row;	   	        // ��ǰ��
    };
    void initKeyWords();
    void initSymbols();
private:
    string lineBuffer;					// ������, ����Դ�����е�һ������
    unsigned bufferPos;					// �����е�ָ��
    unsigned row;						// ���浱ǰ��������Դ�����е��к�
    ifstream fin;						// Դ�����ļ�������������
    char nextChar();					// ���ػ������е���һ���ַ�
    void rollBack();					// �ع�������
    TokenType searchReserved(string &s);	// ���ҹؼ���
public:
    Scanner();
    void openFile(string filename);
    void closeFile();
    Token nextToken();					// ������һ��Token
    void resetRow();
};

#endif
