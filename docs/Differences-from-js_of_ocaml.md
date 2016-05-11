[js_of_ocaml](https://github.com/ocsigen/js_of_ocaml) is a popular compiler which compiles OCaml's bytecode into JavaScript. It is the inspiration for this project, and has already been under development for several years and is ready for production. In comparison, BuckleScript, while moving fast, is still a very young project. BuckleScript's motivation, like `js_of_ocaml`, is to unify the ubiquity of the JavaScript platform and the truly sophisticated type system of OCaml, however, there are some areas where we view things differently from `js_of_ocaml`. We describe below, some of these differences, and also refer readers to some of the original informal [discussions](https://github.com/ocsigen/js_of_ocaml/issues/338).

## Debuggable Output

One of the main BuckleScript goal is to generate debuggable JavaScript code. From the start we believed developers using BuckleScript for JavaScript development will look at the generated code an order of magnitude more than an OCaml developer will look at the assembly one. Part of our intent is to make it easier for a JavaScript developer to transition to the OCaml language. Furthermore looking at existing transpilers for JavaScript:  [coffescript](http://coffeescript.org/), [babel](https://babeljs.io/) and [typescript](https://github.com/Microsoft/TypeScript), the most widely adopted ones are the one that favors code readability.
The generated code by BuckleScript is pretty close to the JavaScript code one might write by hand, especially if you use mostly the language features which are shared between JavaScript and OCaml. 

`js_of_ocaml` produces code with mangled names, which is typically not a concern, except when the code is used as a primary backend and must be extensively debugged and maintained. In these situations, `js_of_ocaml` proves harder to debug, because the original names in the code are lost.

## Runtime Representations && FFI

**Runtime Representation**

`js_of_ocaml` runtime representation is as close as possible to the runtime representation of native/byte compiler. This makes it particularly easy for an OCaml developer already familiar with that representation. 

BuckleScript runtime representation is closer to JavaScript. This is particularly helpful for both the ability to debug OCaml values in JavaScript but also when writing the FFI.

Some example of differences are:
- `string` : In BuckleScript the string is represented as a JavaScript string while in `js_of_ocaml` it's a much more involved data structure. 
- `array`: In BuckleScript the array has the same indexing as a JavaScript array while for `js_of_ocaml` the index starts at 1.  
- `tuple`: In BuckleScript the array has the same indexing as a JavaScript array while for `js_of_ocaml` the index starts at 1.

**FFI**

Regarding the FFI, BuckleScript favors using only [attributes](http://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec245); one drawback that we plan to address on the future is that it lacks some expressiveness. 

`js_of_ocaml` introduces a very sophisticated and expressive syntax extension, which works great most of the time, but can sometimes generate confusing compiler errors, and be difficult to integrate with existing IDEs and build systems. 

**Runtime library**

BuckleScript runtime library is mostly implemented in OCaml while `js_of_ocaml` runtime is purely in JavaScript. The difference is actually significant since we believe it reflects how easy it is to write JavaScript code in OCaml using the BuckleScript model (FFI and Runtime representation).

## Separate Compilation

BuckleScript compiles one OCaml module into one Javascript module. This follows the modern JavaScript development and makes it easier to gradually use OCaml in an existing code base. This is particularly relevant for our use cases for which we plan to implement components in OCaml while the larger application is written in JavaScript. The JavaScript echo system also has plenty of tools and support for modules, making it easy and natural to integrate modules generated by BuckleScript. It also opens the door for supporting [hot module replacement](http://webpack.github.io/docs/hot-module-replacement.html) in future.
The module compilation strategy allows more granular compilation and as consequence faster feedback loop during development. 

`js_of_ocaml` compiles a whole OCaml program in JavaScript. This makes it easier when the main application is written in OCaml but less natural when integrating OCaml as a component in a larger JavaScript application.

## Integration with existing ecosystems

BuckleScript is aware of `npm` module paths and favor libraries development. In contrast with `js_of_ocaml`' focus on developing executable. 
BuckleScript does not provide a whole program compilation mode out of the box; it rather delegates this to existing linker/bundler (such as webpack or Google Closure compiler).

When integrating code generated by BuckleScript developers only need to look at the `.mli` files. BuckleScript respect those interfaces and will only export the functions from the `.mli file. No special code needs to be added to expose OCaml code to the JavaScript.

`js_of_ocaml` requires specific code to export functions OCaml code to the larger JavaScript application.

## Intrusiveness

The major advantage of `js_of_ocaml` is that it is non intrusive; you can reuse your existing project setup (build system) and simply convert the bytecode output to JavaScript output as a post-processing step. 

With BuckleScript, however, users have to adapt their build system for existing OCaml code base. In BuckleScript, we traded intrusiveness for being able to extract more information from the code. 

We think there's a need for both tools to exist simultaneously. If you have some OCaml code, and your primary motivation is that it should run inside a browser, then `js_of_ocaml` is a very good choice. However, if you target JavaScript (browser/Node.Js) as the primary backend for your application and care about the integration with the JavaScript environment then we believe BuckleScript can offer a better experience. We also think both projects can help and learn from each other.

## Performance

We have not conducted exhaustive benchmarks yet, however, our initial results show similar performance between `js_of_ocaml` and BuckleScript (using Google Closure simple optimization level).