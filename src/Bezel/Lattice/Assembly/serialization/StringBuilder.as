package Bezel.Lattice.Assembly.serialization
{
    import flash.utils.ByteArray;

    /**
     * ...
     * @author Chris
     */
    internal class StringBuilder
    {
        private var buf:ByteArray;
        private var filename:String;

        public function StringBuilder(filename:String)
        {
            this.filename = filename;
            buf = new ByteArray();
        }

        public function put(s:String):void
        {
            buf.writeUTFBytes(s);
        }

        public function newLine():void
        {
            buf.writeUTFBytes("\n");
        }

        public function save(obj:Object):void
        {
            buf.position = 0;
            obj[filename] = buf.readUTFBytes(buf.length);
            buf.length = buf.position = 0;
        }
    }
}
