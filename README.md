# slim

Project home:  [http://github.com/TheMarkitecht/slim](http://github.com/TheMarkitecht/slim)

Legal stuff:  see below.

---

## Introduction:

**slim** is an object-oriented programming package for [Jim Tcl](http://jim.tcl.tk/), the small-footprint Tcl interpreter.
**slim** is an evolution of Jim's built-in OOP support, and completely replaces it.
**slim** adds flexible constructors, eliminating the frequent need for instance-factory methods.
**slim** also eliminates the mandatory 'get' keyword, and includes various other bug fixes and improvements such as more explicit error messages.
**slim** is implemented entirely in script; there is no C component beyond the Jim interpreter.

**slim** is so named because it rhymes with Jim - thus 'slim Jim'.

## Features of This Version:

* This version has proven usable in applications.
* Accepts comments, subcommands, variable substitution, etc. in class definition.
* 3 modes of outside access selectable for each instance variable: read/write, read only, or private.
* Multiple inheritance, with all base classes' methods accessible, not just those of the right-most base class.
* Apps can check for inheritance (direct or indirect) from a given ancestor class.
* Comprehensive automated test suite, with asserts and basic speed benchmarks.
* Clean, crisp fundamental concepts and nomenclature.
* Implementation is heavily commented.
* Re-released under BSD license.

## Requirements:

* Jim 0.79 or later

## Building:

There is no build process.  Simply **package require slim**; see the top of **slim.tcl** for details.

## Future Direction:

* Write lots of apps :-) because slim is in very good condition!
* Mark a v1.0 release.  The code is ready for that now.
* Write an introductory document explaining the concepts and syntax, with examples.
* Explore how slim can be used with namespaces.

## Legal stuff:
```
  slim - an object-oriented programming package for Jim Tcl.

  Copyright 2005 Salvatore Sanfilippo <antirez@invece.org>
  Copyright 2008 Steve Bennett <steveb@workware.net.au>
  Copyright 2020 Mark Hubbard <Mark@TheMarkitecht.com>

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above
     copyright notice, this list of conditions and the following
     disclaimer in the documentation and/or other materials
     provided with the distribution.

  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY
  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  AUTHORS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## Contact:

Send donations, praise, curses, and the occasional question to: `Mark-ate-TheMarkitecht-dote-com`

## Final Word:

I hope you enjoy this software.  If you enhance it, port it to another environment,
or just use it in your project etc., by all means let me know.

>  \- TheMarkitecht

---
