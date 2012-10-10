Developed by: Marko Simic
Email: marko.simic@gmail.com
Blog: itreminder.blogspot.com
Twitter: markosimic

CFML to CFSCript conversion tool
- ColdFusion Builder Plugin -

Assists developer in process of code migration from CFML to CFScript.
When it finishes conversion, in most cases, it will leave your component unusable.
Thus, it requires your attention and detail code review upon completion.
In this process javing your under version control will be very valuable.
ColdFusion Builder may help you too, with detecting syntax errors.
All places, where manual intervention is necessary, are marked with bold comment.
Pay special attention on things that are in TODO list.

TOD0:
	- loop by step is ignored
	- improve patterns to handle better CF-HTML mixes
	- exclude comments from noise reduction calcuation

Requirments:
	- ColdFusion Builder 1.x
	- ColdFusion 9+
	
Hopefully, by time, we'll make it better and more complete, reducing manual work to minimum.
Two more things: This is just an utility and use it at your own risk.

Remove The Noise!