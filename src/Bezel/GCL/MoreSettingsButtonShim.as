package Bezel.GCL
{
    import Bezel.Bezel;

    import flash.display.MovieClip;
    import flash.text.TextField;

    internal class MoreSettingsButtonShim extends MovieClip
    {
        public var tf:TextField;
        public var plate:MovieClip;

        public function MoreSettingsButtonShim(template:MovieClip)
        {
            this.tf = Bezel.Bezel.createTextBox(template.tf.getTextFormat());
            this.tf.defaultTextFormat.color = 0xFFFFFF;
            this.tf.text = "aaa";
            this.tf.y = template.tf.y;
            this.tf.height = template.tf.height;
            this.tf.mouseEnabled = false;
            this.tf.wordWrap = true;
            this.tf.multiline = true;
            this.tf.filters = template.tf.filters;
            this.tf.scaleX = template.tf.scaleX;
            this.tf.scaleY = template.tf.scaleY;

            this.plate = new (template.plate.constructor as Class)();

            this.addChild(this.plate);
            this.addChild(this.tf);
            this.tf.width = this.plate.width;
            this.tf.visible = true;
        }
    }
}
