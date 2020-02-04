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

* This initial version has proven usable in applications.

## Requirements:

* Jim 0.79 or later

## Building:

There is no build process.  Simply **package require slim**; see the top of **slim.tcl** for details.

## Future Direction:

* Accept comments, subcommands, variable substitution, etc. in class variable list.

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
