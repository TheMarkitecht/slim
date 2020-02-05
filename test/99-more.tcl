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
}

set todo {
    #TODO: break up this file.

    # test ctor and its parms.
    Pet.new merlin cat white
    # test method can read vars.
    puts [merlin.txt]
    assert {[merlin.txt] eq {Pet merlin is a white cat.}}
    # test method can modify vars.  this was already tested once, in the ctor.
    puts "[merlin.older] [merlin.older] [merlin.older]"
    assert {[merlin.older] == 9}
    # test default setter and getter.
    merlin species devil
    puts [merlin.txt]
    assert {[merlin species] eq {devil}}
    # test a method calling another method.
    assert {[merlin.makeTag] eq {Pet merlin is a white devil.}}

    # test default behavior without ctor.
    class Snake {
        var length
        var _poop stinky
    }
    Snake.new boo length 16
    puts "length [boo length]"

    # test refusing to set/get a nonexistent var
    assert {[catch {boo color black}]}
    puts [lindex [split $::errorInfo \n] 0]
    assert {[catch {boo color}]}
    puts [lindex [split $::errorInfo \n] 0]

    # test refusing to set/get a private var
    assert {[catch {boo _poop black}]}
    puts [lindex [split $::errorInfo \n] 0]
    assert {[catch {boo _poop}]}
    puts [lindex [split $::errorInfo \n] 0]

    # test inheritance of vars and methods, including 'new'.
    class Dog {
        inherit Pet
        var coat fuzzy
        method new {species_ color_ coat_} {
            base.new $species_ $color_
            coat = $coat_
        }
        method txt {} {
            older
            return "[base.txt] with coat $coat."
        }
        method polymorphic {} {
            return [txt]
        }
    }
    Dog.new tipper BullChow brown short
    assert {[tipper baseClass] eq {Pet}}
    assert {[tipper coat] eq {short}}
    assert {[tipper age] == 5}
    puts "[tipper.older] [tipper.older]"
    assert {[tipper age] == 7}
    puts [tipper.txt]
    assert {[tipper.txt] eq {Dog tipper is a brown BullChow. with coat short.}}
    assert {[tipper age] == 9}
    assert {[tipper.polymorphic] eq {Dog tipper is a brown BullChow. with coat short.}}

    # test re-use of an object name.
    class Sum {
        var tot 0
        method add {v} {
            tot := ($tot + $v) % 255
        }
    }
    for {set i 0} {$i < 3} {incr i} {
        Sum.new sum
        sum.add 5
        sum.add 5
        sum.add 5
        assert {[sum tot] == 15}
    }
}
