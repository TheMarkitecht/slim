# slim - an object-oriented programming package for Jim Tcl.
#
# Copyright 2005 Salvatore Sanfilippo <antirez@invece.org>
# Copyright 2008 Steve Bennett <steveb@workware.net.au>
# Copyright 2020 Mark Hubbard <Mark@TheMarkitecht.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials
#    provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# AUTHORS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

    # ctor call base ctor w/same name.
    FossilPet method fromSpecies {name_ species_ color_ foundIn_} {
        baseCall * fromSpecies $name_ $species_ $color_
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
