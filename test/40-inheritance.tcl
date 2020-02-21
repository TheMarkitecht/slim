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

    # inherited method using self.
    Pet method cn {} {
        return [$self className]
    }
    class FossilPet Pet {
        r foundIn {South Dakota}
    }
    set p [FossilPet new fromSpecies Tipper dog brown]
    assert {[$p cn] eq {FossilPet}}

    # report on inheritance.
    assert {[FossilPet inherits Pet]}
    class Navy {
        r ships [list]
    }
    assert { ! [FossilPet inherits Navy]}
    class MuseumPet FossilPet {
        r displayAtMuseum FieldNaturalHistory
    }
    assert {[MuseumPet inherits FossilPet]}
    assert {[MuseumPet inherits Pet]}
    assert { ! [MuseumPet inherits Navy]}

    # report on multiple inheritance.
    class PetNavy {MuseumPet Navy} {
        r interspeciesAlliance 1
    }
    assert {[PetNavy inherits MuseumPet]}
    assert {[PetNavy inherits FossilPet]}
    assert {[PetNavy inherits Pet]}
    assert {[PetNavy inherits Navy]}

    # action of multiple inheritance.
    set pn [PetNavy new]
    assert {[$pn cn] eq {PetNavy}}
    assert {[$pn foundIn] eq {South Dakota}}
    assert {[$pn ships] eq [list]}
    assert {[$pn displayAtMuseum] eq {FieldNaturalHistory}}
    assert {[$pn interspeciesAlliance] == 1}
}
