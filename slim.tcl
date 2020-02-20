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

# Create a new class $className, using the given definition to initialize
# class variables etc..  These are the initial
# variables which all newly created objects of this class are
# initialised with.
# The definition can accept # comments, blank lines, subcommands, and
# variable substitutions.
#
# If a list of baseclasses is given,
# methods and instance variables are inherited.
# The *last* baseclass can be accessed directly with [super]
# Later baseclasses take precedence if the same method exists in more than one
proc class {className {baseclasses {}} classDefinition} {
    {memberRe {^(\S+)\s+(\S+)(.*)$}}
} {
    # parse class definition.  perform substitutions.  extract class vars etc.
    set classVars [dict create]
    set implicitAccess [list]
    set implicitMutate [list]
    set whole {}
    foreach lin [split $classDefinition \n] {
        append whole $lin
        if {[info complete $whole]} {
            set whole [string trim $whole]
            if {$whole eq {}} {
                # blank line - ignore.
            } elseif {[string range $whole 0 0] eq {#}} {
                # comment - ignore.
            } else {
                # use a regex to parse a variable definition.  this approach doesn't support
                # a variable name of more than one word.  but those aren't helpful in ordinary
                # source code anyway.  classes are generally defined statically, not dynamically.
                # the valueExpr, however, is often multiple words, e.g. subcommands.
                if { ! [regexp $memberRe $whole junk cmd nameExpr valueExpr]} {
                    return -code error "syntax error at class member '[string range $whole 0 20]'"
                }
                if {$cmd in {read r readwrite rw private p}} {
                    # variable declaration.
                    set valueExpr [string trim $valueExpr]
                    if {$valueExpr eq {}} {
                        set valueExpr {{}}
                    }
                    try {
                        set name [subst $nameExpr]
                    } on error {errMsg errDic} {
                        return -code error -errorinfo $errDic(-errorinfo) \
                            "while evaluating variable name in '[string range $whole 0 20]': $errMsg"
                    }
                    # call eval to invoke the Tcl interpreter on the many words of the valueExpr.
                    try {
                        eval "set value $valueExpr"
                    } on error {errMsg errDic} {
                        return -code error -errorinfo $errDic(-errorinfo) \
                            "maybe too many words at class member '[string range $whole 0 20]': $errMsg"
                    }
                    dict set classVars $name $value
                    if {$cmd in {read r readwrite rw}} {
                        lappend implicitAccess $name
                    }
                    if {$cmd in {readwrite rw}} {
                        lappend implicitMutate $name
                    }
                } else {
                    return -code error "invalid class member '[string range $whole 0 20]'"
                }
            }
            set whole {}
        } else {
            append whole \n
        }
    }

    # inherit from base classes.
    set baseClassVars {}
    proc "$className baseclass" {} { return {} }
    foreach baseclass $baseclasses {
        # Start by mapping all methods to the parent class
        foreach method [$baseclass methods] { alias "$className $method" "$baseclass $method" }
        # Now import the base class classVars
        set baseClassVars [dict merge $baseClassVars [$baseclass classVars]]
        # The last baseclass will win here
        proc "$className baseclass" {} baseclass { return $baseclass }
    }

    # Merge in the baseclass vars with lower precedence
    set classVars [dict merge $baseClassVars $classVars]
    set vars [lsort [dict keys $classVars]]

    # This is the class dispatcher for $className
    # It simply dispatches 'className cmd' to a procedure named {className cmd}
    # with a nice message if the class procedure doesn't exist
    proc $className {{cmd new} args} className {
        if {![exists -command "$className $cmd"]} {
            return -code error "In class $className, unknown command or class method \"$cmd\": should be [join [$className methods] ", "]"
        }
        tailcall "$className $cmd" {*}$args
    }

    # "new" class method, creates a new instance.  this now accepts any desired arguments,
    # and passes those along to the given ctor method.
    # a default ctor method called 'set' is available; see below.
    proc "$className new" { {ctorName {}} args } {className classVars vars} {
        # clone an entire dictionary of instance variables from the existing classVars.
        set instvars $classVars
        if {$ctorName eq {set}} {
            # default constructor.  this one simply memorizes each var given as a name and value pair.
            foreach {n v} $args {set instvars($n) $v}
            set ctorName {}
        }

        # declare the object dispatcher for $className.
        # Store the className in both the ref value and tag, for debugging.
        set obj [ref $className $className "$className finalize"]
        # the instance's variables are all stored in the instvars declared here as a static.
        # that means instance variables are inaccessible (by $ substitution) anywhere else
        # except inside a method that was dispatched through here.
        proc $obj {method args} {className classVars instvars} {
            if { ! [exists -command "$className $method"]} {
                if {![exists -command "$className unknown"]} {
                    return -code error "In class $className, unknown method \"$method\": should be [join [$className methods] ", "]"
                }
                return ["$className unknown" $method {*}$args]
            }
            "$className $method" {*}$args
        }
        # from this point forward, any change to instvars is ignored; they've already been initialized.

        if {$ctorName ne {}} {
            # call the additional constructor method that was specified by ctorName.  its return value is discarded.
            $obj $ctorName {*}$args
        }
        # finally, call the validateInstance method, if it exists.  it can enforce any critical invariants the instance needs.
        if {[exists -command "$className validateInstance"]} {
            $obj validateInstance
        }
        return $obj
    }

    # Finalizer to invoke destructor during garbage collection
    proc "$className finalize" {ref className} { $ref destroy }

    # Method creator
    proc "$className method" {method arglist __body} className {
        proc "$className $method" $arglist {__body} {
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
            unset -nocomplain __
            eval $__body
        }
    }

    # classProc creator.  syntactic sugar making it obvious which procs are used as class methods.
    proc "$className classProc" {procName arglist __body} className {
        proc "$className $procName" $arglist $__body
    }

    # Other simple class procs
    proc "$className vars" {} vars { return $vars }
    # classVars returns only the DEFAULT values, not the instance's CURRENT values.
    proc "$className classVars" {} classVars { return $classVars }
    proc "$className className" {} className { return $className }
    proc "$className methods" {} className {
        lsort [lmap p [info commands "$className *"] {
            lrange $p 1 end
        }]
    }
#TODO: support classprocs list.
#TODO: rename all built-in functionality to camel-case convention.

    # Pre-defined some instance methods
    $className method destroy {} { rename $self "" }
    $className method eval {{locals {}} __code} {
        foreach var $locals { upvar 2 $var $var }
        eval $__code
    }

    # define bare accessor methods to get instance vars.  doing so here avoids
    # an additional step during each method dispatch.
    foreach var $implicitAccess {
        proc "$className $var" {} "uplevel 1 set instvars($var)"
    }
    # define mutator method to set instance vars.  it has to be one method, not one per var,
    # because multi-word method names aren't supported by the object's dispatcher.
    proc "$className set" {var value} {className implicitMutate} {
        if {$var ni $implicitMutate} {
            return -code error -level 2 "In class $className, instance variable \"$var\" is not writable from outside the instance."
        }
        uplevel 1 set instvars($var) $value
    }

    return $className
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
