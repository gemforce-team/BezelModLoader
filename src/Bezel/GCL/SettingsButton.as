package Bezel.GCL
{
    import Bezel.Bezel;

    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    internal class SettingsButton extends MovieClip
    {
        public var plate:MovieClip;
        public var tf:TextField;

        public function SettingsButton(template:MovieClip, width:Number = 0, height:Number = 0)
        {
            this.plate = new (template.plate.constructor as Class)();
            this.plate.mouseEnabled = false;
            if (height != 0)
            {
                this.plate.height = height;
            }
            if (width != 0)
            {
                this.plate.width = width;
            }
            this.addChild(this.plate);

            this.tf = Bezel.Bezel.createTextBox(new TextFormat("Celtic Garamond for GemCraft", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER));
            this.tf.mouseEnabled = false;
            this.tf.multiline = false;
            this.tf.width = this.width;
            this.tf.height = this.height / 2 + 4;
            this.tf.y = this.height / 2 - this.tf.height / 2;

            this.addChild(this.tf);
        }

        public override function gotoAndStop(frame:Object, scene:String = null):void
        {
            this.plate.gotoAndStop(frame, scene);
        }
    }
}
