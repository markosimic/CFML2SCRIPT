component extends="mxunit.framework.TestCase"{

	function parseElementAttributes(){
		var parser = new TagParser();
		
		var parsedText = parser.parseElementAttributes("from=""##Application.SomeValue##""
			to=""##Application.WebmasterFullEMail##""
			cc=""Marko Simic <marko.simic@gmail.com>""
			iswatchmode=""FALSE""
			subject=""##application.translate('vs_title')##: ##application.translate('vs_key')## ##(This.IsGuidedTourRegistration? application.translate('vs_filmTour'):application.translate('vs_key2'))##""
			body=""##MailBody##""");
		assert(parsedText.cc == "Marko Simic <marko.simic@gmail.com>" && parsedText.iswatchmode == "FALSE", "Text not parsed well.");
	} 
	
	function parseElementAttributes_PerformanceIssue(){
		var parser = new TagParser();
		var parsedText = parser.parseElementAttributes("from=""##Application.WebmasterEMail##""
				to=""##person.emailAddress()##""
				bcc=""##Application.WebmasterFullEMail##, Marko Simic <marko.simic@gmail.de>""
				iswatchmode=""FALSE""
				subject=""##translate.getLabel('vs_givitTitle')##: ##translate.getText(""mail"", ""guidedTourInvitationSubject"", this.Language)##""
				body=""##MailBody##""");
		debug(parsedText);
		//assert(parsedText.bcc == "##Application.WebmasterFullEMail##, Marko Simic <marko.simic@gmail.de>" && parsedText.body == "##MailBody##", "Text not parsed well.");
	}	
	
	
	function parseElementAttributes_singleMatch(){
		var parser = new TagParser();
		var parsedText = parser.parseElementAttributes(" suppresswhitespace=""no"" ");
		debug(parsedText);
		//assert(parsedText.bcc == "##Application.WebmasterFullEMail##, Marko Simic <marko.simic@gmail.de>" && parsedText.body == "##MailBody##", "Text not parsed well.");
	}	
	

}