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

    # validateInstance OK.
    Pet method validateInstance {} {
        if {$color eq {}} {error "color required"}
        set color fur-$color
    }
    set p [Pet new]
    assertState $p {color fur-black}

    # validateInstance after named ctor.
    set p [Pet new fromSpecies Arnie bear white]
    assertState $p {color fur-white species bear}

    # validateInstance after default ctor.
    set p [Pet new set age 12]
    assertState $p {color fur-black age 12}

    # validateInstance reject.
    Pet method validateInstance {} {
        if {$age < 1} {error "age required"}
    }
    assertError {age required} {
        set p [Pet new]
    }
}
