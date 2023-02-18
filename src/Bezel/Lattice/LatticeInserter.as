package Bezel.Lattice
{
    import com.cff.anebe.ir.ASScript;

    /**
     * A higher level view of Lattice patching. Allows insertion of functions and classes.
     * @author Chris
     */
    public interface LatticeInserter
    {
        /**
         * Called by lattice after registering this Inserter with it.
         * @param script The new script that has been inserted. Manipulate it to insert classes, functions, and whatever else is necessary
         */
        function doInsert(script:ASScript):void;
    }
}
