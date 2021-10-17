package Bezel.Lattice.Assembly.serialization {

    /**
     * ...
     * @author Chris
     */
    public class FilePosition {
        public var file:SourceFile;
        public var offset:uint;

        public function FilePosition(file:SourceFile = null, offset:uint = 0) {
            this.file = file;
            this.offset = offset;
        }

        public function load():SourceFile {
            // if (file.currentPos != file.data.length)
            // {
            //     throw new Error("Not at the end of the SourceFile");
            // }
            file.filePosition = offset;
            return file;
        }
    }
}
