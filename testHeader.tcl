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

proc bench {label  reps  script} {
    set reps $($reps * $::benchReps)
    puts "$label:  reps=$reps"
    flush stdout
    set beginMs [clock milliseconds]
    uplevel 1 loop attempt 0 $reps \{ $script \}
    set elapseMs $([clock milliseconds] - $beginMs)
    set eachUs $(double($elapseMs) / double($reps) * 1000.0)
    puts [format "    time=%0.3fs  each=%0.1fus" $(double($elapseMs) / 1000.0) $eachUs]
    flush stdout
}
