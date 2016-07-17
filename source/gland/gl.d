module gland.gl;

import core.stdc.stdio : printf;
import std.typecons : tuple, Tuple;

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

nothrow pure @nogc
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

nothrow pure @nogc
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

nothrow @nogc
bool checkShaderError(GLuint shader, GLuint flag, bool is_program) {

	GLint result;

	(is_program) ? glGetProgramiv(shader, flag, &result)
				: glGetShaderiv(shader, flag, &result);

	if (result == GL_FALSE) {

		GLchar[256] log; //FIXME this is potentially fatal
		(is_program) ? glGetProgramInfoLog(shader, log.sizeof, null, log.ptr)
			: glGetShaderInfoLog(shader, log.sizeof, null, log.ptr);

		printf("[OpenGL] Error %s\n", log.ptr);
		return false;

	}

	return true;

} // checkShaderError

nothrow @nogc
GLuint compileShader(const(GLchar*)* shader_source, ShaderType shader_type) {

	GLuint new_shader = glCreateShader(shader_type);
	if (new_shader == 0) { return 0; } // FAILED, TODO: return proper error

	glShaderSource(new_shader, 1, shader_source, null);
	glCompileShader(new_shader);

	bool result = checkShaderError(new_shader, GL_COMPILE_STATUS, false);

	if (!result) {
		glDeleteShader(new_shader);
		return 0;
	}

	return new_shader;

} // compileShader

GLuint createShaderProgram(in GLuint[] shader_ids, in AttribTuple[] attribs) {

	GLuint program = glCreateProgram();

	foreach(i, shader; shader_ids) {
		glAttachShader(program, shader);
	}

	foreach (ref attr; attribs) {
		glBindAttribLocation(program, attr.offset, attr.identifier.ptr);
	}

	glLinkProgram(program);
	if (!checkShaderError(program, GL_LINK_STATUS, true)) {
		glDeleteShader(program);
		return 0;
	}

	glValidateProgram(program);
	if (!checkShaderError(program, GL_VALIDATE_STATUS, true)) {
		glDeleteShader(program);
		return 0;
	}

	return program;

} //createShaderProgram

alias AttribTuple = Tuple!(string, "identifier", int, "offset");
alias ShaderTuple = Tuple!(ShaderType, "type", AttribTuple[], "attribs");
struct Shader(ShaderTuple[] shaders, Uniforms...) {

	import std.string : format;
	alias Bindings = Uniforms;

	GLuint program_;
	mixin(q{GLuint[%d] uniforms_;}.format(Uniforms.length / 2));

	/* example shader data
	GLuint program_;
	GLuint[1] uniforms_;
	*/

	@disable this(this);

	static string createFunction(ShaderTuple[] shaders) {

		import std.algorithm : map, joiner;
		import std.range : enumerate;
		import std.array : appender;

		auto buffer = appender!string();

		buffer ~= q{static Shader compile(%s) {
			%s
		}}.format(shaders.enumerate.map!(e => q{const (char*)* source_%d}.format(e.index)).joiner(","), createCompiler(shaders));

		return buffer.data();

	} // createFunction

	static string createCompiler(ShaderTuple[] shaders) {

		import std.algorithm : map, joiner;
		import std.range : enumerate;
		import std.array : appender;

		auto buffer = appender!string();

		buffer ~= q{
			Shader new_shader;};

		foreach (i, shader; shaders) {
		buffer ~= q{
			GLuint shader_%d = compileShader(source_%d, ShaderType.%s);}.format(i, i, shader.type);
		}

		buffer ~= q{
			GLuint[%d] shader_ids = [%s];}.format(shaders.length, map!(e => "shader_%d".format(e.index))(shaders.enumerate).joiner(","));

		// check uniforms
		buffer ~= q{
			new_shader.program_ = createShaderProgram(shader_ids, shaders[0].attribs);

			foreach (i, uniform; Uniforms) {

				// two for each iteration, type + string
				static if (i % 2 != 0) {
					continue;
				} else {
					GLint res = glGetUniformLocation(new_shader.program_, Uniforms[i+1].ptr);
					if (res == -1) {
						assert(0, "uniform fail");
					}
					new_shader.uniforms_[i/2] = res;
				}

			}
		};

		// linked into program now, delete for now.
		foreach (i, shader; shaders) {
			buffer ~= q{
			glDetachShader(new_shader.program_, shader_%d);}.format(i);
		}

		foreach (i, shader; shaders) {
			buffer ~= q{
			glDeleteShader(shader_%d);}.format(i);
		}

		buffer ~= q{
			return new_shader;
		};

		return buffer.data();

	} // createCompiler

