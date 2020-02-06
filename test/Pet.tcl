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

class Pet {
    name {}
    color black
    species {}
    age 0
}

Pet method fromSpecies {name_ species_ color_} {
    assert {$name eq {}}
    assert {$color eq {black}}
    assert {$age eq {}}
    set name $name_
    set species $species_
    set color $color_
    age = 5
}

Pet method txt {} {
    return "$classname $name is a $color $species."
}

Pet method older {} {
    return [incr age]
}

Pet method makeTag {} {
    return [$self txt]
}
