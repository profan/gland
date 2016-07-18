import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;

import gland.util;
import gland.win;
import gland.gl;

immutable char* vs_shader = "
	#version 330

	layout (location = 0) in vec3 position;
	layout (location = 1) in vec3 colour;

	out vec3 v_colour;

	void main() {
		gl_Position = vec4(position, 1.0);
		v_colour = colour;
	}
";

immutable char* fs_shader = "
	#version 330

	in vec3 v_colour;
	out vec4 f_colour;

	void main() {
		f_colour = vec4(v_colour, 1.0);
	}
";

alias Mat4f = float[4][4];

alias TriangleShader = Shader!([
	ShaderTuple(ShaderType.VertexShader, [
		AttribTuple("position", 0),
		AttribTuple("colour", 1)
	]),
	ShaderTuple(ShaderType.FragmentShader, [])
]);

struct Vec3f {

	alias T = float[3];
	T data_;

	this(float f1, float f2, float f3) {
		data_ = [f1, f2, f3];
	}

	alias data_ this;

} // Vec3f

struct Vertex3f {

	Vec3f.T position;
	Vec3f.T colour;

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

	// load graphics and stuff
	auto triangle_shader = TriangleShader.compile(&vs_shader, &fs_shader);

	// check validity
	if (!triangle_shader.valid) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

	// declare vertex data
	Vertex3f[3] vertices = [
		Vertex3f(Vec3f(0.0f, 0.5f, 0.0f), Vec3f(1, 0, 0)), // triangle top
		Vertex3f(Vec3f(-0.5f, -0.5f, 0.0f), Vec3f(0, 1, 0)), // triangle left
		Vertex3f(Vec3f(0.5f, -0.5f, 0.0f), Vec3f(0, 0, 1)) // triangle right
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
		Renderer.draw(triangle_shader, vao, params);

		window.present();

	}

}
