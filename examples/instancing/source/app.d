import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;

import gland.util;
import gland.win;
import gland.gl;

immutable char* vs_shader = "
	#version 330 core

	layout (location = 0) in vec2 position;
	layout (location = 1) in vec3 colour;
	layout (location = 2) in vec2 offset;

	out vec3 v_colour;

	void main() {
		gl_Position = vec4(position + offset, 0.0, 1.0);
		v_colour = colour;
	}
";

immutable char* fs_shader = "
	#version 330 core

	in vec3 v_colour;
	out vec4 f_colour;

	void main() {
		f_colour = vec4(v_colour, 1.0);
	}
";

alias Mat4f = float[4][4];

alias InstanceShader = Shader!(
	[ShaderType.VertexShader, ShaderType.FragmentShader], [
		AttribTuple("position", 0),
		AttribTuple("colour", 1),
		AttribTuple("offset", 2)
	]
);

struct Vertex2f3f {

	float[2] position;
	float[3] colour;

} // Vertex2f3f

@(DrawType.DrawArraysInstanced)
struct VertexData {

	@(DrawHint.StaticDraw)
	@(BufferTarget.ArrayBuffer)
	@VertexCountProvider
	Vertex2f3f[] vertices;
	
	@(DrawHint.DynamicDraw)
	@(BufferTarget.ArrayBuffer)
	@VertexAttribDivisor(1) // changes EVERY FREHM!
	@InstanceCountProvider
	float[2][] offsets;

} // VertexData

alias InstanceVao = VertexArrayT!VertexData;

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
	InstanceShader instance_shader;
	auto shader_result = InstanceShader.compile(instance_shader, &vs_shader, &fs_shader);

	// check validity
	if (shader_result != InstanceShader.Error.Success) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

	// declare static vertex data
	Vertex2f3f[3] vertices = [
		Vertex2f3f([0.0f, 0.25f], [1.0f, 0.0f, 0.0f]), // triangle top
		Vertex2f3f([-0.25f, -0.25f], [0.0f, 1.0f, 0.0f]), // triangle left
		Vertex2f3f([0.25f, -0.25f], [0.0f, 0.0f, 1.0f]) // triangle right
	];
	
	float[2][40] instances;
	foreach (i, ref e; instances) {
		e = [-0.75f + (0.05f * i), -0.75f + (0.05f * i)];
	}
	
	// package data
	auto data = VertexData(vertices, instances);

	// now, upload all ze data
	auto vao = InstanceVao.upload(data, DrawPrimitive.Triangles);

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
		Renderer.draw(instance_shader, vao, params);

		window.present();

	}

}
