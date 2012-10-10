component 
{
	function init(string loopExpression){
		loop = new Loop(loopExpression);
		parser = new LoopParserFactory().create(loop);
		return this;
	}
	

	string function toCFScript(){		
		return parser.toCFScript();
	}
	
	private Loop function getLoop(){
		return loop;
	}
}