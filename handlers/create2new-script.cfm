<cfsetting showdebugoutput="false">

<cfscript>
	void function backupFile(filePath){
		fileCopy(filePath, filePath & ".bak");
	}
	
	if (isDefined("ideeventinfo")){
		data = xmlParse(ideeventinfo);
		path = data.event.ide.projectview.resource.xmlAttributes['path'];
	}
	else{
		path = url.path;
	}

	code = new parser.Converter(path).convertScriptCreateObjectToNew();
	
	backupFile(path);
	
	fileWrite(path, code, "utf-8");
	
	dialogMesssage = "Done!";
	dialogStatus = "information";
</cfscript>

<cfheader name="Content-Type" value="text/xml">
<response status="<cfoutput>#dialogStatus#</cfoutput>" showresponse="true">
	<ide message="<cfoutput>#HTMLEditFormat(dialogMesssage)#</cfoutput>" />
</response>