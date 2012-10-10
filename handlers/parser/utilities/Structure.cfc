component 
{
	string function toList(struct structure){
		var key = "";
		var keyValuePairList = "";
		for (key in structure){
			keyValuePairList &= trim(key) & " = " & """" & ToString(trim(structure[key])) & """, ";
		}
		if (keyValuePairList != "")
			keyValuePairList = left(keyValuePairList, len(keyValuePairList)-2);
		
		return keyValuePairList;
	}
}