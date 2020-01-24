
# slim
# provides object-oriented programming support in Jim Tcl.
# this is an evolution of Jim's built-in oo package.

# verify prerequisites.
package require initjimsh
if { ! [exists -command ref]} {
	error "Jim was built with no support for references.  Can't support slim object-oriented programming."
}

# first eliminate Jim's built-in OO support, if present.
catch {
	rename class {}
	rename super {}
}

# Create a new class $classname, with the given
# dictionary as class variables. These are the initial
# variables which all newly created objects of this class are
# initialised with.
#
# If a list of baseclasses is given,
# methods and instance variables are inherited.
# The *last* baseclass can be accessed directly with [super]
# Later baseclasses take precedence if the same method exists in more than one
proc class {classname {baseclasses {}} classvars} {
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
			return -code error "$classname, unknown command \"$cmd\": should be [join [$classname methods] ", "]"
		}
		tailcall "$classname $cmd" {*}$args
	}

	# "new" class method, creates a new instance.  this now accepts any desired arguments,
	# and passes those along to the given ctor method.  
	# a default ctor method is available; see below.
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
#puts "in:[info level 0]"
#catch {puts "	uplevel:[uplevel 1 {info level 0}]" }
			# Make sure this isn't incorrectly called without an object
			if {![uplevel exists instvars]} {
				# using 'error' here instead of 'return -code error -level 2', to improve stack traces.
				error "\"[lindex [info level 0] 0]\" method called with no object"
			}
			set self [lindex [info level -1] 0]
			# Note that we can't use 'dict with' here because
			# the dict isn't updated until the body completes.
			foreach __ [$self vars] {upvar 1 instvars($__) $__}
			unset __
			eval $__body
		}
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
	uplevel 2 [$self baseclass] $method {*}$args
}
