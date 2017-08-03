#pragma once
#ifndef __XMLPARSER_H__
#define __XMLPARSER_H__
#include "cocos2d.h"
#include "cocos/editor-support/cocostudio/CocoStudio.h"

USING_NS_CC;
using namespace cocostudio;
namespace custom{
	class XMLParser : public Ref
	{
	public:
		XMLParser();
		~XMLParser();

		bool init();
		CREATE_FUNC(XMLParser);
		ValueMap parseXML(const std::string &filename, std::string index = "");
		static void updateArmatureGLProgram(Armature *arm, GLProgram *prm);
	private:
		int size;
	};
}
#endif

