package Bezel 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.errors.IllegalOperationError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.globalization.DateTimeFormatter;
	import flash.utils.Dictionary;
	
	public class Logger 
	{
		private static var logFile:File;
		private static var logStream:FileStream;
		private static var loggers:Dictionary;
		
		private var id:String;
		
		internal static function init(): void
		{
			logFile = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/Bezel_log.log");
			if(logFile.exists)
				logFile.deleteFile();
			logStream = new FileStream();
			loggers = new Dictionary();
		}
		
		// UglyLog is ugly because I open, write, close the stream every time this method is called
		// This is to guarantee that the messages arrive at the log in case of an uncaught exception
		// TODO probably just add a hook to Main uncaughtErrorHandler to gracefully shut down?
		private static function writeLog(id:String, source:String, message:String): void
		{
			logStream.open(logFile, FileMode.APPEND);
			var df:DateTimeFormatter = new DateTimeFormatter("");
			df.setDateTimePattern("yyyy-MM-dd HH:mm:ss");
			var formattedId:String = id.substring(0, 10);
			formattedId += "               ".substr(0, 10-formattedId.length);
			logStream.writeUTFBytes(df.format(new Date()) + "\t[" + formattedId + "][" + source + "]:\t" + message + "\r\n");
			logStream.close();
		}
		
		public function Logger(identifier:String)
		{
			if (identifier == null || identifier == "")
				throw new ArgumentError("Logger identifier can't be null or empty");
			if (loggers[identifier])
				throw new IllegalOperationError("Constructor should only be called by getLogger! Get your logger instance that way");
			this.id = identifier;
		}
		
		public static function getLogger(identifier:String): Logger
		{
			if (identifier == null || identifier == "")
				throw new ArgumentError("Logger identifier can't be null or empty");
		
			if (loggers[identifier])
				return loggers[identifier];
			else
			{
				loggers[identifier] = new Logger(identifier);
				writeLog("Logger", "getLogger", "Created a new logger: " + identifier);
				return loggers[identifier];
			}
			
		}
		
		public function log(source:String, message:String): void
		{
			writeLog(this.id, source, message);
		}
	}

}