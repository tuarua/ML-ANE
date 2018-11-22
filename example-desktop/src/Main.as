package {
import com.tuarua.CommonDependencies;
import com.tuarua.MLANE;
import com.tuarua.mlane.Model;
import com.tuarua.mlane.ModelDescription;
import com.tuarua.mlane.events.ModelEvent;
import com.tuarua.mlane.models.MobileNet;
import com.tuarua.mlane.models.MobileNetOutput;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.text.AntiAliasType;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;

import mymodels.MarsHabitatPricer;
import mymodels.MarsHabitatPricerOutput;

import views.SimpleButton;

[SWF(width="800", height="600", frameRate="60", backgroundColor="#FFFFFF")]
public class Main extends Sprite {
    [Embed(source="dog.jpg")]
    public static const TestImage:Class;

    private var commonDependenciesANE:CommonDependencies = new CommonDependencies(); //must create before all others
    public static const FONT:Font = new FiraSansSemiBold();
    private var loadMobileNetBtn:SimpleButton;
    private var predictMobileNetBtn:SimpleButton;
    private var predictMarsBtn:SimpleButton;

    private var loadMarsBtn:SimpleButton;

    private var mobileNetStatusLabel:TextField;
    private var marsStatusLabel:TextField;

    //other image examples SqueezeNet.mlmodel - GoogLeNetPlaces.mlmodel
    private static const mobileNetFileName:String = "MobileNet.mlmodel";
    private static const mobileNetCompiledFileName:String = mobileNetFileName + "c";
    private static const mobileNetUrl:String = "https://docs-assets.developer.apple.com/coreml/models/" + mobileNetFileName;

    private static const marsFileName:String = "MarsHabitatPricer.mlmodel";
    private static const marsCompiledFileName:String = marsFileName + "c";

    private var model:Model;


    public function Main() {

        super();

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        start();

        NativeApplication.nativeApplication.executeInBackground = true;
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);

    }

    private function start():void {
        var tf:TextFormat = new TextFormat(Main.FONT.fontName, 13, 0x222222);
        tf.align = "center";
        tf.bold = false;

        loadMobileNetBtn = new SimpleButton("Get MobileNet Model");
        loadMobileNetBtn.addEventListener(MouseEvent.CLICK, onLoadMobileNetTouch);
        loadMobileNetBtn.x = (stage.stageWidth - loadMobileNetBtn.width) / 2;
        loadMobileNetBtn.y = 80;

        predictMobileNetBtn = new SimpleButton("Predict");
        predictMobileNetBtn.addEventListener(MouseEvent.CLICK, onPredictMobileNetTouch);
        predictMobileNetBtn.x = (stage.stageWidth - predictMobileNetBtn.width) / 2;
        predictMobileNetBtn.y = 80;
        predictMobileNetBtn.visible = false;

        mobileNetStatusLabel = new TextField();
        mobileNetStatusLabel.wordWrap = mobileNetStatusLabel.multiline = false;
        mobileNetStatusLabel.embedFonts = true;
        mobileNetStatusLabel.antiAliasType = AntiAliasType.ADVANCED;
        mobileNetStatusLabel.sharpness = -100;
        mobileNetStatusLabel.defaultTextFormat = tf;
        mobileNetStatusLabel.selectable = false;
        mobileNetStatusLabel.width = stage.stageWidth;

        marsStatusLabel = new TextField();
        marsStatusLabel.wordWrap = marsStatusLabel.multiline = false;
        marsStatusLabel.embedFonts = true;
        marsStatusLabel.antiAliasType = AntiAliasType.ADVANCED;
        marsStatusLabel.sharpness = -100;
        marsStatusLabel.defaultTextFormat = tf;
        marsStatusLabel.selectable = false;
        marsStatusLabel.width = stage.stageWidth;

        loadMarsBtn = new SimpleButton("Get Mars Model");
        loadMarsBtn.addEventListener(MouseEvent.CLICK, onLoadMarsTouch);
        loadMarsBtn.x = (stage.stageWidth - loadMarsBtn.width) / 2;
        loadMarsBtn.y = 280;

        predictMarsBtn = new SimpleButton("Predict");
        predictMarsBtn.addEventListener(MouseEvent.CLICK, onPredictMarsTouch);
        predictMarsBtn.x = (stage.stageWidth - predictMarsBtn.width) / 2;
        predictMarsBtn.y = 280;
        predictMarsBtn.visible = false;

        var coreml:MLANE = MLANE.coreml;

        if (coreml.isSupported) {
            addChild(loadMobileNetBtn);
            addChild(predictMobileNetBtn);
            addChild(loadMarsBtn);
            addChild(predictMarsBtn);
        } else {
            trace("Core ML is only supported on Mac OSX 10.13+ and iOS 11.0+");
        }

        mobileNetStatusLabel.y = 160;
        addChild(mobileNetStatusLabel);

        marsStatusLabel.y = 340;
        addChild(marsStatusLabel);

    }

    private function onPredictMarsTouch(event:MouseEvent):void {
        predictMarsBtn.enabled = false;
        predictMarsBtn.alpha = 0.5;
        var marsHabitatPricer:MarsHabitatPricer = new MarsHabitatPricer(50, 10, 20);
        model.prediction(marsHabitatPricer, onMarsResult);
    }

    private function onLoadMarsTouch(event:MouseEvent):void {
        loadMarsBtn.enabled = false;
        loadMarsBtn.alpha = 0.5;
        var modelFile:File = File.applicationStorageDirectory.resolvePath(marsCompiledFileName);
        if (modelFile.exists) {
            marsStatusLabel.text = "already compiled, load model";
            model = new Model(modelFile.nativePath);
            model.load(onMarsLoaded);
        } else {
            marsStatusLabel.text = "getting model";
            // must copy Mars model to application storage dir
            var copyFrom:File = File.applicationDirectory.resolvePath(marsFileName);
            var copyTo:File = File.applicationStorageDirectory.resolvePath(marsFileName);
            if (copyFrom.exists) {
                copyFrom.copyTo(copyTo, false);
                model = Model.fromPath(File.applicationStorageDirectory.resolvePath(marsFileName).nativePath, onMarsCompiled);
            }
        }
    }

    private function onPredictMobileNetTouch(event:MouseEvent):void {
        predictMobileNetBtn.enabled = false;
        predictMobileNetBtn.alpha = 0.5;
        var testImage:Bitmap = new TestImage() as Bitmap;
        var mobileNet:MobileNet = new MobileNet(testImage.bitmapData);
        model.prediction(mobileNet, onMobileNetResult);
    }

    private function onLoadMobileNetTouch(event:MouseEvent):void {
        loadMobileNetBtn.enabled = false;
        loadMobileNetBtn.alpha = 0.5;
        var modelFile:File = File.applicationStorageDirectory.resolvePath(mobileNetCompiledFileName);
        if (modelFile.exists) {
            mobileNetStatusLabel.text = "already compiled, load model";
            model = new Model(modelFile.nativePath);
            model.load(onMobileNetLoaded);
        } else {
            mobileNetStatusLabel.text = "downloading model";
            model = Model.fromUrl(mobileNetUrl, onDownloadProgress, onDownloadComplete, onMobileNetCompiled);
        }
    }

    private function onMobileNetCompiled(event:ModelEvent):void {
        mobileNetStatusLabel.text = "Compile complete";
        model.load(onMobileNetLoaded);
    }

    private function onMarsCompiled(event:ModelEvent):void {
        marsStatusLabel.text = "Compile complete";
        model.load(onMarsLoaded);
    }

    private function onDownloadProgress(event:ProgressEvent):void {
        mobileNetStatusLabel.text = Math.floor((event.bytesLoaded / event.bytesTotal) * 100) + "% downloaded";
    }

    private function onDownloadComplete(event:Event):void {
        mobileNetStatusLabel.text = "Download complete, start compile";
    }

    private function onMobileNetLoaded(event:ModelEvent):void {
        mobileNetStatusLabel.text = "model loaded";
        loadMobileNetBtn.visible = false;
        predictMobileNetBtn.visible = true;
        var modelDescription:ModelDescription = model.description;
        if (modelDescription) {
            trace(modelDescription.metadata.description);
            trace("predictedFeatureName:", modelDescription.predictedFeatureName);
            trace("predictedProbabilitiesName:", modelDescription.predictedProbabilitiesName);
        }
    }

    private function onMarsLoaded(event:ModelEvent):void {
        marsStatusLabel.text = "model loaded";
        loadMarsBtn.visible = false;
        predictMarsBtn.visible = true;
    }

    private function onMobileNetResult(event:ModelEvent):void {
        var output:MobileNetOutput = new MobileNetOutput(event.result);
        mobileNetStatusLabel.text = output.classLabel + " confidence: "
                + (output.classLabelProbs[output.classLabel] as Number).toFixed(4);
    }

    private function onMarsResult(event:ModelEvent):void {
        var output:MarsHabitatPricerOutput = new MarsHabitatPricerOutput(event.result);
        marsStatusLabel.text = "$" + output.price.toFixed(2);
    }

    private function onExiting(event:Event):void {
        MLANE.dispose();
        commonDependenciesANE.dispose();
    }

}
}
