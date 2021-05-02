package Bezel 
{
	/**
	 * Bezel's logger: prints out to <game appdata folder>/Local Store/Bezel Mod Loader/Bezel_log.log
	 * @author Hellrage
	 */
	
	import flash.desktop.NativeApplication;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.globalization.DateTimeFormatter;
	import flash.utils.Dictionary;
	
	public class Logger
	{
		private static const logFile:File = Bezel.Bezel.bezelFolder.resolvePath("Bezel_log.log");
		private static var _logStream:FileStream;
		private static var _loggers:Dictionary;
		
		private static function get logStream(): FileStream
		{
			if (_logStream == null)
			{
				_logStream = new FileStream();
				_logStream.open(logFile, FileMode.WRITE);
				NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
			}
			return _logStream;
		}
		
		private static function get loggers(): Dictionary
		{
			if (_loggers == null)
			{
				_loggers = new Dictionary();
			}
			return _loggers;
		}
		
		private var id:String;
		
		private static function onExit(e:Event): void
		{
			if (_logStream != null)
			{
				_logStream.close();
				_logStream = null;
			}
		}

		private static function writeLog(id:String, source:String, message:String): void
		{
			var df:DateTimeFormatter = new DateTimeFormatter("");
			df.setDateTimePattern("yyyy-MM-dd HH:mm:ss");
			var formattedId:String = id.substring(0, 20);
			formattedId += "               ".substr(0, 20-formattedId.length);
			//logStream.writeUTFBytes(df.format(new Date()) + "\t[" + formattedId + "][" + source + "]:\t" + message + "\r\n");
			logStream.writeUTFBytes(df.format(new Date()) + "\t[" + formattedId + "]: " + message + "\r\n");
		}
		
		// Cannot be called
		public function Logger(identifier:String, _blocker:LoggerInstantiationBlocker)
		{
			if (identifier == null || identifier == "")
				throw new ArgumentError("Logger identifier can't be null or empty");
			if (loggers[identifier] || _blocker == null)
				throw new IllegalOperationError("Constructor should only be called by getLogger! Get your logger instance that way");
			this.id = identifier;
		}
		
		/**
		 * Get an instance of a logger that writes to the Bezel log
		 * @param	identifier Name to use in the log file
		 * @return Logger for the given identifier
		 */
		public static function getLogger(identifier:String): Logger
		{
			if (identifier == null || identifier == "")
				throw new ArgumentError("Logger identifier can't be null or empty");
		
			if (loggers[identifier])
				return loggers[identifier];
			else
			{
				loggers[identifier] = new Logger(identifier, new LoggerInstantiationBlocker());
				//writeLog("Logger", "getLogger", "Created a new logger: " + identifier);
				return loggers[identifier];
			}
		}
		
		/**
		 * Writes the given message and source to the Bezel log
		 * @param	source The source to output
		 * @param	message The message to output
		 */
		public function log(source:String, message:String): void
		{
			writeLog(this.id, source, message);
		}
	}

}

// Hack I found online: this is a way to implement singletons.
// While this isn't actually a singleton, it works to make the constructor inaccessible
internal class LoggerInstantiationBlocker {}
