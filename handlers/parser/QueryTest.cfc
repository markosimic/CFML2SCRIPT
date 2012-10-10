component extends="mxunit.framework.TestCase" 
{
	function parse(){
		var samplefile = getDirectoryFromPath(getCurrentTemplatePath()) & "/SampleCFC.cfc";
		var regex = new RegEx();
		var code = fileRead(samplefile);
		var matches = regex.RegMatches("(?i)<cfquery\s[^<]*?>[\s\S]*?</cfquery>", code, true);
		var CFScriptQueries = [];
		for (match in matches){
			arrayAppend(CFScriptQueries, new QueryParser(match.string).toCFScript());
		}	
		
		assertTrue(
		(
			CFScriptQueries[1].indexOf("queryService = new Query") != -1 && 
			CFScriptQueries[2].indexOf("getResult();") != -1
		), "Queries did not translate to CFSCript properly.");	
	}
	
	
	function parseStoreProc(){
		var samplefile = getDirectoryFromPath(getCurrentTemplatePath()) & "/SampleCFC.cfc";
		var regex = new RegEx();
		var code = fileRead(samplefile);
		var matches = regex.RegMatches("(?i)<cfstoredproc\s[^<]*?>[\s\S]*?</cfstoredproc>", code, true);
		var CFScriptSPs = [];
		for (match in matches){
			arrayAppend(CFScriptSPs, new StoredProcParser(match.string).toCFScript());
		}	
		
		assertTrue((CFScriptSPs[1].indexOf("new StoredProc(datasource=""DSN-NAME""")!= -1 && CFScriptSPs[1].indexOf("result = spService.execute();")!= -1), "Stored procedure did not translate to CFSCript properly.");	
	}	
	
	myVar2 = "instance variable";
	this.myVar = "THIS VAR";
	
	private function scopePresendence(myVar3){
		var myVar2 = "local var";
		writeDump(this.myVar);
	}
	
	public function variableScopeStorePresendence(myvar="123"){
		var myVar2 = "var value";
		writeDump(variables.myvar);
		writeDump(myVar);
	}
	
	public function testscopePresendence(){
		scopePresedence("argument");
	}
	
	someVariables = "instance var";
	
	private function assignmentPresendence(someVariables){
		someVariables = someVariables;
		writeDump(someVariables);
	}
	
	public function testAssignmentPresendence(){
		assignmentPresendence("argument value");
	}
	
	public function testCFSDump(){
			var dumpinfo = "";
			
			savecontent variable="dumpinfo" {
				writeDump(this);
			}
			
			writeOutput(dumpinfo);
	}
}