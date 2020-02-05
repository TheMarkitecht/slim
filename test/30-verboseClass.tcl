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
    setup BrochurePet

    set p [BrochurePet new]
    assert {[lsort [$p vars]] eq [lsort [list \
        name  color  species  age  \
        brochureName  brochure  brochurePages  brochurePics  \
    ]]}
    assert {[llength [$p brochurePics]] == 3}
    assert {[$p brochure] ne [string trimleft [$p brochure]]}
    assert {[$p brochure] ne [string trimright [$p brochure]]}

    set desc "a 1 \n b {one \\  \ntwo} \n c \[list \\  \n one \\  \n two \]"
    puts $desc
    class TrailingWhitespace $desc
    set t [TrailingWhitespace new]
    assert {[$t a] == 1}
    assert {[$t b] == {one two}}
    assert {[$t c] == [list one two]}
}
