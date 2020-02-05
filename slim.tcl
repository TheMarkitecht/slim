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

# if you get an error such as "Can't load package slim", try setting
#   JIMLIB=.
# in your command line shell environment before running your script.
# on Linux (bash) that looks like:  export JIMLIB=.
# on Windows (cmd.exe) that looks like:  set JIMLIB=.
# that tells jimsh where to search for package scripts.  that's a problem
# more often on Windows, because there, if you don't give the path to the jimsh
# exectutable when you launch jimsh, Jim can't extract the path from Windows OS.
# then it doesn't know where its executable is stored.  then it doesn't know
# to search there.
# instead of "." (meaning the current working directory), you can also give
# an explicit path to the directory where slim.tcl is stored.  you can also
# give a list of paths to search, separated by colons (:).

# this file uses tabs instead of spaces for its indentation.  that helps
# minimize the file size, in case you want to substitute it for Jim's
# oo.tcl when building Jim.

# verify prerequisites.
if {$::tcl_platform(engine) ne {Jim}} {
    error "Interpreter '$::tcl_platform(engine)' can't support slim object-oriented programming.  Slim requires Jim."
}
if { ! [exists -command ref]} {
    error "Jim was built with no support for references.  Can't support slim object-oriented programming."
}

# first eliminate Jim's built-in OO support, if present.
catch {rename class {}}
catch {rename super {}}

