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

## Requirements:

* Jim 0.79 or later

## Building:

There is no build process.  Simply **package require slim**; see the top of **slim.tcl** for details.

## Future Direction:

* Write lots of apps :-) because slim is in very good condition!
* Convert from LGPL to BSD license.
* Mark a v1.0 release.  The code ready for that now.
* Write an introductory document explaining the concepts and syntax, with examples.
* Explore how slim can be used with namespaces.

## Legal stuff:
```
  slim
  Copyright 2020 Mark Hubbard, a.k.a. "TheMarkitecht"
  http://www.TheMarkitecht.com

  Project home:  http://github.com/TheMarkitecht/slim
  slim is an object-oriented programming package for Jim Tcl (http://jim.tcl.tk/)
  slim helps you develop well-organized object-oriented apps in Tcl.

  This file is part of slim.

  slim is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  slim is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with slim.  If not, see <https://www.gnu.org/licenses/>.
```

See [COPYING.LESSER](COPYING.LESSER) and [COPYING](COPYING).

## Contact:

Send donations, praise, curses, and the occasional question to: `Mark-ate-TheMarkitecht-dote-com`

## Final Word:

I hope you enjoy this software.  If you enhance it, port it to another environment,
or just use it in your project etc., by all means let me know.

>  \- TheMarkitecht

---
