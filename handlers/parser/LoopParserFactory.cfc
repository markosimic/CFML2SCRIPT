component 
{
	public any function init(){
		return this;
	}

	public any function create(Loop loop){
		parser = "";
		switch (loop.getType()){
			case types.index:
				parser = new LoopIndexParser(loop);
				break;
			case types.conditional:
				parser = new LoopConditionalParser(loop);
				break;
			case types.datetimeindex:
				parser = new LoopDatetimeIndexParser(loop);
				break;
			case types.query:
				parser = new LoopQueryParser(loop);
				break;
			case types.list:
				parser = new LoopListParser(loop);
				break;
			case types.array:
				parser = new LoopArrayParser(loop);
				break;
			case types.file:
				parser = new LoopFileParser(loop);
				break;
			case types.collection:
				parser = new LoopCollectionParser(loop);
				break;	
		}
		
		return parser;
	}
}