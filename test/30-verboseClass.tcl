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
        name  color  species  age  collar  \
        brochureName  brochure  brochurePages  brochurePics  \
        totalLen1   totalLen2  totalLen3  quoted1  emptyString
    ]]}
    assert {[$p brochure] eq {
        (Empty brochure text)
    }}
    assert {[$p brochure] ne [string trimleft [$p brochure]]}
    assert {[$p brochure] ne [string trimright [$p brochure]]}
    assert {[$p brochurePages] eq [dict create page1 landscape]}
    assert {[$p brochurePics] eq [list  \
        a.jpg  \
        b.jpg  \
        c.jpg  \
    ]}
    assert {[$p totalLen1] == ( [string length $::brochureDefaultName] * 3 )}
    assert {[$p totalLen2] == [expr  \
        [string length $::brochureDefaultName]  \
        * 3  \
    ]}
    assert {[$p totalLen3] == [expr {
        [string length $::brochureDefaultName]
        * 3
    }]}
    assert {[$p quoted1] eq "  (brochure $::brochureDefaultName)  "}
    assert {[$p emptyString] eq {}}

    # test again with no trailing whitespace after a line continuation backslash.
    set desc "rw a 1 \n rw b {one \\  \ntwo} \n rw c \[list \\\n one \\\n two \]"
    class Backslash $desc
    set b [Backslash new]
    assert {[$b a] == 1}
    assert {[$b b] eq "one \\  \ntwo"}
    assert {[$b c] eq [list one two]}

    # test again with trailing whitespace after (what only appears to be)
    # a line continuation backslash.
    set desc "rw a 1 \n rw b {one \\  \ntwo} \n rw c \[list \\  \n one \\  \n two \]"
    assertError {* too many words at class member 'rw c *} {
        class TrailingWhitespace $desc
    }

    # test again with multiple variables on one line.
    assertError {* too many words at class member 'rw page1 *} {
        class multi {
            rw page1 title; rw page2 content; rw page3 copyright
        }
    }
}
