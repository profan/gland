module gl;

import glad.gl.enums;
import glad.gl.types;
import glad.gl.funcs;

/**
 * Misc Types
*/

alias GLColour = float[4];

/**
 * Public Helper Functions
*/

/**
 * Converts an integer representing a colour, for example 0x428bca into a 4 element
 * int array for passing to OpenGL.
*/

nothrow @nogc pure
GLfloat[4] to(T : GLfloat[4])(int colour, ubyte alpha = 255) {

	GLfloat[4] gl_colour = [ //mask out r, g, b components from int
		cast(float)cast(ubyte)(colour>>16)/255,
		cast(float)cast(ubyte)(colour>>8)/255,
		cast(float)cast(ubyte)(colour)/255,
		cast(float)cast(ubyte)(alpha)/255
	];

	return gl_colour;

} //to!GLfloat[4]

/**
 * Converts a GLenum representation of a value to a c string representation,
 * for use with debug printing of OpenGL info, from debug callbacks for example.
*/
const (char*) to(T : char*)(GLenum value) {

    switch (value) {

        // sources
        case GL_DEBUG_SOURCE_API: return "API";
        case GL_DEBUG_SOURCE_WINDOW_SYSTEM: return "Window System";
        case GL_DEBUG_SOURCE_SHADER_COMPILER: return "Shader Compiler";
        case GL_DEBUG_SOURCE_THIRD_PARTY: return "Third Party";
        case GL_DEBUG_SOURCE_APPLICATION: return "Application";
        case GL_DEBUG_SOURCE_OTHER: return "Other";

        // error types
        case GL_DEBUG_TYPE_ERROR: return "Error";
        case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: return "Deprecated Behaviour";
        case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: return "Undefined Behaviour";
        case GL_DEBUG_TYPE_PORTABILITY: return "Portability";
        case GL_DEBUG_TYPE_PERFORMANCE: return "Performance";
        case GL_DEBUG_TYPE_MARKER: return "Marker";
        case GL_DEBUG_TYPE_PUSH_GROUP: return "Push Group";
        case GL_DEBUG_TYPE_POP_GROUP: return "Pop Group";
        case GL_DEBUG_TYPE_OTHER: return "Other";

        // severity markers
        case GL_DEBUG_SEVERITY_HIGH: return "High";
        case GL_DEBUG_SEVERITY_MEDIUM: return "Medium";
        case GL_DEBUG_SEVERITY_LOW: return "Low";
        case GL_DEBUG_SEVERITY_NOTIFICATION: return "Notification";

        default: return "(undefined)";

    }

} //to!(const (char*))(GLenum)

/**
 * UDA's for defining stuff in vertex structures.
*/

struct VertexAttribDivisor_ {

	GLuint divisor;

} // VertexAttribDivisor

@property vertexAttribDivisor(GLuint divisor) {
	return VertexAttribDivisor_(divisor);
} // vertexAttribDivisor

// attribute normalization in structures
struct Normalized_ {

	bool is_normalized;

} // Normalized

@property normalized(bool normalized) {
	return Normalized_(normalized);
} // normalized

template TypeToGL(T) {

	import std.format : format;

	static if (is (T == float)) {
		enum TypeToGL = GL_FLOAT;
	} else static if (is (T == double)) {
		enum TypeToGL = GL_DOUBLE;
	} else static if (is (T == int)) {
		enum TypeToGL = GL_INT;
	} else static if (is (T == uint)) {
		enum TypeToGL = GL_UNSIGNED_INT;
	} else static if (is (T == short)) {
		enum TypeToGL = GL_SHORT;
	} else static if (is (T == ushort)) {
		enum TypeToGL = GL_UNSIGNED_SHORT;
	} else static if (is (T == byte)) {
		enum TypeToGL = GL_BYTE;
	} else static if (is (T == ubyte) || is(T == void)) {
		enum TypeToGL = GL_UNSIGNED_BYTE;
	} else {
		static assert (0, format("No type conversion found for: %s to OpenGL equivalent", T.stringof));
	}

} // TypeToGL

// corresponds to targets to which OpenGL buffer objects are bound
enum BufferTarget {

