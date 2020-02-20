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

    set p [Pet new]

    # variable write through implicit mutator method ok?
    # extra spacing is used here to ensure Jim parses and matches
    # that command name OK after slim declares it.
    assert {[$p   collar] eq {}}
    assert {[$p   set   collar   small] eq {small}}
    # and is retained?
    assert {[$p   collar] eq {small}}

    # illegal variable write through implicit mutator method throws error?
    assertError {In class Pet, instance variable "age" is not writable from outside the instance.} {
        $p set age 10
    }

    # ctors can use implicit get/set.  but not sure why you'd ever do that...
    # it's easier to set vars directly.
    Pet method fromShelter {} {
        set color red
        $self set collar [$self color]
    }
    set p [Pet new fromShelter]
    assertState $p [list color red collar red]
}
