package Bezel.GCL.Events
{
    import com.giab.games.gcl.gs.Main;

    import flash.events.Event;

    public class PostInitiateEvent extends Event
    {
        private var _main:Main;

        /** The Main that just got initiated */
        public function get main():Main
        {
            return _main;
        }

        public override function clone():Event
        {
            return new PostInitiateEvent(main, type, bubbles, cancelable);
        }

        public function PostInitiateEvent(main:Main, type:String, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
            _main = main;
        }
    }
}
