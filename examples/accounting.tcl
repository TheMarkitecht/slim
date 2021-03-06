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

set ::appDir [file join [pwd] [file dirname [info script]]]
lappend auto_path $::appDir
    puts auto_path=$::auto_path
package require slim

# Create a class, the usual bank account, with two instance variables:
class Account {
    p balance 0
    r name "Unknown"
}

# We have some classProcs predefined
puts "---- class Account ----"
puts "Account vars=[Account instanceVarsList]"
puts "Account methods=[Account methods]"
puts ""

# Create a validation constructor. This can enforce any critical invariants the instance needs.
Account method validateInstance {} {
    if {$balance < 0} {
        error "Can't initialise account with negative balance"
    }
    puts "[$self className] opening balance $balance is OK."
}

# Now flesh out the class with some instance methods.
Account method deposit {amount} {
    set balance [+ $balance $amount]
}
Account method see {} {
    set balance
}
Account method withdraw {amount} {
    if {$amount > $balance} {error "Sorry $name, can only withdraw $balance"}
    set balance [- $balance $amount]
}
Account method describe {label} {
    puts "$label I am object $self of class [$self className]"
    puts "My 'see' method returns [$self see]"
    puts "My variables are:"
    foreach i [[$self className] instanceVarsList] {
        set v [set $i]
        if {[string match <reference.* $v]} {
            catch {append v "; name=[$v name]"}
        }
        puts "  $i=$v"
    }
}

# Now an instance, initialize some fields
set a [Account new set name "Bob Smith"]

puts "---- object Account ----"
# We can use classProc's on the instance too.
puts a.vars=[[$a className] instanceVarsList]
puts a.className=[$a className]

# Now instance methods
$a deposit 100
puts "deposit 100 -> [$a see]"

$a withdraw 40
puts "withdraw 40 -> [$a see]"

catch {$a withdraw 1000} res
puts "withdraw 1000 -> $res\n"

# Tell me something about the object
$a describe {}
puts ""

# Now create a new subclass
# Could change the initial balance here too
class CreditAccount Account {
    p limit -1000
}

CreditAccount method validateInstance {} {
    # Dummy constructor
    # If desired, manually invoke the baseClass constructor
    baseCall * validateInstance
}

# Override the 'withdraw' method to allow overdrawing
CreditAccount method withdraw {amount} {
    if {$balance - $amount < $limit} {error "Sorry $name, that would exceed your credit limit of [expr -$limit]"}
    set balance [- $balance $amount]
}
# Override the 'describe' method, but invoke the baseClass method first
CreditAccount method describe {label} {
    # First invoke the base class 'describe'
    baseCall * describe $label
    if {$balance < 0} {
        puts "*** Account is in debit"
    }
}

puts "---- class CreditAccount ----"
puts "CreditAccount vars=[CreditAccount instanceVarsList]"
puts "CreditAccount methods=[CreditAccount methods]"
puts ""

puts "---- object CreditAccount ----"
set b [CreditAccount new set name "John White"]

puts b.vars=[CreditAccount instanceVarsList]
puts b.className=[$b className]

puts "initial balance -> [$b see]"
$b deposit 100
puts "deposit 100 -> [$b see]"

$b withdraw 40
puts "withdraw 40 -> [$b see]"

$b withdraw 1000
puts "withdraw 1000 -> [$b see]"
puts ""

# Tell me something about the object
$b describe {}
puts ""

# 'eval' is similar to 'dict with' for an object, except it operates
# in its own scope. A list of variables can be imported into the object scope.
# It is useful for ad-hoc operations for which a method is undesirable for some reason.
set total 0
$a eval total { incr total $balance }
incr total [$b see]
puts "Total of accounts [$a name] and [$b eval {return "$name (Credit Limit: $limit)"}] is: $total"

# try out slim's flexible constructors.
class TeenAccount CreditAccount {
    p parent {}
}
# a method name usable as a constructor should start with 'from' just as a convention.
TeenAccount method fromParent {parent_ name_} {
    set parent $parent_
    set name $name_
    # enforce some arbitrary rules.
    if {[$parent className] ne {Account}} {
        error "Naughty teen tried to open an account with the wrong parent class."
    }
}
puts "---- object TeenAccount ----"
set tommy [TeenAccount new fromParent $a {Tommy A.}]
$tommy withdraw 50
puts "withdraw 50 -> [$tommy see]"
$tommy describe {}
puts "---- object TeenAccount ----"
set daisy [TeenAccount new set parent $a name {Daisy A.}]
$daisy withdraw 75
puts "withdraw 75 -> [$daisy see]"
$daisy describe {}

# test a slim constructor calling another one in another class.
class Payment {} {
    p acct {}
    p amt 0
}
Payment method fromAcct {acct_ amt_} {
    set acct $acct_
    set amt $amt_
}
Payment method describe {} {
    puts "Payment $amt from [$acct name]"
}
class SpendingAccount TeenAccount {
    p payments {}
}
SpendingAccount method fromPayment {amt args} {
    $self fromParent {*}$args
    lappend payments [Payment new fromAcct $self $amt]
}
SpendingAccount method describe {label} {
    baseCall * describe $label
    foreach p $payments {$p describe}
}
set samir [SpendingAccount new fromPayment 90 $a {Samir A.}]
$samir describe {}

# test invoking base ctor's.
SpendingAccount method fromParent {args} {
    puts "Calling:base fromParent {*}$args"
    baseCall * fromParent {*}$args
}
set nibiki [SpendingAccount new fromParent $a {Nibiki A.}]
$nibiki describe {}


# Can we find all objects in the system?
# Almost. We can't really distinguish those which aren't real classes.
# This will get all references which aren't simple lambdas.
Account new set name "Terry Green" balance 20
set x [Account]
lambda {} {dummy}
ref blah blah

puts "---- All objects ----"
foreach r [lsort [info references]] {
    #if {[getref $r] ne {}}
    if {[catch "$r className"]} {
        puts "Not an object: $r"
    } else {
        try {
            $r eval {
                puts [format "Found %20s: Owner: %14s, Balance: %+5d, in object %s" [$self className] $name $balance $self]
            }
        } on error msg {
            puts "Not an Account: $r"
        }
    }
}
unset r

# And goodbye
$a destroy

# Let the garbage collection take care of this one
unset b
collect

