# slim
# Copyright 2020 Mark Hubbard, a.k.a. "TheMarkitecht"
# http://www.TheMarkitecht.com
#
# Project home:  http://github.com/TheMarkitecht/slim
# slim is an object-oriented programming package for Jim Tcl (http://jim.tcl.tk/)
# slim helps you develop well-organized object-oriented apps in Tcl.
#
# This file is part of slim.
#
# slim is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# slim is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with slim.  If not, see <https://www.gnu.org/licenses/>.

proc test {} {
    setup Pet

    # plain instantiation.
    set p [Pet new]
    assertState $p {
        name {}
        color black
        species {}
        age 0
    }

    # default ctor 'set'.
    set p [Pet new set age 10]
    assertState $p {
        name {}
        color black
        species {}
        age 10
    }

    # named ctor with parms.
    set p [Pet new fromSpecies Tipper dog brown]
    assertState $p {
        name Tipper
        color brown
        species dog
        age 5
    }

    # inherited named ctor.
    class FossilPet Pet {
        foundIn {South Dakota}
    }
    set p [FossilPet new fromSpecies Tipper dog brown]
    assertState $p {
        name Tipper
        color brown
        species dog
        age 5
        foundIn {South Dakota}
    }
}
