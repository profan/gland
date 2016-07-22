import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;
import derelict.freetype.ft;

import gland.util;
import gland.win;
import gland.gl;

immutable char* vs_shader = "
	#version 330 core

	layout (location = 0) in vec4 coord;
	out vec2 tex_coord;

	uniform mat4 projection;

	void main() {
		gl_Position = projection * vec4(coord.xy, 0.0, 1.0);
		tex_coord = coord.zw;
	}
";

immutable char* fs_shader = "
	#version 330 core

	in vec2 tex_coord;

	uniform sampler2D tex;
	uniform vec4 color;

	void main() {
		gl_FragColor = vec4(1, 1, 1, texture2D(tex, tex_coord).r) * color;
	}
";

alias Mat4f = float[4][4];

alias TextShader = Shader!([
	ShaderTuple(ShaderType.VertexShader, [
		AttribTuple("coord", 0)
	]),
	ShaderTuple(ShaderType.FragmentShader, [])
], Mat4f[], "projection", float[4], "color", Texture*, "tex");

alias Vec4f = float[4];

struct FontAtlas {

	import std.algorithm : max;
	import derelict.freetype.ft;

	private struct CharacterInfo {

		float advance_x; // advance.x
		float advance_y; // advance.y

		float bitmap_width; // bitmap.width;
		float bitmap_height; // bitmap.rows;

		float bitmap_left; // bitmap_left;
		float bitmap_top; // bitmap_top;

		float tx_offset; // x offset of glyph in texture coordinates
		float tx_offset_y;

	} //CharacterInfo

	struct Vertex4f {
		Vec4f coord;
		alias coord this;
	} // Vertex4f

	enum Error {
		Success = "FontAtlas successfully created."
	} // Error

	private {

		VertexArray!Vertex4f vertices_;
		TextShader shader_;
		Texture texture_;

		CharacterInfo[96] chars_;

		int atlas_width_;
		int atlas_height_;

		int char_width_;
		int char_height_;

	}

	// load libs
	static void load() {

		DerelictFT.load();

	} // load

	static Error create(ref FontAtlas atlas, in char* font_name, int font_size, ref TextShader shader) {

		// freetype shit
		FT_Library ft;
		FT_Face face;

		if (FT_Init_FreeType(&ft)) { //TODO move this
			printf("[FontAtlas] Could not init freetype.");
		}

		if (FT_New_Face(ft, font_name, 0, &face)) {
			printf("[FontAtlas] Could not open font.");
		}

		scope(exit) {
			FT_Done_Face(face);
			FT_Done_FreeType(ft);
		}

		FT_Set_Pixel_Sizes(face, 0, font_size);
		FT_GlyphSlot glyph = face.glyph;

		int w = 0, h = 0;
		for (uint i = 32; i < 128; ++i) {

			if (FT_Load_Char(face, i, FT_LOAD_RENDER)) {
				printf("[FontAtlas] Character %c failed to load.", i);
				continue;
			}

			w += glyph.bitmap.width;
			h = max(h, glyph.bitmap.rows);

			atlas.atlas_width_ = w;
			atlas.atlas_height_ = h;

		}

		TextureParams params = {
			internal_format : InternalTextureFormat.R8,
			pixel_format : PixelFormat.Red,
			unpack_alignment : PixelPack.One,
			filtering : TextureFiltering.Linear,
			wrapping : TextureWrapping.ClampToEdge
		};

		auto texture_result = Texture.create(atlas.texture_, null, w, h, params);

		int x = 0; // current x position in the resulting texture to write to
		for (uint i = 32; i < 128; ++i) {

			if (FT_Load_Char(face, i, FT_LOAD_RENDER)) {
				continue;
			}

			float top_distance = face.glyph.metrics.horiBearingY; //used to adjust for eventual hang

			atlas.texture_.update(x, 0, glyph.bitmap.width, glyph.bitmap.rows, glyph.bitmap.buffer);

			int ci = i - 32;
			atlas.chars_[ci].advance_x = glyph.advance.x >> 6;
			atlas.chars_[ci].advance_y = glyph.advance.y >> 6;

			atlas.chars_[ci].bitmap_width = glyph.bitmap.width;
			atlas.chars_[ci].bitmap_height = glyph.bitmap.rows;

			atlas.chars_[ci].bitmap_left = glyph.bitmap_left;
			atlas.chars_[ci].bitmap_top = glyph.bitmap_top;

			atlas.chars_[ci].tx_offset = cast(float)x / w;
			atlas.chars_[ci].tx_offset_y = (top_distance/64 - (face.glyph.metrics.height>>6));

			x += glyph.bitmap.width; // adjust x position by the width of the current bitmap

		}

		// TODO document this part
		atlas.char_width_ = cast(typeof(char_width_))face.glyph.metrics.width >> 6;
		atlas.char_height_ = cast(typeof(char_height_))face.glyph.metrics.height >> 6;

		/**
		 * EVERYTHING ELSE
		*/

		import std.algorithm.mutation : move;
		move(shader, atlas.shader_);

		Vertex4f[3] verts = [
			Vertex4f([0.0f, 0.0f, 0.0f, 0.0f]),
			Vertex4f([0.0f, 32.0f, 0.0f, 32.0f]),
			Vertex4f([32.0f, 32.0f, 32.0f, 32.0f]),
		];

		atlas.vertices_ = upload(verts[], DrawHint.DynamicDraw, DrawPrimitive.Triangles);

		return Error.Success;

	} // create

