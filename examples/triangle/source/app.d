import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;

import gland.win;
import gland.gl;
import util;

immutable char* vs_shader = "
	#version 330

	uniform mat4 matrix;

	layout (location = 0) in vec3 position;

	out vec3 vColor;

	void main() {
		gl_Position = vec4(position, 1.0) * matrix;
		vColor = vec3(1, 0, 0);
	}
";

immutable char* fs_shader = "
	#version 330

	in vec3 vColor;
	out vec4 f_color;

	void main() {
		f_color = vec4(vColor, 1.0);
	}
";

alias Mat4f = float[4][4];

alias TriangleShader = Shader!([
	ShaderTuple(ShaderType.VertexShader, [
		AttribTuple("position", 0)
	]),
	ShaderTuple(ShaderType.FragmentShader, [])
], Mat4f, "matrix");

struct Vec3f {

	alias T = float[3];
	T data_;

	this(float f1, float f2, float f3) {
		data_ = [f1, f2, f3];
	}

	alias data_ this;

} // Vec3f

struct Vec2f {

	alias T = float[2];
	T data_;

	this(float f1, float f2) {
		data_ = [f1, f2];
	}

	alias data_ this;

} // Vec2f

struct Vertex3f {

	Vec3f.T position;

} // Vertex3f

void main() {

	// load libs
	Window.load();

	Window window;
	auto result = Window.create(window, 640, 480);

	final switch (result) with (Window.Error) {

		/* return from main if we failed, print stuff. */
		case WindowCreationFailed, ContextCreationFailed:
			writefln("[WIN] Error: %s", cast(string)result);
			return;

		/* we succeeded, just continue. */
		case Success:
			writefln("[WIN] %s", cast(string)result);
			break;

	}

	// ortographic projection
	Mat4f projection = orthographic(0.0f, window.width, 0.0f, window.height, 0.0f, 1.0f);
	auto transposed_projection = transpose(projection); // because OpenGL row-major

	// load graphics and stuff
	auto triangle_shader = TriangleShader.compile(&vs_shader, &fs_shader);

	// check validity
	if (!triangle_shader.valid) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

	// declare vertex data
	int w = window.width;
	int h = window.height;

	Vertex3f[6] vertices = [
		Vertex3f(Vec3f(0.0f, 0.0f, 0.0f)), // top left
		Vertex3f(Vec3f(w, 0.0f, 0.0f)), // top right
		Vertex3f(Vec3f(w, h, 0.0f)), // bottom right

		Vertex3f(Vec3f(0.0f, 0.0f, 0.0f)), // top left
		Vertex3f(Vec3f(0.0f, h, 0.0f)), // bottom left
		Vertex3f(Vec3f(w, h, 0.0f)) // bottom right
	];

	// now, upload vertices
	auto vao = vertices.upload(DrawHint.StaticDraw, DrawPrimitive.Triangles);

	while (window.isAlive) {

		// handle window events
		window.handleEvents();

		// check if it's time to quit
		if (window.isKeyDown(SDL_SCANCODE_ESCAPE)) {
			window.quit();
		}

		// default state, holds all OpenGL state params like blend state etc to be use for given draw call
		DrawParams params = {};

		// cornflower blue, of course
		Renderer.clearColour(0x428bca);
		Renderer.draw(triangle_shader, vao, params, transposed_projection);

		window.present();

	}

}
