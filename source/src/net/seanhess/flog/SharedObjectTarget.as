package net.seanhess.flog
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.utils.Timer;
	
	import mx.core.mx_internal;
	import mx.logging.targets.LineFormattedTarget;
	
	use namespace mx_internal;
	
	public class SharedObjectTarget extends LineFormattedTarget
	{
		public static const MAX_CHARS:int = 50000; // shooting for 50kbs
		public static const PAGE_SIZE:int = 100; // in lines
		public static const FLUSH_DELAY:int = 1; // in seconds
		
		private var object:SharedObject;
		private var maxSize:int;
		private var size:int
		private var delay:Timer;
		
		public function SharedObjectTarget(name:String="sharedObjectTarget", maxSize:int=MAX_CHARS)
		{
			object = SharedObject.getLocal(name);
			this.maxSize = maxSize;
			this.size = object.size;
			delay = new Timer(FLUSH_DELAY * 1000, 1);
			delay.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function get messages():Array
		{
			if (object.data.messages == null)
				object.data.messages = [];
			
			return object.data.messages;
		}
		
		public function flush():void
		{
			if (object.flush() != SharedObjectFlushStatus.FLUSHED)
				throw new Error("SharedObjectTarget exceeded allowed size");
		}
		
		private function onTimer(event:Event):void
		{
			flush();
		}
		
		override mx_internal function internalLog(message:String):void
		{
			messages.push("\n" + message);
			size += message.length;
			
			if (size > maxSize)
			{
				var oldLines:Array = messages.splice(0, PAGE_SIZE);
				var clearedSize:int = 0;
				for each (var message:String in oldLines)
				clearedSize += message.length;
				
				size -= clearedSize;
			}
			
			delay.reset();
			delay.start();
		}
	}
}