component 
{
	function init(path){
		variables.path = arguments.path; 
		variables.code = fileRead(path);
		variables.regEx = new RegEx();
		variables.tagParser = new TagParser();
		variables.structure = new utilities.Structure();
		return this;
	}
	
	public string function execute(){ 
	
		code = convertCustomTags(code);
	
		code = stripSelfClosingSlashes(code);
	
		code = replaceFunctionSignatures(code);

		code = convertHeader(code);
		
		code = convertOutput(code);
		
		code = convertOperators(code);
		
		code = convertBodyTags(code);

		code = convertInlineQueries(code);
	
		code = convertStoredProcedures(code);

		code = convertLocation(code);
		
		code = convertFlowControl(code);
		
		code = convertCFMLFunctions(code);
		
		code = adjustments(code);
		
		code = convertScriptCreateObjectToNew(code);
		
		return code;	
	}
	
	private string function stripSelfClosingSlashes(code){
		code = code.ReplaceAll("(?i)(<cf[^>]+)/>", "$1>");
		return code;
	}
	
	
	private string function replaceFunctionSignatures(code){
		var newsignutures = functionSignatures(componentFunctions(path));
		var markupSignaturePattern = "";
		var functionElement = "";
		var args = "(?i)<cfargument[\s\S]*?>\s*";
		code = code.replaceAll(args, "");
		var i = 1;
		
		for (functionName in newsignutures){
			functionElement = "<cffunction[^<]*?name\s*=\s*[""|']#functionName#[""|'][^<]*?>\s*";
			code = rereplaceNoCase(code, functionElement, newsignutures[functionName] & chr(10) & chr(9));
			i++;
		}
		
		code = regEx.RegReplace("(?i)</cffunction>", code, "}",true);
		
		return code;
	}
	
	
	struct function functionSignatures(array functions){
		var functionMetadata = {};
		var signatures = {};
		for (i=1;i <= arrayLen(arguments.functions);i++){
			functionmetadata = arguments.functions[i];
	
			if (!isScriptFunction(functionmetadata)){
				signatures[functionmetadata.name] = createFunctionSignature(functionmetadata);	
			}
		}
		return signatures;
	}
	
	private boolean function isScriptFunction(functionMetadata){
		var regexPatternForMarkup = "<cffunction[\s\S]*?(name\s*=\s*[""|']#functionMetadata.name#[""|'])";
		var matches = REFindNoCase(regexPatternForMarkup, code, 0, true);
		
		return (matches.pos[1] == 0 && matches.len[1] == 0);
	}	
	
	private string function createFunctionSignature(struct functionMetadata){
		var signature = "";
		
		if (structKeyExists(functionMetadata, "access")){
			signature &= "#functionMetadata.access# "; 
		}
		
		if (structKeyExists(functionMetadata, "returntype")){
			signature &= "#functionMetadata.returntype# "; 
		}
		
		signature &= "function #functionMetadata.name#(";
		
		signature &= parameterSignature(functionMetadata);
		
		signature &= ")";
		
		for (meta in functionMetadata){
			try{
			if (listfindnocase("access,returntype,name,parameters,resolvedArgType", meta) == 0)
				signature &= " " & lcase(meta) & " = """ & functionMetadata[meta] & """";
			}
			catch(any ex){
				writeDump(functionMetadata);
				writeDump(functionMetadata[meta]);
				writeDump(ex);
				rethrow;
				abort;
			}
		}
		
		signature &= "{";
		return signature;
	}	
	
	private function parameterSignature(functionMetadata){
		var signature = "";
		if (structKeyExists(functionMetadata, "parameters") && arrayLen(functionMetadata.parameters) > 0){
			var parameter = {};
			var i = 1;
			var signature = "";
			var numberOfParemters = arrayLen(functionMetadata.parameters);
			for (i = 1;i <= arrayLen(functionMetadata.parameters);i++){
				parameter = functionMetadata.parameters[i];

				if (structKeyExists(parameter, "required") && parameter.required == true){
					signature &= "required "; 
				}
				
				if (structKeyExists(parameter, "type")){
					signature &= "#parameter.type# "; 
				}
				
				signature &= parameter.name;
				
				if (structKeyExists(parameter, "default")){
					defaultValueExpression = parameter.default;
					if (defaultValueExpression == "[runtime expression]"){
						defaultValueExpression = findParameterDefaultValue(functionMetadata.name, parameter);
					}
					signature &= "=""#defaultValueExpression#"""; 
				}
				
				if (i < numberOfParemters)
					signature &= ", ";
			}
		}
		return signature;	
	}	
	
	private function findParameterDefaultValue(functionName, parameter){
		var regexPatternForMarkup = "<cffunction[\s\S]*?name\s*=\s*[""|']#functionName#[""|'][\s\S]*?<cfargument[\s\S]*?name\s*=\s*[""|']#parameter.name#[""|'][\s\S]*?default\s*=\s*[""|'](.*?)[""|'][\s\S]*?>";
		var matches = REFindNoCase(regexPatternForMarkup, code, 0, true);
		var defaulValueExpression = "";
		
		if (!(matches.pos[1] == 0 && matches.len[1] == 0)){
			defaulValueExpression = mid(code, matches.pos[2], matches.len[2]);
		}
		
		return defaulValueExpression;
	}
	
	string function maskUnsupportedTags(){
		var unsupportedTags = "(</?(?:cfprocessinfdirective[\s\S]*?>)";
	}
	
	array function componentFunctions(pathToCFC){
		var dotpath = new cfcutils().absoluteToDotPath(pathToCFC);
		var metadata = getComponentMetadata(dotpath);
		var functions = [];
		if (structKeyExists(metadata, "functions"))
			functions = metadata.functions;
		return functions;
	}	

	private string function convertHeader(code){
		var patterns = [];
		var replacementStrings = [];
			
		arrayAppend(patterns, "(?i)<cfcomponent([\s\S]*?)>");
		arrayAppend(replacementStrings, "component$1{");
		
		arrayAppend(patterns, "(?i)<cfinterface([\s\S]*?)>");
		arrayAppend(replacementStrings, "interface$1{");
	
		arrayAppend(patterns, "(?i)</cfcomponent>");
		arrayAppend(replacementStrings, "}");	
		
		arrayAppend(patterns, "(?i)</cfinterface>");
		arrayAppend(replacementStrings, "}");	
		
		for (i = 1;i <= arrayLen(patterns);i++){
			code = code.ReplaceAll(patterns[i], replacementStrings[i]);
		}
		return code;		
	}	
	

	private string function convertOutput(code){
		var outputPattern = "(?i)<cfoutput>([\s\S]+?)</cfoutput>";
		code = regEx.RegReplace(outputPattern, code, "#chr(10)#writeOutput(""$1"");#chr(10)#", true);
		
		return code;	
	}
	
	private string function convertCustomTags(code){
		var openTag = "(?i)(\t*?)<cf_([^\s>]+)([\s\S]*?)\/*>";
		code = regEx.RegReplace(openTag, code, "$1/*CONVERSION WARNING#chr(10)#$1Custom tag needs to be replaced!*/#chr(10)#$1CUSTOMTAG_$2 $3;", true);
		
		var closingTag = "(?i)</cf_([^\s>]+?)>";
		code = regEx.RegReplace(closingTag, code, "END_OF_CUSTOMTAG_$1;", true);
		
		return code;
	}	
	
	private string function convertOperators(code){
		var cfmlMetaPattern = "(?i)(?:<cf(property|param|return|abort|exit|include|rethrow|break|continue))([\s\S]*?)[\/]?>";
		code = regEx.RegReplace(cfmlMetaPattern, code, "$1$2;",true);
		
		var cfmlSet = "(?i)<cfset\s?([\s\S]*?)/?>";
		code = regEx.RegReplace(cfmlSet, code, "$1;",true);
		
		code = regEx.RegReplace("(?i)\s*<\s*?\/*?\s*?(?:cfscript|cfsilent)>", code, "",true);
		
		return code;
	}
	
	private string function convertBodyTags(code){
		code = regEx.RegReplace("(?i)<cf(lock|savecontent|transaction|thread)([\s\S]*?)>", code, "$1$2 {#chr(10)#",true);
		code = regEx.RegReplace("(?i)</cf(lock|savecontent|transaction|thread)>", code, "}",true);
		
		return code;
	}	

	private string function convertInlineQueries(code){
		var regex = new RegEx();
		var matches = regex.RegMatches("(?i)<cfquery\s[^<]*?>[\s\S]*?</cfquery>", code, true);
		var CFScriptQueries = [];
		for (match in matches){
			code = replaceNoCase(code, match.string, new QueryParser(match.string).toCFScript());
		}
		
		return code;
	}
	
	private string function convertStoredProcedures(code){
		var regex = new RegEx();
		var matches = regex.RegMatches("(?i)<cfstoredproc\s[^<]*?>[\s\S]*?</cfstoredproc>", code, true);
		var CFScriptSPs = [];
		for (match in matches){
			code = replaceNoCase(code, match.string, new StoredProcParser(match.string).toCFScript());
		}
		
		return code;
	}	

	private string function convertLocation(code){
		var matches = regEx.RegMatches("(?i)<cflocation([\s\S]*?)>", code, true);
		if (arraylen(matches) > 0){
			for (match in matches){
				locationAttributes = structure.toList(tagParser.parseElementAttributes(match.sub[1]));
				code = replacenocase(code, "<cflocation#match.sub[1]#>", "location(#locationAttributes#);");
			}
		}
		
		return code;
	}

	
	private string function convertCFMLFunctions(code){
		var cfmlFunctionPattern = "(?i)<cf([^\s>\_]+)\s+([\w\d]+?\s*=\s*['""][\s\S]+?['""])/?>";
		var matches = regEx.RegMatches(cfmlFunctionPattern, code, true);
		var match = {};
		var cfscript = "";
		var attribs = {};
		var attributeText = "";
		
		fileWrite("c:\ttt.txt", code);
		
		for (match in matches){
			var attributeText = match.sub[2];
			attribs = structure.toList(tagParser.parseElementAttributes(attributeText));
			cfscript = "#match.sub[1]#(#attribs#);";
			code = replacenocase(code, match.string, cfscript);
		}
		
		return code;
	}

	private string function convertFlowControl(code){	
		var patterns = [];
		var replacementStrings = [];
	
		arrayAppend(patterns, "(?i)<!---([\s\S]*?)--->");
		arrayAppend(replacementStrings, "/*$1*/");
	
		arrayAppend(patterns, "(?i)<cfif([\s\S]*?)>");
		arrayAppend(replacementStrings, "if ($1){");
		
		arrayAppend(patterns, "(?i)<cfelseif([\s\S]*?)>");
		arrayAppend(replacementStrings, "}else if ($1){");
	
		arrayAppend(patterns, "(?i)<cfelse>");
		arrayAppend(replacementStrings, "}else{");
	
		arrayAppend(patterns, "(?i)</cfif>");
		arrayAppend(replacementStrings, "}");
	
		arrayAppend(patterns, "(?i)<loop\s*?condition\s*=\s*[""|'](.*?)[""|']\s*?>");
		arrayAppend(replacementStrings, "while($1){");
		
		arrayAppend(patterns, "(?i)<cfloop([\s\S]*?)>");
		arrayAppend(replacementStrings, "loop ($1){");
		
		arrayAppend(patterns, "(?i)</cfloop>");
		arrayAppend(replacementStrings, "}");
		
		arrayAppend(patterns, "(?i)<cfswitch expression=[""|'](.*?)[""|']>");
		arrayAppend(replacementStrings, "switch ($1){");
	
		arrayAppend(patterns, "(?i)</cfswitch>");
		arrayAppend(replacementStrings, "}");
	
		arrayAppend(patterns, "(?i)<cfcase value=[""']([^,]*?)[""']>");
		arrayAppend(replacementStrings, "case ""$1"":");
		
		arrayAppend(patterns, "(?i)<cfcase value=[""']([\s\S]*?)[""']>");
		arrayAppend(replacementStrings, "{mocase}case ""$1"":{/mocase}");
	
		arrayAppend(patterns, "(?i)</cfcase>");
		arrayAppend(replacementStrings, "break;");
		
		arrayAppend(patterns, "(?i)<cfdefaultcase>([\s\S]*?)</cfdefaultcase>");
		arrayAppend(replacementStrings, "default:$1");
	
		arrayAppend(patterns, "(?i)<cftry>([\s\S]*?)</cftry>");
		arrayAppend(replacementStrings, "try{$1");
	
		arrayAppend(patterns, "(?i)<cfcatch(.*?)>([\s\S]*?)</cfcatch>");
		arrayAppend(replacementStrings, "}catch(any ex){$2}");
		
		arrayAppend(patterns, "(?i)<cfthrow([\s\S]*?)>");
		arrayAppend(replacementStrings, "throw($1);");
		
		arrayAppend(patterns, "(?i)<cfset(.*)createobject\([""']component[""|']\s*,\s*[""|'](gms\.cfc\..*?)[""|']\s*?\)\.init\((.*?)\)\s*[\/]*>");
		arrayAppend(replacementStrings, "$1new $2($3);");

		for (i = 1;i <= arrayLen(patterns);i++){
			code = code.ReplaceAll(patterns[i], replacementStrings[i]);
		}
		
		code = convertMultiOptionCases(code);
		
		return code;
	}
	
	string function convertMultiOptionCases(required string code){
		var cases = regEx.RegMatches("(?:\{mocase\})([\s\S]*?)(?:\{\/mocase\})", code, true);
		var matchedCase = "";
		for (matchedCase in cases){
			var statement = matchedCase.sub[1];
			var pattern = "case ""([\s\S]*)""";
			var valueMatch = regEx.RegMatches(pattern, statement, true);
			var values = valueMatch[1].sub[1];
			var convertedCode = "";
			var val = "";
			var i = 1;
			for (i = 1; i <= listLen(values); i++){
				val = listGetAt(values, i);
				convertedCode &= "case """ & removeSeparators(val) & """: ";  
			}
			code = replaceNoCase(code, matchedCase.string, convertedCode);
		}
		
		return code;
	}	
	
	private function removeSeparators(string text){
		if (text == "") return "";
		return text.replaceAll("[\r\n\t]","");
	}
	
	string function convertCFMLCreateObjectToNew(code){
		var patternForCreateTagWithInit = "(?i)<cfset(.*)createobject\([""']component[""|']\s*,\s*[""|'](gms\.cfc\..*?)[""|']\s*?\)\.init\((.*?)\)\s*[\/]*>";
		code = code.ReplaceAll(patternForCreateTagWithInit, "<cfset$1new $2($3)>");
		var patternForCreateTagWOInit = "(?i)<cfset(.*)createobject\([""']component[""|']\s*,\s*[""|'](gms\.cfc\..*?)[""|']\s*?\)\s*[\/]*>";
		code = code.ReplaceAll(patternForCreateTagWOInit, "<cfset$1new $2()>");
		return code;
	}
	
	string function convertScriptCreateObjectToNew(code){
		var patternForCreateWithInit = "(?i)createobject\([""']component[""|']\s*,\s*[""|'](.*?)[""|']\s*?\)\.init\((.*?)\)";
		code = code.ReplaceAll(patternForCreateWithInit, "new $1($2)");
		var patternForCreateWOInit = "(?i)createobject\([""']component[""|']\s*,\s*[""|'](.*?)[""|']\s*?\)";
		code = code.ReplaceAll(patternForCreateWOInit, "new $1()");
		return code;
	}	
	
	private function adjustments(){
		//Collection loops
		var pattern = "(\t*?)loop\s*\(\s*collection\s*=\s*[""']*\##*(.*?)\##*[""']*\s*item\s*=\s*[""']*(.*?)[""']\s*\)\s*\{";
		var replacementString = "$1var $3 = "";#chr(13)##chr(10)#$1for ($3 in $2) {";
		code = code.ReplaceAll(pattern, replacementString);
		
		//For loop
		pattern = "(\t*)loop\s*\(\s*from\s*=\s*[""']*\##*(.*?)\##*[""']*\s*to\s*=\s*[""']*\##*(.*?)\##*[""']*\s*index\s*=\s*[""'](.*?)[""']*\)\s*\{";
		replacementString = "$1var $4 = """";#chr(13)##chr(10)#$1for ($4 = $2;$4 <= $3; $4++) {";
		code = code.ReplaceAll(pattern, replacementString);
		
		//Array loop
		pattern = "(\t*)loop\s*\(\s*array\s*=\s*[""']*\##*(.*?)\##*[""']*\s*index\s*=\s*[""']*(.*?)[""']*\)\s*\{";
		replacementString = "$1for (var elementIndex = 1; elementIndex <= arrayLen($2)); elementIndex++){#chr(13)##chr(10)#$1#chr(9)#$3 = $2[elementIndex];";
		code = code.ReplaceAll(pattern, replacementString);
		
		//Query loop
		pattern = "(\t*)loop\s*\(\s*query\s*=\s*[""']*(.*?)[""']*\s*\)\s*\{";
		replacementString = "$1/*Conversion warning!#chr(13)##chr(10)#$1!!!QUERY SCRIPTED!!!#chr(13)##chr(10)#$1Check COLUMN and ROW references!!!#chr(13)##chr(10)##chr(13)##chr(10)#$1*/#chr(13)##chr(10)#$1for (i = 1; i <= $2.recordcount; i++){";
		code = code.ReplaceAll(pattern, replacementString);
		
		//List loop
		pattern = "(\t*)loop\s*\(\s*list\s*=\s*[""']*\##*(.*?)\##*[""']*\s*index\s*=\s*[""']*(.*?)[""']*\)\s*\{";
		replacementString = "$1for(var elementIndex = 1; elementIndex <= listLen($2); elementIndex++){#chr(13)##chr(10)#$1#chr(9)#$3 = listGetAt($2, elementIndex);";
		code = code.ReplaceAll(pattern, replacementString);
		
		//QoQ
		pattern = "(\t*)(queryService\s*=\s*new[\s\S]*?dbtype\s*=\s*[""']query[""'][\s\S]*?\)\s*\;*)";
		replacementString = "$1/*Conversion warning!#chr(13)##chr(10)#$1 QoQ: Set reference to source query (setAttributes(sourceQuery = sourceQuery)). Also do revision of query. Conditional query string must be revised!!!*/#chr(13)##chr(10)#$1$2#chr(13)##chr(10)#$1queryService.setAttributes(sourceQuery = sourceQuery);";
		code = code.ReplaceAll(pattern, replacementString);

		return code;
	}
}