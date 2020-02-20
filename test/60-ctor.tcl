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
    set p [Pet new set age 10 collar large]
    assertState $p {
        name {}
        color black
        species {}
        age 10
        collar large
    }

    # named ctor with parms.
    set p [Pet new fromSpecies Tipper dog brown]
    assertState $p {
        name Tipper
        color brown
        species dog
        age 5
    }

    # named ctor with 'args'.
    class Navy {
        r ships [list]
    }
    Navy method fromShips {args} {
        set ships $args
    }
    set p [Navy new fromShips carrier destroyer frigate]
    assertState $p {ships {carrier destroyer frigate}}

    # inherited named ctor.
    class FossilPet Pet {
        r foundIn {South Dakota}
    }
    set p [FossilPet new fromSpecies Tipper dog brown]
    assertState $p {
        name Tipper
        color brown
        species dog
        age 5
        foundIn {South Dakota}
    }

    # ctor call other ctor.
    class Complex {
        r stuff {}
        r flotsam {}
    }
    Complex method ctorA {} {
        $self ctorB none
        set flotsam all
    }
    Complex method ctorB {amount} {
        set stuff $amount
    }
    set p [Complex new ctorA]
    assertState $p {stuff none flotsam all}

    # ctor call super ctor w/same name.
    FossilPet method fromSpecies {name_ species_ color_ foundIn_} {
        super fromSpecies $name_ $species_ $color_
        set foundIn $foundIn_
    }
    set p [FossilPet new fromSpecies Tipper dog brown Montana]
    assertState $p {
        name Tipper
        color brown
        species dog
        age 5
        foundIn Montana
    }
}
