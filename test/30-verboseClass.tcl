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
    setup BrochurePet

    set p [BrochurePet new]
    assert {[lsort [BrochurePet instanceVarsList]] eq [lsort [list \
        name  color  species  age  collar  \
        brochureName  brochure  brochurePages  brochurePics  \
        totalLen1   totalLen2  totalLen3  quoted1  emptyString
    ]]}
    assert {[$p brochure] eq "\n        (Empty brochure text)\n    "}
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
