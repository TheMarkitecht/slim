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

    # created a unique reference?
    assert {$p in [info references]}

    # supports className?
    assert {[$p className] eq {Pet}}

    # supports baseClasses?
    assert {[Pet baseClasses] eq {}}

    # supports vars list and has correct vars?
    assert {[lsort [Pet instanceVarsList]] eq [lsort [list name color species age collar]]}

    # has correct default values?
    set expected {
        name {}
        color black
        species {}
        age 0
        collar {}
    }
    assertState $p $expected

    # supports methods list and has correct methods?
    assert {[lsort [Pet methods]] eq [lsort [list  \
        className destroy eval set  \
        age collar color fromSpecies makeTag name older species txt]]}

    # supports classProcs list and has correct classProcs?
    assert {[lsort [Pet classProcs]] eq [lsort [list  \
        baseClasses classProc classProcs finalize inherits instanceVarsList  \
        method methods new templateVarsDict]]}

    # method call ok?
    assert {[$p older] == 1}

    # method's modifications to instance vars are retained?
    assert {[$p older] == 2}

    # next instance has a different identity unique from the last one?
    set t [Pet new]
    assert {$t ne $p}

    # modifying p instance var didn't modify template vars for t?
    assertState $t $expected

    # wrong arguments throws error?
    assertError {wrong # args: should be "Pet _method_older"} {
        $p older tooMuch
    }

    # variable fetch through implicit bare accessor method ok?
    assert {[$p color] eq {black}}

    # nonexistent method throws error?
    assertError {In instance of Pet, unknown method "junk": should be *} {
        $p junk
    }
}
