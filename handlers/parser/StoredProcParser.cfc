component {

	function init(string spExpression){
		variables.spExpression = arguments.spExpression;
		variables.regEx = new RegEx();
		variables.tagParser = new TagParser();
		return this;
	}
	

	string function toCFScript(){
		var CFScript = "";
	
		var outparams = [];
		var resultsets = [];
		var spPattern = "(?i)<cfstoredproc(\s[^<]*?)>([\s\S]*?)</cfstoredproc>";
		var match = "";
		var matches = regEx.RegMatches(spPattern, spExpression, true);
		
		if (arrayLen(matches) != 1 || arraylen(matches[1].sub) != 2){
			throw (message = "Invalid query expression: ""#spExpression#""");
		}
		
		var spProps = matches[1].sub[1];
		var spParams = matches[1].sub[2];
		
		var spAttributes = tagParser.parseElementAttributes(spProps);
		var spAttributesAsString = tagParser.structToKeyValuePairList(spAttributes);
			
		CFScript = "spService = new StoredProc(#spAttributesAsString#);" & chr(10);
			
		//extract queryparams
		var spParamsPattern = "<cfprocparam([^<]*?)[\/]?>";
		matches = regEx.RegMatches(spParamsPattern, spParams, true);
		
		var paramPropsAsString = "";
		for (match in matches){
			spParams = replaceNoCase(spParams, match.string & "\s*", "");
			try{
				paramProps = tagParser.parseElementAttributes(match.sub[1]);
			}
			catch(any ex){
				writedump(match.sub[1]);
				writedump(ex);
				abort;
			}
			
			if ((paramProps.type == "out" || paramProps.type == "inout") && structKeyExists(paramProps, "variable")){
				arrayAppend(outparams, paramProps.variable);
			}
			
			paramPropsAsString = tagParser.structToKeyValuePairList(paramProps);
			CFScript &= "spService.addParam(#paramPropsAsString#);" & chr(10);
		}
		
		var spResultsetPattern = "<cfprocresult([^<]*?)[\/]?>";
		matches = regEx.RegMatches(spResultsetPattern, spParams, true);
		
		var paramPropsAsString = "";
		for (match in matches){
			spParams = replaceNoCase(spParams, match.string & "\s*", "");
			paramProps	= tagParser.parseElementAttributes(match.sub[1]);
			
			arrayAppend(resultsets, paramProps.name);
			paramPropsAsString = tagParser.structToKeyValuePairList(paramProps);
			CFScript &= "spService.addProcResult(#paramPropsAsString#);" & chr(10);
		}
		
		CFScript &= "result = spService.execute();" & chr(10);
		for (outparam in outparams){
			CFScript &= "#outparam# =  result.getprocOutVariables().#outparam#;" & chr(10);
		}
		
		for (resultset in resultsets){
			CFScript &= "#resultset# = result.getProcResultSets().#resultset#;" & chr(10);
			
		}
		return CFScript;
	}
	
}
