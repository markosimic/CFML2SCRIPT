component {

	function init(string queryExpression){
		variables.queryExpression = arguments.queryExpression;
		variables.regEx = new RegEx();
		variables.tagParser = new TagParser();
		return this;
	}
	

	string function toCFScript(){
		var CFScript = "";
	
		var queryPattern = "(?i)<cfquery(\s[^<]*?)>([\s\S]*?)</cfquery>";
		var matches = regEx.RegMatches(queryPattern, queryExpression, true);
		
		if (arrayLen(matches) != 1 || arraylen(matches[1].sub) != 2){
			throw (message = "Invalid query expression: ""#queryExpression#""");
		}
		
		var queryProps = matches[1].sub[1];
		var queryString = matches[1].sub[2];
		
		var queryAttributes = tagParser.parseElementAttributes(queryProps);
		var queryAttributesAsString = tagParser.structToKeyValuePairList(queryAttributes);
		var queryName = queryAttributes.name;
			
		CFScript = "queryService = new Query(#queryAttributesAsString#);" & chr(10);
			
		//extract queryparams
		var queryParamsPattern = "<cfqueryparam([^<]*?)[\/]?>";
		matches = regEx.RegMatches(queryParamsPattern, queryString, true);
		
		
		var paramPropsAsString = "";
		for (match in matches){
			queryString = replaceNoCase(queryString, match.string, "?");	
			paramPropsAsString = tagParser.structToKeyValuePairList(tagParser.parseElementAttributes(match.sub[1]));
			CFScript &= "queryService.addParam(#paramPropsAsString#);" & chr(10);
		}
		
		CFScript &= "#queryName# = queryService.execute(sql = ""#queryString#"").getResult();" & chr(10);		
		return CFScript;
	}
	
}
