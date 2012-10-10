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

	lengthBeforeConversion = len(fileread(path));
	
	code = new parser.Converter(path).execute();
	
	lengthAfterConversion = len(code);
	 
	backupFile(path);
	
	fileWrite(path, code, "utf-8");
	
	dialogMesssage = "Number of characters before conversion: #lengthBeforeConversion##chr(10)#
	Number of characters after conversion: #lengthAfterConversion##chr(10)#
	Less: #(lengthBeforeConversion - lengthAfterConversion)# chars = #numberFormat((1-lengthAfterConversion/lengthBeforeConversion)*100, ".99")#%";
	dialogStatus = "information";
	
	/*
	TODO:
	CFINVOKE
	*CFQUERY -> new Query()
	CFDIRECTORY -> DirectoryCreate, DirectoryDelete, DirectoryList, and DirectoryRename
	CFFILE -> FileDelete, FileSeek, FileSkipBytes, and FileWriteLine
	CFIMAGE -> The Image functions
	CFOUTPUT Query="" -> for...
	
	<cfimport path="..." => import "";
	
	CFLOOP Query="" -> for...
	CFloop list="URL,Form" index="iScope" -> for (;i++,iScope=...) 
	ftp
	http
	mail
	pdf
	dbinfo
	imap
	pop
	ldap
	feed
	*/
</cfscript>

<cfheader name="Content-Type" value="text/xml">
<response status="<cfoutput>#dialogStatus#</cfoutput>" showresponse="true">
	<ide message="<cfoutput>#HTMLEditFormat(dialogMesssage)#</cfoutput>" />
</response>