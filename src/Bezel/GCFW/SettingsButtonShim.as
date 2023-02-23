package Bezel.GCFW
{
    import Bezel.Bezel;

    import GemCraftFrostbornWrath_fla.btnplate160x34_24;

    import flash.display.MovieClip;
    import flash.text.TextField;

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
            this.plate.scaleX = this.plate.scaleY = 1.5;
            this.addChild(this.tf);
            this.tf.width = this.plate.width;
            this.tf.visible = true;
        }
    }
}
