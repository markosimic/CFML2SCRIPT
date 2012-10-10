component accessors="true" {
	property name="loopExpression" default="" type="string";
	property name="attributes" default="#structNew()#" type="struct";
	property name="body" default="" type="string";
	property name="type" default="2" type="numeric";
	
	types = {
		index = 1,
		conditional = 2,
		datetimeindex = 3,
		query = 4,
		list = 5,
		array = 6,
		file = 7,
		collection = 8
	}; 

	any function init(loopExpression){
		variables.loopExpression = loopExpression;
		variables.regEx = new RegEx();
		variables.tagParser = new TagParser();
		parseAttributes();
		parseBody();
		parseType();
		return this;
	}

	private void function parseAttributes(){
		var loopAttributesPattern = "<cfloop([^>]+?)>";
		var matches = regEx.RegMatches(loopAttributesPattern, loopExpression, true);
		setAttributes(tagParser.parseElementAttributes(matches[1].sub[1]));
	}
	
	private void function parseBody(){
		var loopBodyPattern = "<cfloop(?:[^>]+?)>([\s\S]+?)</cfloop>)";
		var matches = regEx.RegMatches(loopBodyPattern, loopExpression, true);
		return matches[1].sub[1];
	}
	
	private void function parseType(){
		var loopAttributes = getAttributes();
		
		if (structKeyExists(loopAttributes, "from") && structKeyExists(loopAttributes, "to") && structKeyExists(loopAttributes, "index")){
			if (isDate(loopAttributes.from) && isDate(loopAttributes.to)){
				setType(types.datetimeindex);
			}
			else {
				setType(types.index);
			}
			return;
		}
		
		if (structKeyExists(loopAttributes, "condition")){
			setType(types.conditional);return;
		}
		
		if (structKeyExists(loopAttributes, "query")){
			setType(types.query);return;
		}
		
		if (structKeyExists(loopAttributes, "list")){
			setType(types.list);return;
		}
		
		if (structKeyExists(loopAttributes, "array")){
			setType(types.array);return;
		}
		
		if (structKeyExists(loopAttributes, "file")){
			setType(types.file);return;
		}
		
		if (structKeyExists(loopAttributes, "collection")){
			setType(types.collection);return;
		}
	}	
	
	public struct function getTypes(){
		return types;
	}	
}
