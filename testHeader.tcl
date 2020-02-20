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

lappend auto_path $::appDir
package require slim

proc assert {exp} {
    set truth [uplevel 1 [list expr $exp]]
    if { ! $truth} {
        return -code error "ASSERT FAILED: $exp"
    }
}

proc assertError {msgPattern script} {
    try {
        uplevel 1 $script
    } on error {errMsg errDic} {
        if {[string match $msgPattern $errMsg]} {
            return {}
        }
        return -code error "ASSERT FAILED: error did not match expected pattern.  Actual error caught:\n$errMsg\n[stackdump $errDic(-errorinfo)]\n\n"
    }
    return -code error "ASSERT FAILED: expected an error but caught none."
}

proc assertDefaults {obj defaultsDic} {
    assert {[sortDic [$obj instanceDefaultsDict]] eq [sortDic $defaultsDic]}
}

proc assertState {obj state} {
    dict for {n v} $state {
        set actual [$obj $n]
        if {$v ne $actual} {
            return -code error "ASSERT FAILED: expected '$n' = '[string range $v 0 20]' but got '[string range $actual 0 20]'"
        }
    }
}

proc setup {className} {
    source [f+ $::testDir $className.tcl]
}

# sort a dictionary by its keys, so it's comparable.
proc sortDic {dic} {
    set all [list]
    foreach k [lsort [dict keys $dic]] {
        lappend all $k $dic($k)
    }
    return $all
}