	/* generator */
	mixin(createFunction(shaders));

	~this() {

		glDeleteProgram(program_);

	} // ~this

	@property {

		bool valid() {
			return true;
		} // valid

		GLuint handle() {
			return program_;
		} // handle

	}

} // Shader

struct Vertex {

} // Vertex

struct VertexArray(VT) {

	private {

		GLuint id_;
		GLuint vbo_;
		DrawPrimitive type_;
		uint num_vertices_;

	}

	@property
	GLuint* handle() {
		return &id_;
	} // handle

} // VertexArray

struct VertexBuffer(VT) {

	private {

		GLuint id;

		uint num_vertices;
		DrawPrimitive prim_type;

	}

	@property
	GLuint* handle() {
		return &id;
	} // handle

} // VertexBuffer

template PODMembers(T) {

	import std.meta : Filter;
	import std.traits : FieldNameTuple;

	template isFieldPOD(string field) {
		enum isFieldPOD = __traits(isPOD, typeof(__traits(getMember, T, field)));
	}

	alias PODMembers = Filter!(isFieldPOD, FieldNameTuple!T);

} // PODMembers

/**
 * UFCS functions for drawing, uploading data, etc.
*/

nothrow @nogc
auto upload(VertexType)(in VertexType[] vertices, DrawHint draw_hint, DrawPrimitive prim_type = DrawPrimitive.Triangles) {

	VertexArray!VertexType vao;

	vao.type_ = prim_type;
	vao.num_vertices_ = cast(uint)vertices.length;

	glGenVertexArrays(1, vao.handle);
	Renderer.bindVertexArray(vao);

	glGenBuffers(1, &vao.vbo_);
	Renderer.bindBuffer(BufferTarget.ArrayBuffer, vao.vbo_);
	glBufferData(GL_ARRAY_BUFFER, vertices.length * vertices[0].sizeof, vertices.ptr, draw_hint);

	foreach (i, m; PODMembers!VertexType) {

		alias MemberType = typeof(__traits(getMember, VertexType, m));
		enum MemberOffset = __traits(getMember, VertexType, m).offsetof;
		alias ElementType =  typeof(__traits(getMember, VertexType, m)[0]);

		glEnableVertexAttribArray(i);
		glVertexAttribPointer(i,
			MemberType.sizeof / ElementType.sizeof,
			TypeToGL!ElementType,
			GL_FALSE, // normalization
			vertices[0].sizeof, // stride to jump
			cast(const(void)*)MemberOffset
		);

	}

	return vao;

} // upload

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

	//GL_CURRENT_PROGRAM
	GLint current_program_binding;

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
	nothrow @nogc
	void clearColour(GLint rgb) {

		auto colour = to!GLColour(rgb);
		glClearColor(colour[0], colour[1], colour[2], colour[3]);
		glClear(GL_COLOR_BUFFER_BIT);

	} // clearColour

	nothrow @nogc
	void clearColour(GLclampf r, GLclampf g, GLclampf b, GLclampf a = 255) {

		glClearColor(r, g, b, a);
		glClear(GL_COLOR_BUFFER_BIT);

	} // clearColour

	nothrow @nogc
	void draw(ShaderType, VertexArrayType, Args...)(ref ShaderType shader, ref VertexArrayType vao, DrawParams params, Args args) {

		import std.string : format;

		// type checking args
		static assert(args.length == ShaderType.Bindings.length/2,
			"length of args passed doesn't match length of ShaderType bindings!");

		foreach (i, arg; Args) {
			static if (i % 2 != 0) {
				continue;
			} else {
				static assert(is (arg : ShaderType.Bindings[i]),
					"input type: %s does not match binding type: %s!".format(typeof(arg).stringof, ShaderType.Bindings[i]));
			}
		}

		Renderer.bindVertexArray(vao);
		Renderer.useProgram(shader.handle);

		foreach (i, T; Args) {

			/**
			 * Vectors
			*/

			static if (is (T : float)) {
				glUniform1f(i, args[i]);
			} else static if (is (T : float[2])) {
				glUniform2f(i, args[i][0], args[i][1]);
			} else static if (is (T : float[3])) {
				glUniform3f(i, args[i][0], args[i][1], args[i][2]);
			} else static if (is (T : float[4])) {
				glUniform4f(i, args[i][0], args[i][1], args[i][2], args[i][3]);

			} else static if (is (T : uint)) {
				glUniform1ui(i, args[i]);
			} else static if (is (T : uint[2])) {
				glUniform2ui(i, args[i][0], args[i][1]);
			} else static if (is (T : uint[3])) {
				glUniform3ui(i, args[i][0], args[i][1], args[i][2]);
			} else static if (is (T : uint[4])) {
				glUniform4ui(i, args[i][0], args[i][1], args[i][2], args[i][3]);

			} else static if (is (T : int)) {
				glUniform1i(i, args[i]);
			} else static if (is (T : int[2])) {
				glUniform2i(i, args[i][0], args[i][1]);
			} else static if (is (T : int[3])) {
				glUniform3i(i, args[i][0], args[i][1], args[i][2]);
			} else static if (is (T : int[4])) {
				glUniform4i(i, args[i][0], args[i][1], args[i][2], args[i][3]);

			} else static if (is (T : float[1][])) {
				glUniform1fv(i, args[i].length, cast(float*)args[i].ptr);
			} else static if (is (T : float[2][])) {
				glUniform2fv(i, args[i].length, cast(float*)args[i].ptr); 
			} else static if (is (T : float[3][])) {
				glUniform3fv(i, args[i].length, cast(float*)args[i].ptr);
			} else static if (is (T : float[4][])) {
				glUniform4fv(i, args[i].length, cast(float*)args[i].ptr);

			} else static if (is (T : uint[1][])) {
				glUniform1uiv(i, args[i].length, args[i].ptr);
			} else static if (is (T : uint[2][])) {
				glUniform2uiv(i, args[i].length, args[i].ptr); 
			} else static if (is (T : uint[3][])) {
				glUniform3uiv(i, args[i].length, args[i].ptr);
			} else static if (is (T : uint[4][])) {
				glUniform4uiv(i, args[i].length, args[i].ptr);

			} else static if (is (T : int[1][])) {
				glUniform1iv(i, args[i].length, args[i].ptr);
			} else static if (is (T : int[2][])) {
				glUniform2iv(i, args[i].length, args[i].ptr); 
			} else static if (is (T : int[3][])) {
				glUniform3iv(i, args[i].length, args[i].ptr);
			} else static if (is (T : int[4][])) {
				glUniform4iv(i, args[i].length, args[i].ptr);

			/**
			 * Matrices
			*/

			} else static if (is (T : float[2][2][])) {
				glUniformMatrix2fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			} else static if (is (T : float[3][3][])) {
				glUniformMatrix3fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			} else static if (is (T : float[4][4][])) {
				glUniformMatrix4fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);

			} else static if (is (T : float[2][3][])) {
				glUniformMatrix2x3fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			} else static if (is (T : float[3][2][])) {
				glUniformMatrix3x2fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			} else static if (is (T : float[2][4][])) {
				glUniformMatrix2x4fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			} else static if (is (T : float[4][2][])) {
				glUniformMatrix4x2fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			} else static if (is (T : float[3][4][])) {
				glUniformMatrix3x4fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			} else static if (is (T : float[4][3][])) {
				glUniformMatrix4x3fv(i, args[i].length, GL_FALSE, cast(float*)args[i].ptr);
			}

		}

		glDrawArrays(vao.type_, 0, vao.num_vertices_);

	} // draw

private:

	/**
	 * Internal Helpers, not public API.
	*/

	nothrow @nogc
	bool isBound(alias name)() {

		return name != 0;

	} // isBound

	nothrow @nogc
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
			printf("gland: tried checking if non-existent buffer type bound: %d", type);
		}

		return result;

	} // isAnyBound

	nothrow @nogc
	bool bindVertexArray(VertexType)(ref VertexArray!VertexType vao) {

		if (vertex_array_buffer_binding == *vao.handle) {
			return false;
		}
			
		glBindVertexArray(*vao.handle);

		return true;

	} // bindVertexArray

	nothrow @nogc
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
				printf("gland: tried to bindBuffer with unknown type: %.*s", type.stringof.length, type);
				return false;
			}

		}

		glBindBuffer(type, id);

		return true;

	} // bindBuffer

	nothrow @nogc
	bool useProgram(GLuint program) {

		if (current_program_binding == program) {
			return false; // already bound
		}

		glUseProgram(program);
		return true;

	} // useProgram

	nothrow @nogc
	bool bufferData(BufferTarget target, GLsizeiptr size, const GLvoid* data, DrawHint usage) {

		if (!isAnyBound(target)) {
			return false;
		}

		return true;

	} // bufferData

} // Renderer
