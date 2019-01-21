/*
  *公共函数,数据
  *@2017-8-4
  *@Author:xiaohuaxiong
 */

const char *_static_common_vertex_shader = "attribute vec4 a_position;"
"void main()"
"{"
"		gl_Position  = CC_MVPMatrix  * a_position;"
"}";

const char *_static_common_frag_shader = "uniform vec4 g_Color;"
"void main()"
"{"
"		gl_FragColor = g_Color;"
"}";

const char *_static_common_model_vertex_shader="attribute vec4 a_position;"
"uniform mat4 g_ModelMatrix;"
"void main()"
"{"
"		gl_Position  = CC_MVPMatrix * g_ModelMatrix * a_position;"
"}";

const char *_static_common_model_frag_shader = "uniform vec4 g_Color;"
"void main()"
"{"
"		gl_FragColor = g_Color;"
"}";