	void renderText(Mat4f[] projection_data, in char[] text, float x, float y, float sx, float sy, int colour) {

		import core.stdc.stdlib : malloc, free;
		Vertex4f[] coords = (cast(Vertex4f*)malloc(Vertex4f.sizeof * (text.length * 6)))[0..text.length*6];
		scope(exit) { free(cast(void*)coords.ptr); }

		int n = 0; // current index into coords
		foreach (ch; text) {

			if (ch < 32 || ch > 127) {
				continue;
			}

			int ci = ch - 32; // char index into chars_ array

			float x2 =  x + chars_[ci].bitmap_left * sx;
			float y2 = y + chars_[ci].bitmap_top * sy;

			float w = chars_[ci].bitmap_width * sx;
			float h = chars_[ci].bitmap_height * sy;

			x += chars_[ci].advance_x * sx;
			y += chars_[ci].advance_y * sy;

			// adjust for hang
			y2 -= (chars_[ci].bitmap_top * sy);
			y2 -= (chars_[ci].tx_offset_y * sy);

			if (!w || !h) { // continue if no width or height, invisible character
				continue;
			}

			coords[n++] = [x2, y2, chars_[ci].tx_offset, chars_[ci].bitmap_height / atlas_height_]; //top left?
			coords[n++] = [x2, y2 - h, chars_[ci].tx_offset, 0];

			coords[n++] = [x2 + w, y2, chars_[ci].tx_offset + chars_[ci].bitmap_width / atlas_width_, chars_[ci].bitmap_height / atlas_height_];
			coords[n++] = [x2 + w, y2, chars_[ci].tx_offset + chars_[ci].bitmap_width / atlas_width_, chars_[ci].bitmap_height / atlas_height_];

			coords[n++] = [x2, y2 - h, chars_[ci].tx_offset, 0];
			coords[n++] = [x2 + w, y2 - h, chars_[ci].tx_offset + chars_[ci].bitmap_width / atlas_width_, 0];

		}

		DrawParams params = {
			do_blend_test : true,
			do_face_culling : false,
			do_depth_test : false
		};

		vertices_.update!Vertex4f(coords, DrawHint.DynamicDraw);
		Renderer.draw(shader_, vertices_, params, projection_data, to!GLColour(colour), &texture_);

	} // renderText

} // FontAtlas

void main() {

	// load libs
	Window.load();
	FontAtlas.load();

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
	auto transposed_projection = transpose(projection);

	// load graphics and stuff
	auto text_shader = TextShader.compile(&vs_shader, &fs_shader);

	FontAtlas text_atlas;
	auto atlas_result = FontAtlas.create(text_atlas, "fonts/OpenSans-Bold.ttf", 12, text_shader);

	// check validity
	if (!text_shader.valid) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

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

		Mat4f[1] projection_data = [transposed_projection];
		text_atlas.renderText(projection_data[], "Hello, World!", window.width / 2, window.height / 2, 1.0f, 1.0f, 0xFFF);

		window.present();

	}

}
