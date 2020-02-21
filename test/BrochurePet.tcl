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

