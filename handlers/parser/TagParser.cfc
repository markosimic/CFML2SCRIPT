component output="true" 
{
	function init(string queryExpression){
		variables.regEx = new RegEx();
		return this;
	}

	struct function parseElementAttributes(attributesExpression){
	
		if (attributesExpression == "") return {};
		
		//var fakeXML = "<elem #attributesExpression#/>";
		var attributeNamesPattern = "\s*([\w\d]+)\s*=\s*";
		var attributeNames = regEx.RegMatches(attributeNamesPattern, attributesExpression, true);
		var attributes = {};
		var attributeValue = "";
		
		var i = 1;
		
		var previousName = "";
		var previousNamePosition = "";
		
		var name = "";
		var currentNamePosition = "";
		
		
		for (var i = 1; i <= arrayLen(attributeNames); i++){
			match = attributeNames[i];
			name = trim(match.sub[1]);
			
			currentNamePosition = {
				start = match.start, 
				end = match.end
			};
			
			if (i == 1) {
				previousNamePosition = {
					start = match.start, 
					end = match.end
				};
				previousName = name;
				
				if(arrayLen(attributeNames) == 1){
					attributeValue = extractValue(
						attributesExpression, 
						{start = match.end, end = match.end},
						{start = len(attributesExpression), end = len(attributesExpression)}
					);
					attributes[previousName] = attributeValue;
					break;
				}
				
				continue;
			}
			else{
				attributeValue = extractValue(attributesExpression, previousNamePosition, currentNamePosition);
				attributes[previousName] = attributeValue;
				if (i < arrayLen(attributeNames)){
					previousNamePosition = {
						start = match.start, 
						end = match.end
					};
				}
				previousName = name;
			}
		}
		
		if (i > 1){
			attributeValue = extractValue(attributesExpression, {start = 0, end = currentNamePosition.end}, {start = len(attributesExpression), end = 0});
			attributes[previousName] = attributeValue;		
		}
		
		return attributes;
	}
	
	string function extractValue(code, previousNamePosition, currentNamePosition, attributeNames){
		var length = currentNamePosition.start-previousNamePosition.end;
		if (length < 0){
			throw("Length cannot be negative value! currentNamePosition.start: #currentNamePosition.start#, previousNamePosition.end: #previousNamePosition.end#, code: #code#");
		}
		var value = trim(mid(code, previousNamePosition.end, length));
		value = trimSufficientCharacters(value);
		return value;
	}
	
	private string function trimSufficientCharacters(text) {
		var string = trim(text);
		
		if (string == "") return string;
		
		if (left(string, 1) == "="){
			if (len(string) == 1) return "";
			string = right(string, len(string)-1);
			string = trim(string);
		}
		
		if (left(string, 1) == """" || left(string, 1) == "'"){
			if (len(string) == 1) return "";
			string = right(string, len(string)-1);
		}
		
		if (right(string, 1) == """" || right(string, 1) == "'"){
			if (len(string) == 1) return "";
			string = left(string, len(string)-1);
		}
		
		
		return string;
	}
	
	string function structToKeyValuePairList(struct structure){
		return new utilities.Structure().toList(argumentCollection = arguments);
	}
		
}