# Create a new class $classname, using the given description to initialize
# class variables etc..  These are the initial
# variables which all newly created objects of this class are
# initialised with.
# The description can accept # comments, blank lines, subcommands, and
# variable substitutions.
#
# If a list of baseclasses is given,
# methods and instance variables are inherited.
# The *last* baseclass can be accessed directly with [super]
# Later baseclasses take precedence if the same method exists in more than one
proc class {classname {baseclasses {}} classDescription} {
    # parse class description.  perform substitutions.  extract class vars etc.
    set classvars [dict create]
    set whole {}
    foreach lin [split $classDescription \n] {
        append whole $lin
        if {[info complete $whole]} {
            set whole [string trim $whole]
puts complete=$whole
            if {[llength $whole] < 1} {
                # blank line - ignore.
            } else {
                if {[lindex $whole 0] eq {#}} {
                    # comment - ignore.
                } else {
                    lassign $whole varName value
                    set subName [subst $varName]
puts subName=$subName
                    if {[llength $whole] == 1} {
                        set classvars($subName) {}
                    } elseif {[llength $whole] == 2} {
                        set subValue [subst $value]
puts subValue=$subValue
                        set classvars($subName) $subValue
                    } else {
                        return -code error "In class $classname, extra words after initialization: [string range $whole 0 199]"
                    }
                }
            }
            set whole {}
        } else {
puts incomplete=$whole
            append whole \n
        }
    }

    # inherit from base classes.
    set baseclassvars {}
    foreach baseclass $baseclasses {
        # Start by mapping all methods to the parent class
        foreach method [$baseclass methods] { alias "$classname $method" "$baseclass $method" }
        # Now import the base class classvars
        set baseclassvars [dict merge $baseclassvars [$baseclass classvars]]
        # The last baseclass will win here
        proc "$classname baseclass" {} baseclass { return $baseclass }
    }

    # Merge in the baseclass vars with lower precedence
    set classvars [dict merge $baseclassvars $classvars]
    set vars [lsort [dict keys $classvars]]

    # This is the class dispatcher for $classname
    # It simply dispatches 'classname cmd' to a procedure named {classname cmd}
    # with a nice message if the class procedure doesn't exist
    proc $classname {{cmd new} args} classname {
        if {![exists -command "$classname $cmd"]} {
            return -code error "In class $classname, unknown command or class method \"$cmd\": should be [join [$classname methods] ", "]"
        }
        tailcall "$classname $cmd" {*}$args
    }

    # "new" class method, creates a new instance.  this now accepts any desired arguments,
    # and passes those along to the given ctor method.
    # a default ctor method called 'set' is available; see below.
    proc "$classname new" { {ctorName {}} args } {classname classvars vars} {
        # clone an entire dictionary of instance variables from the existing classvars.
        set instvars $classvars
        if {$ctorName eq {set}} {
            # default constructor.  this one simply memorizes each var given as a name and value pair.
            foreach {n v} $args {set instvars($n) $v}
            set ctorName {}
        }

        # declare the object dispatcher for $classname.
        # Store the classname in both the ref value and tag, for debugging.
        set obj [ref $classname $classname "$classname finalize"]
        # the instance's variables are all stored in the instvars declared here as a static.
        # that means instance variables are inaccessible (by $ substitution) anywhere else
        # except inside a method that was dispatched through here.
        proc $obj {method args} {classname classvars instvars} {
            if { ! [exists -command "$classname $method"]} {
                if {[dict exists $instvars $method]} {
                    # this eliminates the use of "get" method.  simply mention the var name instead.
                    return $instvars($method)
                }
                if {![exists -command "$classname unknown"]} {
                    return -code error "In class $classname, unknown method \"$method\": should be [join [$classname methods] ", "]"
                }
                return ["$classname unknown" $method {*}$args]
            }
            "$classname $method" {*}$args
        }
        # from this point forward, any change to instvars is ignored; they've already been initialized.

        if {$ctorName ne {}} {
            # call the additional constructor method that was specified by ctorName.  its return value is discarded.
            $obj $ctorName {*}$args
        }
        # finally, call the validateCtor method, if it exists.  it can enforce any critical invariants the instance needs.
        #TODO: rename to validateNew
        if {[exists -command "$classname validateCtor"]} {
            $obj validateCtor
        }
        return $obj
    }

    # Finalizer to invoke destructor during garbage collection
    proc "$classname finalize" {ref classname} { $ref destroy }

    # Method creator
    proc "$classname method" {method arglist __body} classname {
        proc "$classname $method" $arglist {__body} {
            # Make sure this isn't incorrectly called without an object
            if {![uplevel exists instvars]} {
                # using 'return -code error' here instead of 'return -code error -level 2', to improve stack traces.
                set meth [lindex [info level 0] 0]
                lassign $meth a b
                return -code error "\"${meth}\" method called with no object instance.  Did you mean \"$a new $b\"?"
            }
            set self [lindex [info level -1] 0]
            # Note that we can't use 'dict with' here because
            # the dict isn't updated until the body completes.
            foreach __ [$self vars] {upvar 1 instvars($__) $__}
            unset __
            eval $__body
        }
    }

    # classMethod creator.  syntactic sugar making it obvious which procs are used as class methods.
    proc "$classname classMethod" {method arglist __body} classname {
        proc "$classname $method" $arglist $__body
    }

    # Other simple class procs
    proc "$classname vars" {} vars { return $vars }
    proc "$classname classvars" {} classvars { return $classvars }
    proc "$classname classname" {} classname { return $classname }
    proc "$classname methods" {} classname {
        lsort [lmap p [info commands "$classname *"] {
            lindex [split $p " "] 1
        }]
    }

    # Pre-defined some instance methods
    $classname method destroy {} { rename $self "" }
    $classname method eval {{locals {}} __code} {
        foreach var $locals { upvar 2 $var $var }
        eval $__code
    }

    return $classname
}

# From within a method, invokes the given method on the base class.
# Note that this will only call the last baseclass given
proc super {method args} {
    upvar self self
    # take for our reference point the class whose method is calling 'super',
    # instead of the class of self.
    # this fixes infinite recursion when an inherited method calls 'super', because
    # it would call itself.  the same bug was present in Jim oo, not only in slim.
    set implementorClass [lindex [lindex [info level -1] 0] 0]
    uplevel 2 [list [$implementorClass baseclass] $method {*}$args]
}

#TODO: see if Jim offers a hook to format the default stack dumps.  maybe override the stackdump command?  then adopt the format from slim's test framework.
