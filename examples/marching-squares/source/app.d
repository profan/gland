import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;

import gland.util;
import gland.win;
import gland.gl;

immutable char* ms_vs = "
	#version 330 core

	layout (location = 0) in vec2 position;

	void main() {
		gl_Position = vec4(position, 0.0, 1.0);
	}

";

immutable char* ms_gs = "
	#version 330 core

	layout (points) in;
	layout (triangle_strip, max_vertices = 25) out;

	uniform sampler2D texture_map;

	out vec3 gs_colour;

	void outputSequence(vec4 origin, int which) {

		switch (which) {

			case 0:
				break;

			/*
			   x---o
			   |   |
			   o---o
			*/
			case 1: {

				vec4 offset_1 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;
				
			}

			/*
			   o--x
			   |  |
			   o--o
			*/
			case 2: {

				vec4 offset_1 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--x
			   |  |
			   o--o
			*/
			case 3: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--o
			   |  |
			   o--x
			*/
			case 4: {

				vec4 offset_1 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position  = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--o
			   |  |
			   o--x
			*/
			case 5: {

				// outputSequence(origin, 1);
				// outputSequence(origin, 4);

				break;

			}

			/*
			   o--x
			   |  |
			   o--x
			*/
			case 6: {

				vec4 offset_1 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--x
			   |  |
			   o--x
			*/
			case 7: {
				
				vec4 offset_1 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--o
			   |  |
			   x--o
			*/
			case 8: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--o
			   |  |
			   x--o
			*/
			case 9: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(0.5, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;
			
			}

			/*
			   o--x
			   |  |
			   x--o
			*/
			case 10: {

				vec4 offset_1 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--o
			   |  |
			   x--x
			*/
			case 11: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--o
			   |  |
			   x--x
			*/
			case 12: {

				vec4 offset_1 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;
				
			}

			/*
			   x--x
			   |  |
			   x--o
			*/
			case 13: {

				vec4 offset_1 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--x
			   |  |
			   o--x
			*/
			case 14: {

				vec4 offset_1 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--x
			   |  |
			   x--x
			*/
			case 15: {
				
				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}
		}

	} // outputSequence

	void main() {

		vec4 origin = gl_in[0].gl_Position;
		ivec2 coord = ivec2(origin.xy);
		float colour = texelFetch(texture_map, coord, 0).r;

		gs_colour = vec3(colour, 0.0, 0.0);

		vec2[9] positions = vec2[9](
			vec2(origin.x, origin.y), // point itself
			vec2(origin.x + 1, origin.y), // right of point
			vec2(origin.x, origin.y + 1), // below point
			vec2(origin.x + 1, origin.y + 1), // below to the right
			vec2(origin.x - 1, origin.y), // to the left of the point
			vec2(origin.x, origin.y - 1), // above point
			vec2(origin.x - 1, origin.y - 1), // above and to the left
			vec2(origin.x + 1, origin.y - 1), // above and to the right
			vec2(origin.x - 1, origin.y + 1) // below and to the left
		);

		int start_x = clamp(int(origin.x) - 1, 0, 6);
		int start_y = clamp(int(origin.y) - 1, 0, 6);
		int end_x = clamp(int(origin.x) + 1, 0, 6);
		int end_y = clamp(int(origin.y) + 1, 0, 6);

		/*
		int result;
		for (int y = start_y; y < end_y; y++) {
			for (int x = start_x; x < end_x; x++) {
				int value = int(texture2D(texture_map, coord + vec2(x, y) / 6.0).r);
				result |= value;
			}
		}*/

		int result;
		result |= int(texelFetch(texture_map, coord, 0).r);;

		outputSequence(origin, 15);

	}

";

immutable char* ms_fs = "
	#version 330 core

	in vec3 gs_colour;

	out vec3 f_colour;

	void main() {
		//f_colour = vec3(1.0, 0.0, 0.0);
		f_colour = gs_colour;
	}
";

alias Vec2f = float[2];
alias Mat4f = float[4][4];

enum GridSize = 8;
alias Height = ubyte;

immutable Height[GridSize][GridSize] grid = [
	[
		5, 10, 10, 10, 10, 10, 10, 5
	],
	[
		10, 10, 15, 15, 15, 15, 10, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 10, 15, 15, 15, 15, 10, 10
	],
	[
		5, 10, 10, 10, 10, 10, 10, 5
	]

];

alias MapShader = Shader!(
	[ShaderType.VertexShader, ShaderType.GeometryShader, ShaderType.FragmentShader], [
		AttribTuple("position", 0)
	], Texture*, "texture_map"
);

@(DrawType.DrawArrays)
struct MapData {

	@(DrawHint.StaticDraw)
	@(BufferTarget.ArrayBuffer)
	@VertexCountProvider
	Vec2f[] positions;

} // MapData

alias MapVao = VertexArrayT!MapData;

immutable char* ts_vs = "
	#version 330 core

	layout (location = 0) in vec2 position;
	layout (location = 1) in vec2 uv;

	out vec2 tex_coord;

	void main() {
		gl_Position = vec4(position - 0.5, 0.0, 1.0);
		tex_coord = uv;
	}
";

immutable char* ts_fs = "
	#version 330 core

	in vec2 tex_coord;

	uniform sampler2D diffuse;

	out vec4 f_colour;

	void main() {
		f_colour = vec4(texture2D(diffuse, tex_coord).r, 0.0, 0.0, 1.0);
	}
";

alias TextureShader = Shader!(
	[ShaderType.VertexShader, ShaderType.FragmentShader], [
		AttribTuple("position", 0),
		AttribTuple("uv", 1)
	], Texture*, "diffuse"
);

struct Vertex2f2f {
	float[2] position;
	float[2] uv;
} // Vertex2f2f

@(DrawType.DrawArrays)
struct VertexData {

	@VertexCountProvider
	@(BufferTarget.ArrayBuffer)
	@(DrawHint.StaticDraw)
	Vertex2f2f[] vertices;

} // VertexData

alias TextureVao = VertexArrayT!VertexData;

Texture generateMapTexture(ref in Height[GridSize][GridSize] cells) {

	TextureParams params = {
		internal_format : InternalTextureFormat.R8,
		pixel_format : PixelFormat.Red,
		pack_alignment : PixelPack.One,
		unpack_alignment : PixelPack.One,
		wrapping : TextureWrapping.Repeat
	};

	writefln("data: %s", (cast(ubyte*)cells.ptr)[0..GridSize*GridSize]);

	Texture new_texture;
	auto texture_result = Texture.create(new_texture, cast(ubyte*)cells.ptr, GridSize, GridSize, params);

	return new_texture;

} // generateMapTexture

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

	// texture shader stuff
	TextureShader tex_shader;
	auto tex_shader_result = TextureShader.compile(tex_shader, &ts_vs, &ts_fs);

	// declare texture quad data
	Vertex2f2f[6] vertices = [
		Vertex2f2f([0.0f, 0.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([1.0f, 0.0f], [1.0f, 0.0f]), // top right
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]), // bottom right
		Vertex2f2f([0.0f, 0.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([0.0f, 1.0f], [0.0f, 1.0f]), // bottom left
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]) // bottom right
	];

	auto vertex_data = VertexData(vertices);
	auto tex_vao = TextureVao.upload(vertex_data, DrawPrimitive.Triangles);

	// load graphics and stuff
	MapShader map_shader;
	auto shader_result = MapShader.compile(map_shader, &ms_vs, &ms_gs, &ms_fs);
	auto map_texture = generateMapTexture(grid); 
	
	// check validity
	if (shader_result != MapShader.Error.Success) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

	// position data
	uint cur_x, cur_y;
	Vec2f[GridSize][GridSize] grid_positions;
	foreach (y, row; grid_positions) {
		foreach (x, col; row) {
			grid_positions[y][x] = [cur_x++, cur_y];
		}
		cur_y++;
	}

	auto map_data = MapData(cast(Vec2f[])grid_positions);

	// now, upload vertices
	auto vao = MapVao.upload(map_data, DrawPrimitive.Points);

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
		//Renderer.draw(map_shader, vao, params, &map_texture);
		Renderer.draw(tex_shader, tex_vao, params, &map_texture);

		window.present();

	}

}
