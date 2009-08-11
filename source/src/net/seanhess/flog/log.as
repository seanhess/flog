package net.seanhess.flog
{
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public function log(message:String, source:String="Main"):void
	{
		var logger:ILogger = Log.getLogger(source);
		logger.info(message);  
	}
}