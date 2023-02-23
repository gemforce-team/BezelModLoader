package Bezel.GCL
{
    import flash.display.MovieClip;
    import flash.text.TextField;

    import gcl_gs_fla.btnplate90x60_31;

    internal class MoreSettingsButtonShim extends MovieClip
    {
        public var tf:TextField;
        public var plate:MovieClip;

        public function MoreSettingsButtonShim(template:MovieClip)
        {
            this.tf = new TextField();
            this.tf.text = "aaa";
            this.tf.defaultTextFormat = template.tf.getTextFormat(0, 1);
            this.tf.y = template.tf.y;
            this.tf.height = template.tf.height;
            this.tf.mouseEnabled = false;
            this.tf.wordWrap = true;
            this.tf.multiline = true;
            this.tf.filters = template.tf.filters;
            this.tf.scaleX = template.tf.scaleX;
            this.tf.scaleY = template.tf.scaleY;

            this.plate = new btnplate90x60_31();

            this.addChild(this.plate);
            this.addChild(this.tf);
            this.tf.width = this.plate.width;
            this.tf.visible = true;
        }
    }
}
