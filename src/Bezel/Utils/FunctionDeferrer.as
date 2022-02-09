package Bezel.Utils
{
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.utils.getTimer;

    import Bezel.bezel_internal;

    /**
     * ...
     * @author Chris
     */
    public class FunctionDeferrer
    {
        private static const instance:FunctionDeferrer = new FunctionDeferrer();
        instance.init();

        // 30FPS
        private const myTimer:Timer = new Timer(1000/30);
        private const functions:Vector.<DeferredFunctionToken> = new <DeferredFunctionToken>[];
        private const newFunctions:Vector.<DeferredFunctionToken> = new <DeferredFunctionToken>[];

        private function init():void
        {
            myTimer.addEventListener(TimerEvent.TIMER, this.onTimer);
        }

        private function onTimer(e:TimerEvent):void
        {
            if (functions.length != 0)
            {
                var currentTime:int = getTimer();
                while (functions.length != 0)
                {
                    var current:DeferredFunctionToken = functions.splice(0, 1)[0];
                    current.func.apply(current.that, current.args);
                    if (current.forceFrame)
                    {
                        e.updateAfterEvent();
                    }
                    if (currentTime + 16 <= getTimer()) // Only use a maximum of about half a frame
                    {
                        break;
                    }
                }
            }
            for each (var newFunction:DeferredFunctionToken in newFunctions)
            {
                functions[functions.length] = newFunction;
            }
            newFunctions.length = 0;

            if (functions.length == 0)
            {
                myTimer.stop();
            }
        }

        /**
         * Defers a function
         * @param func Function to execute. May not be null.
         * @param args Arguments to pass to the function. May not be null.
         * @param that Object to pass as this to the function. May be null.
         * @param forceFrame Whether or not a frame must occur after the function is executed
         */
        public static function deferFunction(func:Function, args:Array, that:* = null, forceFrame:Boolean = false):void
        {
            if (func == null || args == null)
            {
                throw new ArgumentError("Neither func nor args may be null when deferring a function");
            }
            instance.functions[instance.functions.length] = new DeferredFunctionToken(func, that, args, forceFrame);

            instance.myTimer.start();
        }

        /**
         * Defers a function until the next frame or later
         * @param func Function to execute. May not be null.
         * @param args Arguments to pass to the function. May not be null.
         * @param that Object to pass as this to the function. May be null.
         * @param forceFrame Whether or not a frame must occur after the function is executed
         */
        public static function hardDeferFunction(func:Function, args:Array, that:* = null, forceFrame:Boolean = false):void
        {
            if (func == null || args == null)
            {
                throw new ArgumentError("Neither func nor args may be null when deferring a function");
            }
            instance.newFunctions[instance.newFunctions.length] = new DeferredFunctionToken(func, that, args, forceFrame);
            instance.myTimer.start();
        }

        /**
         * Removes all queued functions. Used for cleanup for full and mod-only reload.
         */
        bezel_internal static function clear():void
        {
            instance.myTimer.stop();
            
            instance.functions.length = 0;
        }
    }
}
