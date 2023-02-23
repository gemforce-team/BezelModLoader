package Bezel.GCCS
{
    import Bezel.Bezel;

    import flash.display.MovieClip;
    import flash.text.TextField;

    import gc_cs_steam_fla.btnplate160x34_24;

    internal class SettingsButtonShim extends MovieClip
    {
        public var tf:TextField;
        public var plate:MovieClip;
        public var yReal:Number;

        public function SettingsButtonShim(template:MovieClip)
        {
            this.tf = Bezel.Bezel.createTextBox(template.tf.getTextFormat());
            this.tf.text = "aaa";
            this.tf.y = template.tf.y;
            this.tf.height = template.tf.height;
            this.tf.selectable = false;

            this.plate = new btnplate160x34_24();

            this.addChild(this.plate);
            this.plate.scaleX = 1.5;
            this.addChild(this.tf);
            this.tf.width = this.plate.width;
            this.tf.visible = true;
        }
    }
}