	ArrayBuffer = GL_ARRAY_BUFFER,
	CopyReadBuffer = GL_COPY_READ_BUFFER,
	CopyWriteBuffer = GL_COPY_WRITE_BUFFER,
	ElementArrayBuffer = GL_ELEMENT_ARRAY_BUFFER,
	PixelPackBuffer = GL_PIXEL_PACK_BUFFER,
	PixelUnpackBuffer = GL_PIXEL_UNPACK_BUFFER,
	TextureBuffer = GL_TEXTURE_BUFFER,
	TransformFeedbackBuffer = GL_TRANSFORM_FEEDBACK_BUFFER,
	UniformBuffer = GL_UNIFORM_BUFFER

} // BufferTarget

enum ShaderType {

	VertexShader = GL_VERTEX_SHADER,
	FragmentShader = GL_FRAGMENT_SHADER,
	GeometryShader = GL_GEOMETRY_SHADER

} // ShaderType

// corresponds to usage pattern for given data
enum DrawHint {

	StaticDraw = GL_STATIC_DRAW,
	StaticRead = GL_STATIC_READ,

	DynamicDraw = GL_DYNAMIC_DRAW,
	DynamicRead = GL_DYNAMIC_READ,

	StreamDraw = GL_STREAM_DRAW,
	StreamRead = GL_STREAM_READ

} // DrawHint

// corresponds to OpenGL primitives
enum DrawPrimitive {

	Points = GL_POINTS,

	Lines = GL_LINES,
	LineStrip = GL_LINE_STRIP,
	LineLoop = GL_LINE_LOOP,

	Triangles = GL_TRIANGLES,
	TriangleStrip = GL_TRIANGLE_STRIP,
	TriangleFan = GL_TRIANGLE_FAN

} // DrawPrimitive

// corresponds to glBlendEquation
enum BlendEquation {

	Add = GL_FUNC_ADD,
	Subtract = GL_FUNC_SUBTRACT,
	ReverseSubtract = GL_FUNC_REVERSE_SUBTRACT,
	Min = GL_MIN,
	Max = GL_MAX

} // BlendEquation

// corresponds to glBlendFunc
enum BlendFunc {

	Zero = GL_ZERO,
	One = GL_ONE,

	SrcColour = GL_SRC_COLOR,
	OneMinusSrcColour = GL_ONE_MINUS_SRC_COLOR,

	DstColour = GL_DST_COLOR,
	OneMinusDstColour = GL_ONE_MINUS_DST_COLOR,

	SrcAlpha = GL_SRC_ALPHA,
	OneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA,

	DstAlpha = GL_DST_ALPHA,
	OneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA,

	ConstantColour = GL_CONSTANT_COLOR,
	OneMinusConstantColour = GL_ONE_MINUS_CONSTANT_COLOR,

	ConstantAlpha = GL_CONSTANT_ALPHA,
	OneMinusConstantAlpha = GL_ONE_MINUS_CONSTANT_ALPHA

} // BlendFunc

// DrawParams state, is sent with every "draw" command in order to *never* have any manual state modification.
struct DrawParams {

	BlendFunc blend_src, blend_dst;
	BlendEquation blend_eq;

} // DrawParams

/**
 * Possible alternative to DrawParams, would be template on what would be passed 
 *  and then we could only pass what would be necssary for the given call, 
 *  reducing overhead both in memory and run-time checking.
*/
struct TDrawParams {

} // TDrawParams

struct Shader(ShaderType[] shaders, Uniforms...) {

} // Shader

struct Vertex {

} // Vertex

struct VertexArray(VT) {

	private {

		GLuint id;

	}

	@property
	ref GLuint handle() {
		return id;
	} // handle

} // VertexArray

struct VertexBuffer(VT) {

	private {

		GLuint id;

		uint num_vertices;
		DrawPrimitive prim_type;

	}

	@property
	ref GLuint handle() {
		return id;
	} // handle

} // VertexBuffer

/**
 * UFCS functions for drawing, uploading data, etc.
*/

nothrow @nogc
auto allocate(VertexType)(in VertexType[] vertices, DrawHint draw_hint, DrawPrimitive prim_type = DrawPrimitive.Triangles) {

	VertexArray!VertexType vao;
	VertexBuffer!VertexType vbo;

	vao.num_vertices = cast(uint)vertices.length;
	vao.prim_type = prim_type;

	glGenVertexArrays(1, &vao.handle);
	vao.bindVertexArray();

	glGenBuffers(1, vao.handle);

} // allocate

