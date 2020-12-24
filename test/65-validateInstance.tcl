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
