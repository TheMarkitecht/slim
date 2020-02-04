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

package require slim

# Create a class, the usual bank account, with two instance variables:
class Account {
    balance 0
    name "Unknown"
}

# We have some class methods predefined
puts "---- class Account ----"
puts "Account vars=[Account vars]"
puts "Account methods=[Account methods]"
puts ""

# Create a validation constructor. This can enforce any critical invariants the instance needs.
Account method validateCtor {} {
    if {$balance < 0} {
        error "Can't initialise account with negative balance"
    }
    puts "[$self classname] opening balance $balance is OK."
}

# Now flesh out the class with some methods
# Could use 'Account method' here instead
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
Account method describe {} {
    puts "I am object $self of class [$self classname]"
    puts "My 'see' method returns [$self see]"
    puts "My variables are:"
    foreach i [$self vars] {
        puts "  $i=[set $i]"
    }
}

# Now an instance, initialize some fields
set a [Account new set name "Bob Smith"]

puts "---- object Account ----"
# We can use class methods on the instance too
puts a.vars=[$a vars]
puts a.classname=[$a classname]

# Now object methods
$a deposit 100
puts "deposit 100 -> [$a see]"

$a withdraw 40
puts "withdraw 40 -> [$a see]"

catch {$a withdraw 1000} res
puts "withdraw 1000 -> $res\n"

# Tell me something about the object
$a describe
puts ""

# Now create a new subclass
# Could change the initial balance here too
class CreditAccount Account {
    limit -1000
}

CreditAccount method validateCtor {} {
    # Dummy constructor
    # If desired, manually invoke the baseclass constructor
    super validateCtor
}

# Override the 'withdraw' method to allow overdrawing
CreditAccount method withdraw {amount} {
    if {$balance - $amount < $limit} {error "Sorry $name, that would exceed your credit limit of [expr -$limit]"}
    set balance [- $balance $amount]
}
# Override the 'describe' method, but invoke the baseclass method first
CreditAccount method describe {} {
    # First invoke the base class 'describe'
    super describe
    if {$balance < 0} {
        puts "*** Account is in debit"
    }
}

puts "---- class CreditAccount ----"
puts "CreditAccount vars=[CreditAccount vars]"
puts "CreditAccount methods=[CreditAccount methods]"
puts ""

puts "---- object CreditAccount ----"
set b [CreditAccount new set name "John White"]

puts b.vars=[$b vars]
puts b.classname=[$b classname]

puts "initial balance -> [$b see]"
$b deposit 100
puts "deposit 100 -> [$b see]"

$b withdraw 40
puts "withdraw 40 -> [$b see]"

$b withdraw 1000
puts "withdraw 1000 -> [$b see]"
puts ""

# Tell me something about the object
$b describe
puts ""

# 'eval' is similar to 'dict with' for an object, except it operates
# in its own scope. A list of variables can be imported into the object scope.
# It is useful for ad-hoc operations for which it is not worth defining a method.
set total 0
$a eval total { incr total $balance }
incr total [$b balance]
puts "Total of accounts [$a name] and [$b eval {return "$name (Credit Limit: $limit)"}] is: $total"

# test slim's flexible constructors.
class TeenAccount CreditAccount {
    parent {}
}
# a method name usable as a constructor should start with 'new' just as a convention.
TeenAccount method newFromParent {parent_ name_} {
    set parent $parent_
    set name $name_
    # enforce some arbitrary rules.
    if {[$parent classname] ne {Account}} {
        error "Naughty teen tried to open an account with the wrong parent class."
    }
}
puts "---- object TeenAccount ----"
set tommy [TeenAccount new newFromParent $a {Tommy A.}]
$tommy withdraw 50
puts "withdraw 50 -> [$tommy see]"
$tommy describe
puts "---- object TeenAccount ----"
set daisy [TeenAccount new set parent $a name {Daisy A.}]
$daisy withdraw 75
puts "withdraw 75 -> [$daisy see]"
$daisy describe

# test a slim constructor calling another one in another class.
class Payment {} {
    acct {}
    amt 0
}
Payment method newFromAcct {acct_ amt_} {
    set acct $acct_
    set amt $amt_
}
Payment method describe {} {
    puts "Payment $amt from [$acct name]"
}
class SpendingAccount TeenAccount {
    payments {}
}
SpendingAccount method newWithPmt {amt args} {
    $self newFromParent {*}$args
    lappend payments [Payment new newFromAcct $self $amt]
}
SpendingAccount method describe {} {
    super describe
    foreach p $payments {$p describe}
}
set samir [SpendingAccount new newWithPmt 90 $a {Samir A.}]
$samir describe

# test invoking super ctor's.
SpendingAccount method newFromParent {args} {
    puts "Calling:super newFromParent {*}$args"
    super newFromParent {*}$args
}
set nibiki [SpendingAccount new newWithPmt 35 $a {Nibiki A.}]
$nibiki describe


# Can we find all objects in the system?
# Almost. We can't really distinguish those which aren't real classes.
# This will get all references which aren't simple lambdas.
puts "---- All objects ----"
Account new set name "Terry Green" balance 20
set x [Account]
lambda {} {dummy}
ref blah blah

foreach r [info references] {
    if {[getref $r] ne {}} {
        try {
            $r eval {
                puts [format "Found %14s: Owner: %14s, Balance: %+5d, in object %s" [$self classname] $name $balance $self]
            }
        } on error msg {
            puts "Not an object: $r"
        }
    }
}
unset r

# And goodbye
$a destroy

# Let the garbage collection take care of this one
unset b
collect
