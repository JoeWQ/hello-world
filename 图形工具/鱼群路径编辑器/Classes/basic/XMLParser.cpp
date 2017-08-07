#include "XMLParser.h"
#include "extensions/cocos-ext.h"
#include "external/tinyxml2/tinyxml2.h"
namespace custom{
	XMLParser::XMLParser()
		:size(0)
	{

	}

	XMLParser::~XMLParser()
	{
		
	}

	bool XMLParser::init()
	{
		return true;
	}
	//解析一个Element
	ValueMap parseElement(tinyxml2::XMLElement *el)
	{
		const char* name = el->Name();
		const char* value = el->Value();
		ValueMap vac;
		const tinyxml2::XMLAttribute *atr = el->FirstAttribute();
		while (atr)
		{
			const char* name = atr->Name();
			const char* value = atr->Value();
			std::string ap(name);
			vac[ap] = value;
			atr = atr->Next();
		}

		tinyxml2::XMLElement *child = el->FirstChildElement();
		int childNum = 0;
		std::string lastName = "";
		ValueVector tMap;
		while (child)
		{
			const char* name = child->Name();
			std::string nName(name);
			if (lastName != nName)
			{
				if (lastName != "")
				{
					int size = tMap.size();
					if (size > 0)
					{
						if (size == 1)
						{
							vac[lastName] = tMap[0];
						}
						else
						{
							vac[lastName] = tMap;
						}

					}
				}
				childNum = 0;
				lastName = nName;
				tMap.clear();
			}
			ValueMap cm = parseElement(child);
			tMap.push_back(Value(cm));
			child = child->NextSiblingElement();
			childNum++;
		}
		int size = tMap.size();
		if (size > 0)
		{
			if (size == 1)
			{
				vac[lastName] = tMap[0];
			}
			else
			{
				vac[lastName] = tMap;
			}
			
		}
		return vac;
	}

	ValueMap XMLParser::parseXML(const std::string &filename, std::string index /* = "" */)
	{
		std::string filepath = FileUtils::getInstance()->fullPathForFilename(filename);
		tinyxml2::XMLDocument pDoc;
		int errorId = -1;
		ssize_t len = 0;

		ValueMap vac;

		char *pBuffer = (char *)FileUtils::getInstance()->getFileData(filename, "rb", &len);
		if (pBuffer != NULL && len != 0)
		{
			errorId = pDoc.Parse(pBuffer, len);
		}
		if (errorId == 10 || errorId == -1)
		{
			CCLOG("Parser xml failed: %d,%s", errorId, filename.c_str());
			CC_SAFE_DELETE_ARRAY(pBuffer);
			return vac;
		}

		tinyxml2::XMLElement *root = pDoc.FirstChildElement();
		
		std::string lastName = "";//正在解析的名字
		int tNum = 0;

		ValueVector tMap;//将所有名字一样的，放到同一个里面
		while (root)
		{
			const char* rname = root->Name();
			std::string strName(rname);

			if (strName != lastName)
			{
				tNum = 0;
				if (lastName != "")
				{
					int size = tMap.size();
					if (size > 0)
					{
						if (size == 1)
						{
							vac[lastName] = tMap[0];
						}
						else
						{
							vac[lastName] = tMap;
						}

					}
				}
				tMap.clear();
				lastName = strName;
			}
			ValueMap eVac = parseElement(root);
			tMap.push_back(Value(eVac));
			root = root->NextSiblingElement();
			tNum++;
		}
		int size = tMap.size();
		if (size > 0)
		{
			if (size == 1)
			{
				vac[lastName] = tMap[0];
			}
			else{
				vac[lastName] = tMap;
			}
		}
		return vac;
	}

	void XMLParser::updateArmatureGLProgram(Armature *arm, GLProgram *prm)
	{
		for (auto & object : arm->getBoneDic())
		{
			if (cocostudio::Bone *bone = dynamic_cast<cocostudio::Bone *>(object.second))
			{

				const cocos2d::Vector<cocostudio::DecorativeDisplay*>& list = bone->getDisplayManager()->getDecorativeDisplayList();
				for (auto & display : list)
				{
					Node *node = display->getDisplay();

					node->setGLProgram(prm);
				}
			}
		}
	}
}
