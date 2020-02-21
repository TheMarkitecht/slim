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

# Create a new class $className, using the given definition to determine "template
# variables" etc..  Template variables are the initial variables which all newly
# created instances of this class are constructed with.
#
# During instance construction,
# a copy of the template variables is made specifically for that instance.  That copy
# is called the "instance variables".  Instance variables are the only variables
# that are automatically accessible inside instance methods.  Any other variables
# set by a method body are ordinary Tcl variables.  That means they are local, and
# are lost after the method returns.
#
# Template variables themselves are not generally useful after the class is defined;
# they're only for constructing a new instance.
#
# slim doesn't support any concept of "class variables" as seen in some other OOP
# languages such as Java: https://en.wikipedia.org/wiki/Class_variable
# Those would exist outside of any instance, exactly once regardless of how many
# instances exist.
#
# Likewise, slim doesn't support anything called a "class method".  Instead those are called
# "classProc".  That prevents them being confused with "methods", meaning instance methods.
#
# The class definition can accept # comments, blank lines, variable substitutions,
# and subcommands.  Variable substitutions and subcommands may be used in either the
# name or value of a template variable.  If so, those are evaluated at the time of
# class definition, not at instance construction.  To evaluate them at the time of
# instance construction instead, move them to the body of a constructor.
#
# If a list of one or more baseClasses is given, instance methods and
# template variables are inherited from those.  Their methods can be accessed with [baseCall].
# Later baseClasses take precedence if the same method exists in more than one.
proc class {className {baseClasses {}} classDefinition} {
    {memberRe {^(\S+)\s+(\S+)(.*)$}}
} {
    # parse class definition.  perform substitutions.  extract template vars etc.
    set tpVars [dict create]
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
                # use a regex to parse a template variable definition.  this approach doesn't support
                # a nameExpr of more than one word.  but those aren't helpful in ordinary
                # source code anyway.  classes are generally defined statically, not dynamically.
                # the valueExpr, however, is often multiple words, e.g. subcommands.
                if { ! [regexp $memberRe $whole junk cmd nameExpr valueExpr]} {
                    return -code error "syntax error at class member '[string range $whole 0 20]'"
                }
                if {$cmd in {read r readwrite rw private p}} {
                    # template variable definition.
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
                    dict set tpVars $name $value
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
    set baseTpVars {}
    foreach baseClass $baseClasses {
        # Start by mapping all methods and classProcs to the base class
        foreach method [$baseClass methods] {
            alias "$className _method_$method" "$baseClass _method_$method"
        }
        foreach cp [$baseClass classProcs] {
            alias "$className $cp" "$baseClass $cp"
        }
        # Now import the base class template vars
        set baseTpVars [dict merge $baseTpVars [$baseClass templateVarsDict]]
    }

    # Merge in the base class template vars with lower precedence
    set tpVars [dict merge $baseTpVars $tpVars]
    set instanceVarsList [lsort [dict keys $tpVars]]

    # define the class dispatcher for $className
    # It simply dispatches 'className cmd' to a procedure named {className cmd}
    # with a nice message if the class procedure doesn't exist.
    proc $className {{cmd new} args} className {
        if { ! [exists -command "$className $cmd"]} {
            if { ! [exists -command "$className unknown"]} {
                return -code error "In class $className, unknown classProc \"$cmd\": should be [join [$className methods] ", "]"
            }
            tailcall "$className unknown" $cmd {*}$args
        }
        tailcall "$className $cmd" {*}$args
    }

    # "new" class method, creates a new instance.  this now accepts any desired arguments,
    # and passes those along to the given ctor method.
    # a default ctor method called 'set' is available; see below.
    proc "$className new" { {ctorName {}} args } {className tpVars instanceVarsList} {
        # clone an entire dictionary of instance variables from the existing tpVars.
        set instanceVarsDict $tpVars
        if {$ctorName eq {set}} {
            # default constructor.  this one simply memorizes each var given as a name and value pair.
            foreach {n v} $args {set instanceVarsDict($n) $v}
            set ctorName {}
        }

        # create a reference as the unique identity of the instance.
        # Store the className in both the ref value and tag, for debugging.
        set ins [ref $className $className "$className finalize"]

        # define the instance dispatcher for $ins.
        # the instance's variables are all stored in the instanceVarsDict defined here as a static.
        # that means instance variables are inaccessible (by $ substitution) anywhere else
        # except inside a method that was dispatched through here.
        # methods and classProcs both are defined to the interp with two-word names, the first being $className.
        # but they require different dispatchers ($className or $ins) due to the dispatcher's name.
        # after dispatch, methods expect to find $self and then bind its instance variables to locals.
        # classProcs don't use an instance.  however, classProcs can be invoked OK by the instance dispatcher
        # due to their identical naming convention and argument convention.
#TODO: correct that naming comment for latest version.
        # note that we can't use tailcall here; it prevents the use of statics that are required.
        proc $ins {method args} {className instanceVarsDict instanceVarsList} {
            if { ! [exists -command "$className _method_$method"]} {
                if { ! [exists -command "$className _method_unknown"]} {
                    return -code error "In instance of $className, unknown method \"$method\": should be [join [$className methods] ", "]"
                }
                return ["$className _method_unknown" $method {*}$args]
            }
            "$className _method_$method" {*}$args
        }
        # from this point forward, any change to instanceVarsDict is ignored; they've already been
        # copied into the dispatcher's static variable.

        if {$ctorName ne {}} {
            # call the additional constructor method that was specified by ctorName.  its return value is discarded.
            $ins $ctorName {*}$args
        }
        # finally, call the validateInstance method, if it exists.  it can enforce any critical invariants the instance needs.
        if {[exists -command "$className _method_validateInstance"]} {
            $ins validateInstance
        }
        return $ins
    }

    # Finalizer to invoke destructor during garbage collection
    proc "$className finalize" {ref className} { $ref destroy }

    # Method creator.  methods can be added to a class at any time.
    # even so, methods remain uniform for every instance of a class, just like classProcs do.
    # that means old instances are never left out; they can use the newest methods.
    proc "$className method" {method arglist __body} className {
        proc "$className _method_$method" $arglist {__body} {
            # Make sure this isn't incorrectly called without an instance.
            if {![uplevel 1 exists instanceVarsDict]} {
                # using 'return -code error' here instead of 'return -code error -level 2', to improve stack traces.
                set meth [lindex [info level 0] 0]
                lassign $meth a b
                return -code error "\"${meth}\" method called with no object instance.  Did you mean \"$a new $b\"?"
            }
            # find self by extracting it from the call to the instance dispatcher, 1 frame up.
            # this can't be passed as a static because it's different for each call.
            # and it shouldn't be passed as an ordinary argument because that disturbs the method's
            # arg list, making stack traces look strange.
#TODO: try again to pass self as an ordinary argument, for speed.  note: that will prevent instance dispatcher invoking a classProc.
            set self [lindex [info level -1] 0]
            # bind all of self's instance variables to local variables in the method body.
            # Note that we can't use 'dict with' here because
            # the dict isn't updated until the body completes.
            foreach __  [uplevel 1 set instanceVarsList] {upvar 1 instanceVarsDict($__) $__}
            unset -nocomplain __
            eval $__body
        }
    }

    # classProc creator.  using this makes it obvious which procs are class members.
    # it also allows slim to report methods and classProcs separately.
    proc "$className classProc" {procName arglist __body} className {
        proc "$className $procName" $arglist $__body
    }

    # define some built-in classProcs.
    proc "$className instanceVarsList" {} instanceVarsList { return $instanceVarsList }
    proc "$className templateVarsDict" {} tpVars { return $tpVars }
    # methods and classProcs lists are always computed dynamically, because methods
    # and classProcs can be added to a class at any time.
    proc "$className methods" {} className {
        lsort [lmap m [info commands "$className _method_*"] {
            string range [lindex $m 1] 8 end
        }]
    }
    proc "$className classProcs" {} className {
        lsort [lmap p [info commands "$className *"] {
            if {[string match "$className _method_*" $p]} continue
            lrange $p 1 end
        }]
    }
    proc "$className baseClasses" {} baseClasses { return $baseClasses }
#TODO: add test cases for multiple inheritance.
#TODO: support inheritance test.  implement as method inherits {className}.
# recursive, not iterative, due to multiple inheritance.  include test cases for that.
# that will involve storing the complete list of base classes, which might not be done so far.
    # define some built-in instance methods.
    $className method destroy {} { rename $self "" }
    $className method eval {{locals {}} __code} {
        foreach var $locals { upvar 2 $var $var }
        eval $__code
    }
    proc "$className _method_className" {} className { return $className }

    # define bare accessor methods to get instance vars.  doing so here avoids
    # an additional step during each method dispatch.
    foreach var $implicitAccess {
        proc "$className _method_$var" {} "uplevel 1 set instanceVarsDict($var)"
    }
    # define mutator method to set instance vars.  it has to be one method, not one per var,
    # because multi-word method names aren't supported by the instance's dispatcher.
    proc "$className _method_set" {var value} {className implicitMutate} {
        if {$var ni $implicitMutate} {
            return -code error -level 2 "In instance of $className, instance variable \"$var\" is not writable from outside the instance."
        }
        uplevel 1 set instanceVarsDict($var) $value
    }

    return $className
}

# From within a method, invokes the given method of the given base class.
# That class must be one of the base classes of the class that defined the current method.
# Otherwise this returns an error.
# If "*" or empty string is given as the base class, then the list of base classes is scanned;
# the right-most one that actually supports the method is called.
proc baseCall {baseClass method args} {
#TODO: see if this upvar can be eliminated, or if it's required to pass 'self' along to the base class method.
    upvar self self
    # take for our reference point the class whose method is calling 'baseCall',
    # instead of the class of self.
    # this fixes infinite recursion when an inherited method calls 'baseCall', because
    # it would call itself.  the same bug was present in Jim oo, not only in slim.
    set implementorClass [lindex [lindex [info level -1] 0] 0]
    set allBc [$implementorClass baseClasses]
    if {$baseClass in { * {} }} {
        set baseClass __
        foreach c $allBc {
            if {[exists -command "$c _method_$method"]} {set baseClass $c}
        }
        if {$baseClass eq {__}} {
            return -code error "In instance of $implementorClass, no base class implements method $method"
        }
    } elseif { ! [exists -command "$baseClass _method_$method"]} {
        return -code error "Base class $baseClass does not implement method $method"
    }
    uplevel 2 [list $baseClass _method_$method {*}$args]
}

#TODO: see if Jim offers a hook to format the default stack dumps.  maybe override the stackdump command?  then adopt the format from slim's test framework.
