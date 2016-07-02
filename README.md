gland
-----------
This library is intended primarily to reduce boilerplate that OpenGL imposes on the user by employing code generation from user defined structures, getting as close as one can get to making working with OpenGL declarative.

Inspirations
------------------
Without a doubt, (https://github.com/tomaka/glium)[glium] from tomaka is a heavy inspiration for undertaking this project. After seeing it done in Rust, I realised my current approach of working with OpenGL was flawed, and given D's strengths in metaprogramming, I instantly wanted to see how viable it was to do in D.

Who is this for?
-------------------
Anyone who normally would have wanted to use OpenGL in D, but wanted a safer and less repetitive way of working with OpenGL, while retaining all the power of OpenGL with as minimal overhead as possible.
Naturally, working with OpenGL directly would have the least overhead possible, but this library is intended to make common errors when working with OpenGL non-existent, as well as erase boilerplate.

License
-----------
MIT, See LICENSE
