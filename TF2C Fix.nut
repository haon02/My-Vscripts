class Vector4D {
	x = 0.0
	y = 0.0
	z = 0.0
	w = 0.0
}
class Vector2D {
	x = 0.0
	y = 0.0
}

realPrint <- print
print_indent <- 0

function print( text )
{
	for ( local i = print_indent; i > 0; --i )
	{
		realPrint( "  " )
	}
	realPrint( text )
}

function printl( text )
{
	return print( text + "\n" );
}

function Msg( text )
{
	return print( text );
}

function Assert( b, msg = null )
{
	if ( b )
		return;
		
	if ( msg != null )
	{
		throw "Assertion failed: " + msg;
	}
	else
	{
		throw "Assertion failed";
	}
}

function developer()
	return 0

if ( developer() > 0 )
{
	Documentation <-
	{
		classes = {}
		functions = {}
		instances = {}
	}


	function RetrieveNativeSignature( nativeFunction )
	{
		if ( nativeFunction in NativeFunctionSignatures )
		{
			return NativeFunctionSignatures[nativeFunction]
		}
		return "<unnamed>"
	}
	
	function RegisterFunctionDocumentation( func, name, signature, description )
	{
		if ( description.len() )
		{
			local b = ( description[0] == '#' );
			if ( description[0] == '#' )
			{
				local colon = description.find( ":" );
				if ( colon == null )
				{
					colon = description.len();
				}
				local alias = description.slice( 1, colon );
				description = description.slice( colon + 1 );
				name = alias;
				signature = "#";
			}
		}
		Documentation.functions[name] <- [ signature, description ]
	}

	function Document( symbolOrTable, itemIfSymbol = null, descriptionIfSymbol = null )
	{
		if ( typeof( symbolOrTable ) == "table" )
		{
			foreach( symbol, itemDescription in symbolOrTable )
			{
				Assert( typeof(symbol) == "string" )
				
				Document( symbol, itemDescription[0], itemDescription[1] );
			}
		}
		else
		{
			printl( symbolOrTable + ":" + itemIfSymbol.tostring() + "/" + descriptionIfSymbol );
		}
	}
	
	function PrintHelp( string = "*", exact = false )
	{
		local matches = []
		
		if ( string == "*" || !exact )
		{
			foreach( name, documentation in Documentation.functions )
			{
				if ( string != "*" && name.tolower().find( string.tolower() ) == null )
				{
					continue;
				}
				
				matches.append( name ); 
			}
		} 
		else if ( exact )
		{
			if ( string in Documentation.functions )
				matches.append( string )
		}
		
		if ( matches.len() == 0 )
		{
			printl( "Symbol " + string + " not found" );
			return;
		}
		
		matches.sort();
		
		foreach( name in matches )
		{
			local result = name;
			local documentation = Documentation.functions[name];
			
			printl( "Function:    " + name );
			local signature;
			if ( documentation[0] != "#" )
			{
				signature = documentation[0];
			}
			else
			{
				signature = GetFunctionSignature( this[name], name );
			}
			
			printl( "Signature:   " + signature );
			if ( documentation[1].len() )
				printl( "Description: " + documentation[1] );
			print( "\n" ); 
		}
	}
}
else
{
	function RetrieveNativeSignature( nativeFunction ) { return "<unnamed>"; }
	function RegisterFunctionDocumentation( func, name, signature, description ) {}
	function Document( symbolOrTable, itemIfSymbol = null, descriptionIfSymbol = null ) {}
	function PrintHelp( string = "*", exact = false )
	{
		printl( "You must have started the script VM in developer mode to use this. Start a map/the app with '-dev'" );
	}
}

::_PublishedHelp <- {}
function AddToScriptHelp( scopeTable )
{
	foreach (idx, val in scopeTable )
	{
		if (typeof(val) == "function")
		{
			local helpstr = "scripthelp_" + idx
			if ( ( helpstr in scopeTable ) && ( ! (helpstr in ::_PublishedHelp) ) )
			{
				RegisterFunctionDocumentation( val, idx, GetFunctionSignature( val, idx ), scopeTable[helpstr] )
				::_PublishedHelp[helpstr] <- true
				printl("Registered " + helpstr + " for " + val.tostring)
			}
		}
	}
}


function VSquirrel_OnCreateScope( name, outer )
{
	local result;
	if ( !(name in outer) )
	{
		result = outer[name] <- { __vname=name, __vrefs = 1 };
		result.setdelegate( outer );
	}
	else
	{
		result = outer[name];
		result.__vrefs += 1;
	}
	return result;
}

function VSquirrel_OnReleaseScope( scope )
{
	scope.__vrefs -= 1;
	if ( scope.__vrefs < 0 )
	{
		throw "Bad reference counting on scope " + scope.__vname;
	}
	else if ( scope.__vrefs == 0 )
	{
		delete scope.getdelegate()[scope.__vname];
		scope.__vname = null;
		scope.setdelegate( null );
	}
}