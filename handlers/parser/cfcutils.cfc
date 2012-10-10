component{
	string function absoluteToDotPath(required string cfcAbsPath){		var refTemplFactory = "";
		var objJavaFile = "";
		var strDotPath = "";
		var servertype = server.coldfusion.productname;
		switch (lcase(servertype)){
			case "railo": //railo
				strDotPath = contractPath(cfcAbsPath);
				strDotPath = right(strDotPath,len(strDotPath)-1); // strip leading slash
				strDotPath = left(strDotPath,len(strDotPath)-4); // remove file extension
				strDotPath = replace(strDotPath,"/",".",'all'); // replace slash with dot
			break;
			case "coldfusion server": //adobe
				refTemplFactory = createObject('java','coldfusion.runtime.TemplateProxyFactory');
				objJavaFile = createObject('java','java.io.File').init(arguments.cfcAbsPath);
				strDotPath = refTemplFactory.getFullName(objJavaFile, getPageContext(), false);
			break;
		}
		return strDotPath;
	}
}