nothrow @nogc
void draw(VertexType)(ref VertexArray!VertexType vao, DrawParams params) {

} // draw

/* Functions for creating structures and such. */

struct Renderer {
static:

	/**
	 * data bindings
	*/

	//GL_ARRAY_BUFFER_BINDING
	GLuint array_buffer_binding;

	//GL_ELEMENT_ARRAY_BUFFER_BINDING
	GLuint element_array_buffer_binding;

	//GL_VERTEX_ARRAY_BUFFER_BINDING
	GLuint vertex_array_buffer_binding;

	//GL_UNIFORM_BUFFER
	GLuint uniform_buffer_binding;

	//GL_TEXTURE_BINDING_2D
	GLuint texture_binding_2d;

	/**
	 * misc state
	*/

	//GL_TEXTURE_2D
	bool texture_2d;

	//GL_SCISSOR_TEST
	bool scissor_test;

	//GL_SCISSOR_BOX
	GLint[4] scissor_box;

	//GL_ALPHA_TEST
	bool alpha_test;

	//GL_ALPHA_TEST_FUNC
	GLenum alpha_test_func;

	//GL_STENCIL_TEST
	bool stencil_test;

	//GL_STENCIL_FUNC
	GLenum stencil_test_func;

	//GL_DEPTH_TEST
	bool depth_test;

	//GL_DEPTH_FUNC
	GLenum depth_test_func;

	//GL_BLEND
	bool blend_test;

	//GL_BLEND_SRC
	GLenum blend_src;

	//GL_BLEND_DST
	GLenum blend_dst;

	/**
	 * Framebuffer Control
	*/

	//GL_DRAW_BUFFER
	//TODO: ...

	/**
	 * Functions, this is the public API
	*/

	void clearColour(GLint rgb) {

		auto colour = to!GLColour(rgb);
		glClearColor(colour[0], colour[1], colour[2], colour[3]);
		glClear(GL_COLOR_BUFFER_BIT);

	} // clearColour

	void clearColour(GLubyte r, GLubyte g, GLubyte b, GLubyte a = 255) {

		glClearColor(r, g, b, a);
		glClear(GL_COLOR_BUFFER_BIT);

	} // clearColour

	/**
	 * Internal Helpers, not public API.
	*/

private:

	bool isBound(alias name)() {

		return name != 0;

	} // isBound

	bool isAnyBound(BufferTarget type) {

		import std.stdio : writefln;

		bool result = false;

		final switch (type) with (BufferTarget) {

			case ArrayBuffer,
				 CopyReadBuffer,
				 CopyWriteBuffer,
				 PixelPackBuffer,
				 PixelUnpackBuffer:
				result = isBound!array_buffer_binding();
				break;

			case ElementArrayBuffer:
				result = isBound!element_array_buffer_binding();
				break;

			case TextureBuffer:
				result = isBound!texture_binding_2d();
				break;

			case TransformFeedbackBuffer:
				break;

			case UniformBuffer:
				break;

		}

		if (!result) {
			writefln("gland: tried checking if non-existent buffer type bound: %d", type);
		}

		return result;

	} // isAnyBound

	bool bindVertexArray(VertexType)(ref VertexArray!VertexType vao) {

		if (vertex_array_buffer_binding == vao.handle) {
			return false;
		}
			
		glBindVertexArray(vao.handle);

		return true;

	} // bindVertexArray

	bool bindBuffer(BufferTarget type, GLuint id) {

		import std.stdio : writefln;

		switch (type) with (BufferTarget) {

			case ArrayBuffer: {

				if (array_buffer_binding == id) {
					return false;
				}
				
				array_buffer_binding = id;
				break;

			}

			case ElementArrayBuffer: {

				if (element_array_buffer_binding == id) {
					return false;
				}

				element_array_buffer_binding = id;
				break;

			}

			default: {
				writefln("gland: tried to bindBuffer with unknown type: %s", type);
				return false;
			}

		}

		glBindBuffer(type, id);

		return true;

	} // bindBuffer

	bool bufferData(BufferTarget target, GLsizeiptr size, const GLvoid* data, DrawHint usage) {

		if (!isAnyBound(target)) {
			return false;
		}

		return true;

	} // bufferData

} // Renderer
