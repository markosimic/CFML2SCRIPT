component extends="mxunit.framework.TestCase"{

	function initobj(){
		var convert = new Converter(path = "C:\gms\webapp\dev\cfc\registration.cfc");
	}
	
	function execute(){
		var convert = new Converter(path = "C:\gms\webapp\dev\cfc\registration.cfc");
		var convertedvalue = convert.execute();
	}

}


