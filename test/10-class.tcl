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

    # created a reference?
    assert {$p in [info references]}

    # supports classname?
    assert {[$p classname] eq {Pet}}

    # supports baseclass?
    assert {[$p baseclass] eq {}}

    # supports vars list and has correct vars?
    assert {[lsort [$p vars]] eq [lsort [list name color species age collar]]}

    # supports classvars dictionary and has correct classvars?
    set expected {
        name {}
        color black
        species {}
        age 0
        collar {}
    }
puts [sortDic [$p classvars]]
    assertClassVars $p $expected

    # supports methods list and has correct methods?
    assert {[lsort [$p methods]] eq [lsort [list  \
        baseclass classProc classname classvars destroy eval  \
        finalize method methods new set vars  \
        name color species age collar  \
        fromSpecies makeTag older txt]]}

    # method call ok?
    assert {[$p older] == 1}

    # method's modifications to instance vars are retained?
    assert {[$p older] == 2}

    # modifying instance var didn't modify classvars?
    # that's because classvars supplies only the DEFAULT values, not the instance's CURRENT values.
    assertClassVars $p $expected

    # wrong arguments throws error?
    assertError {wrong # args: should be "Pet older"} {
        $p older tooMuch
    }

    # variable fetch through implicit bare accessor method ok?
    assert {[$p color] eq {black}}

    # nonexistent method/variable throws error?
    assertError {In class Pet, unknown method "junk": should be *} {
        $p junk
    }

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
}
