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

set ::brochureDefaultName broc

class BrochurePet Pet {
    # comment, and a blank line.

    # variable substitution.
    r brochureName $::brochureDefaultName

    # multi-line braced string default value.
    # this string should have exactly 8 leading spaces in the indentation before the left paren,
    # 4 leading spaces in the indentation before the right brace,
    # and no trailing spaces after the right brace or the right paren.
    # if the editor or source code version control system messes with the whitespace
    # e.g. by replacing spaces with tabs etc., tests could fail.
    r brochure {
        (Empty brochure text)
    }

    # subcommand.
    r brochurePages [dict create page1 landscape]

    # multi-line subcommand.
    r brochurePics  [list  \
        a.jpg  \
        b.jpg  \
        c.jpg  \
    ]

    # calculation.
    #r totalObjects $( [dict size $brochurePages] + [llength $brochurePics] )
        # previously defined variables are not available yet because the class isn't
        # complete and available for use yet.
        # for that kind of sequential buildup, use a constructor instead.
    r totalLen1 $( [string length $::brochureDefaultName] * 3 )

    # multi-line calculation.
    # Jim doesn't support those using the $() syntax.  use expr instead.
    r totalLen2 [expr  \
        [string length $::brochureDefaultName]  \
        * 3  \
    ]

    # subcommand with braced multi-line arg, often used for calculation.
    r totalLen3 [expr {
        [string length $::brochureDefaultName]
        * 3
    }]

    # quoted string default value.
    r quoted1 "  (brochure $::brochureDefaultName)  "

    # multi-line quoted string default value.
    #quoted2 "
    #    (brochure $::brochureDefaultName)
    #"
    # those are not supported in this version due to a bug in 'info complete'.
    # https://github.com/msteveb/jimtcl/issues/181
    #TODO: import the fix in Jim source and re-test.

    # no default value
    r emptyString
}

