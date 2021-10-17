package Bezel.Lattice.Assembly.serialization
{
    /**
     * ...
     * @author Chris
     */
    public class SourceFile
    {
        public var name:String;
        public var arguments:Vector.<String>;
        public var data:String;

        public var parent:SourceFile;

        public var filePosition:uint;
        public var currentPos:uint;
        public var shift:uint;

        public function SourceFile(name:String, data:String, arguments:Vector.<String> = null)
        {
            this.name = name;
            this.data = data.slice();
            this.arguments = arguments;

            this.filePosition = 0;
            this.shift = 0;
            this.parent = null;
        }

        public function get position():FilePosition
        {
            return new FilePosition(this, filePosition + shift);
        }

        public function get positionStr():String
        {
            var offset:uint = filePosition + shift;
            var line:uint = 1;
            var lineStart:uint = 0;

            for (var i:int = 0; i < data.length; i++)
            {
                if (i == offset)
                {
                    return name + "(" + line + "," + (i-lineStart+1) + ")";
                }
                if (data.charAt(i) == '\n')
                {
                    line++;
                    lineStart = i;
                }
            }
            return name + "(???)";
        }

        public function get front():String
        {
            return this.filePosition >= data.length ? "" : data.charAt(this.filePosition);
        }

        public function popFront():void
        {
            this.filePosition++;
        }
    }
}
