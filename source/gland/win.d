module gland.win;

import core.stdc.stdio;
import core.stdc.stdlib : exit;
import std.functional : toDelegate;
import std.typecons : tuple;

import derelict.sdl2.sdl;
import glad.gl.loader;
import glad.gl.gl;

struct Window {

	enum Error {
		Success = "Window Creation Succeeded!",
		WindowCreationFailed = "Failed to create window!",
		ContextCreationFailed = "Failed to create OpenGL context of at least version 3.3!"
	} // Error

	private {

		SDL_Window* window_;
		SDL_GLContext context_;
		int width_, height_;
		bool alive_;

		// keyboard state
		ubyte* keyboard_;

		// mouse state
		bool[4] mouse_buttons_down_;

	}

	@property
	const nothrow @nogc {

		bool isAlive() { return alive_; }
		int width() { return width_; }
		int height() { return height_; }

	}
		
	void quit() { alive_ = false; }

	@disable this(this);
	@disable ref Window opAssign(ref Window window);

	~this() {

		if (window_) {
			debug printf("[GLAND] Destroying Window. \n");
			SDL_GL_DeleteContext(context_);
			SDL_DestroyWindow(window_);
			SDL_Quit();
		}

	} // ~this

	static load() {

		DerelictSDL2.load();
		SDL_Init(SDL_INIT_EVENTS | SDL_INIT_VIDEO);

	} // load

	static Error create(ref Window window, uint width, uint height) {

		uint flags = 0;
		flags |= SDL_WINDOW_OPENGL;

		window.window_ = SDL_CreateWindow(
			"SDL2 Window",
			SDL_WINDOWPOS_UNDEFINED,
			SDL_WINDOWPOS_UNDEFINED,
			width, height,
			flags
		);	

		// is valid?
		if (!window.window_) { return Error.WindowCreationFailed; }

		// get window dimensions and set vars in struct
		SDL_GetWindowSize(window.window_, &window.width_, &window.height_);

		// try creating context, TODO is setting a "min" version
		auto result = window.createGLContext(3, 3);
		if (result != 0) { return Error.ContextCreationFailed; }

		// it's alive!
		window.alive_ = true;

		// set up keyboard
		window.keyboard_ = SDL_GetKeyboardState(null);

		return Error.Success;

	} // create

	private int createGLContext(int gl_major, int gl_minor) {

		import std.functional : toDelegate;

		// OpenGL related attributes
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, gl_major);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, gl_minor);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

		// debuggering!
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG);

		// actually create context now
		context_ = SDL_GL_CreateContext(window_);

		if (!context_) {
			auto err = SDL_GetError();
			printf("[OpenGL] context creation error: %s \n", err);
			return -1;
		}

		// loader here
		auto glv = gladLoadGL((const (char)* load) => SDL_GL_GetProcAddress(load));

		if (!context_) {
			GLenum err = glGetError();
			printf("[OpenGL] Error: %d \n", err);
			return err;
		}

		const GLubyte* sGLVersion_ren = glGetString(GL_RENDERER);
		const GLubyte* sGLVersion_main = glGetString(GL_VERSION);
		const GLubyte* sGLVersion_shader = glGetString(GL_SHADING_LANGUAGE_VERSION);
		printf("[OpenGL] renderer is: %s \n", sGLVersion_ren);
		printf("[OpenGL] version is: %s \n", sGLVersion_main);
		printf("[OpenGL] GLSL version is: %s \n", sGLVersion_shader);
		printf("[OpenGL] Loading GL Extensions. \n");

		glEnable(GL_DEBUG_OUTPUT);
		glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
		glDebugMessageCallback(&openGLCallbackFunction, null);

		// enable all
		glDebugMessageControl(
			GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, null, true
		);

		// disable notification messages
		glDebugMessageControl(
			GL_DONT_CARE, GL_DONT_CARE, GL_DEBUG_SEVERITY_NOTIFICATION, 0, null, false
		);

		return 0; // all is well

	}

	version (Windows) {
		extern(Windows) nothrow @nogc
			static void openGLCallbackFunction(
					GLenum source, GLenum type,
					GLuint id, GLenum severity,
					GLsizei length, const (GLchar*) message,
					void* userParam)
		{

			import gland.gl : to;

			printf("Message: %s \nSource: %s \nType: %s \nID: %d \nSeverity: %s\n\n",
					message, to!(char*)(source), to!(char*)(type), id, to!(char*)(severity));

			if (severity == GL_DEBUG_SEVERITY_HIGH) {
				printf("Aborting...\n");
			//	exit(-1);
			}

		} //openGLCallbackFunction
	}

	version (linux) {
		extern(C) nothrow @nogc
			static void openGLCallbackFunction(
					GLenum source, GLenum type,
					GLuint id, GLenum severity,
					GLsizei length, const (GLchar*) message,
					void* userParam)
		{

			import gland.gl : to;

			printf("Message: %s \nSource: %s \nType: %s \nID: %d \nSeverity: %s\n\n",
					message, to!(char*)(source), to!(char*)(type), id, to!(char*)(severity));

			if (severity == GL_DEBUG_SEVERITY_HIGH) {
				printf("Aborting...\n");
				exit(-1);
			}

		} //openGLCallbackFunction		
	}

	nothrow @nogc
	void present() {

		SDL_GL_SwapWindow(window_);

	} // present

	nothrow @nogc
	bool isKeyDown(SDL_Scancode key) {

		return cast(bool)keyboard_[key];

	} // isKeyDown

	bool isMouseButtonDown(Uint8 btn) {
		return mouse_buttons_down_[btn];
	} // isMouseButtonDown

	nothrow @nogc
	int[2] getMousePosition() {

		int x, y;
		SDL_GetMouseState(&x, &y);

		return [x, y];

	} // getMousePosition

	nothrow @nogc
	static void noOpHandler(ref SDL_Event ev) {

	}
	
	alias DelegateType = nothrow @nogc void delegate(ref SDL_Event ev);

	nothrow @nogc
	void handleEvents(DelegateType handler = toDelegate(&noOpHandler)) {

		SDL_Event ev;

		while (SDL_PollEvent(&ev)) {

			switch (ev.type) {

				case SDL_MOUSEBUTTONDOWN:
					mouse_buttons_down_[ev.button.button] = true;
					break;

				case SDL_MOUSEBUTTONUP:
					mouse_buttons_down_[ev.button.button] = false;
					break;

				case SDL_QUIT:
					alive_ = false;
					break;

				default:
					handler(ev);
					break;

			}

		}

	} // handleEvents

	void setFullscreen() {

		SDL_SetWindowFullscreen(window_, SDL_WINDOW_FULLSCREEN);

	} // toggleFullscreen

} // Window
