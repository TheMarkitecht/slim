#!/usr/bin/env jimsh

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


# automated test framework in this file.

alias f+ file join

proc handleTestError {errMsg errDic} {
    puts "*** ERROR *** Stack trace follows in chronological order:\n[stackdump $errDic(-errorinfo)]\n$errMsg"
    exit 1
}

proc bench {label  reps  script} {
    #TODO
    puts "$label:  reps=$reps"
    flush stdout
    set beginMs [clock milliseconds]
    uplevel 1 loop attempt 0 $reps \{ $script \}
    set elapseMs $([clock milliseconds] - $beginMs)
    set eachUs $(double($elapseMs) / double($reps) * 1000.0)
    puts [format "    time=%0.3fs  each=%0.1fus" $(double($elapseMs) / 1000.0) $eachUs]
    flush stdout
}

proc runTest {testName benchReps} {
    # each test is run in a dedicated interp so it can't affect any further test.
    puts "========= Begin Test $testName ========================"
    set itp [interp]
    $itp alias f+ f+
    $itp alias handleTestError handleTestError
    $itp alias runTest runTest
    $itp eval [list set ::appDir $::appDir]
    $itp eval [list set ::testDir $::testDir]
    $itp eval [list source [f+ $::appDir testHeader.tcl]]
    $itp eval [list source [f+ $::testDir $testName.tcl]]
    $itp eval [list source [f+ $::appDir testFooter.tcl]]
    $itp delete
}

########### MAIN SCRIPT ########################
set ::appDir [f+ [pwd] [file dirname [info script]]]
set ::testDir [f+ $::appDir test]

lassign  $::argv  testName  benchReps
runTest $testName $benchReps
