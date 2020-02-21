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
        baseClasses classProc classProcs finalize instanceVarsList  \
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
