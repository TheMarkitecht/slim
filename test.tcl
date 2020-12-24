#!/usr/bin/env jimsh

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


# automated test framework in this file.

alias f+ file join

proc handleTestError {errMsg errDic} {
    puts "*** ERROR *** Stack trace follows in chronological order:\n[stackdump $errDic(-errorinfo)]\n$errMsg"
    exit 1
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
    $itp eval [list set ::benchReps $::benchReps]
    $itp eval [list source [f+ $::appDir testHeader.tcl]]
    $itp eval [list source [f+ $::testDir $testName.tcl]]
    $itp eval [list source [f+ $::appDir testFooter.tcl]]
    $itp delete
}

########### MAIN SCRIPT ########################
set ::appDir [f+ [pwd] [file dirname [info script]]]
set ::testDir [f+ $::appDir test]

lassign  $::argv  ::testName  ::benchReps
runTest $::testName $::benchReps
