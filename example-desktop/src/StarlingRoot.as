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
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.filesystem.File;

import mymodels.MarsHabitatPricer;
import mymodels.MarsHabitatPricerOutput;

import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.Align;

import views.SimpleButton;

public class StarlingRoot extends Sprite {
    [Embed(source="dog.jpg")]
    public static const TestImage:Class;

    //noinspection JSUnusedLocalSymbols
    private var commonDependenciesANE:CommonDependencies = new CommonDependencies(); //must create before all others
    private var loadMobileNetBtn:SimpleButton;
    private var predictMobileNetBtn:SimpleButton;
    private var predictMarsBtn:SimpleButton;

    private var loadMarsBtn:SimpleButton;

    private var mobileNetStatusLabel:TextField;
    private var marsStatusLabel:TextField;
    private var coreml:MLANE;

    //other image examples SqueezeNet.mlmodel - GoogLeNetPlaces.mlmodel
    private static const mobileNetFileName:String = "MobileNet.mlmodel";
    private static const mobileNetCompiledFileName:String = mobileNetFileName + "c";
    private static const mobileNetUrl:String = "https://docs-assets.developer.apple.com/coreml/models/" + mobileNetFileName;

    private static const marsFileName:String = "MarsHabitatPricer.mlmodel";
    private static const marsCompiledFileName:String = marsFileName + "c";

    private var model:Model;

    public function StarlingRoot() {
        super();
        TextField.registerCompositor(Fonts.getFont("fira-sans-semi-bold-13"), "Fira Sans Semi-Bold 13");
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
    }

    public function start():void {
        trace(File.applicationStorageDirectory.nativePath);

        loadMobileNetBtn = new SimpleButton("Get MobileNet Model");
        loadMobileNetBtn.addEventListener(TouchEvent.TOUCH, onLoadMobileNetTouch);
        loadMobileNetBtn.useHandCursor = true;
        loadMobileNetBtn.x = (stage.stageWidth - loadMobileNetBtn.width) / 2;
        loadMobileNetBtn.y = 80;

        predictMobileNetBtn = new SimpleButton("Predict");
        predictMobileNetBtn.addEventListener(TouchEvent.TOUCH, onPredictMobileNetTouch);
        predictMobileNetBtn.useHandCursor = true;
        predictMobileNetBtn.x = (stage.stageWidth - predictMobileNetBtn.width) / 2;
        predictMobileNetBtn.y = 80;
        predictMobileNetBtn.visible = false;

        mobileNetStatusLabel = new TextField(stage.stageWidth, 100, "");
        marsStatusLabel = new TextField(stage.stageWidth, 100, "");

        loadMarsBtn = new SimpleButton("Get Mars Model");
        loadMarsBtn.addEventListener(TouchEvent.TOUCH, onLoadMarsTouch);
        loadMarsBtn.useHandCursor = true;
        loadMarsBtn.x = (stage.stageWidth - loadMarsBtn.width) / 2;
        loadMarsBtn.y = 280;

        predictMarsBtn = new SimpleButton("Predict");
        predictMarsBtn.addEventListener(TouchEvent.TOUCH, onPredictMarsTouch);
        predictMarsBtn.useHandCursor = true;
        predictMarsBtn.x = (stage.stageWidth - predictMarsBtn.width) / 2;
        predictMarsBtn.y = 280;
        predictMarsBtn.visible = false;

        coreml = MLANE.coreml;

        if (coreml.isSupported) {
            addChild(loadMobileNetBtn);
            addChild(predictMobileNetBtn);
            addChild(loadMarsBtn);
            addChild(predictMarsBtn);
        } else {
            trace("Core ML is only supported on Mac OSX 10.13+ and iOS 11.0+");
        }

        mobileNetStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        mobileNetStatusLabel.batchable = true;
        mobileNetStatusLabel.touchable = false;
        mobileNetStatusLabel.y = 160;
        addChild(mobileNetStatusLabel);

        marsStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        marsStatusLabel.y = 340;
        addChild(marsStatusLabel);

    }

    private function onPredictMobileNetTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(predictMobileNetBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            predictMobileNetBtn.touchable = false;
            predictMobileNetBtn.alpha = 0.5;
            var testImage:Bitmap = new TestImage() as Bitmap;
            var mobileNet:MobileNet = new MobileNet(testImage.bitmapData);

            model.prediction(mobileNet, onMobileNetResult);
        }
    }

    private function onPredictMarsTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(predictMarsBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            predictMarsBtn.touchable = false;
            predictMarsBtn.alpha = 0.5;
            var marsHabitatPricer:MarsHabitatPricer = new MarsHabitatPricer(50, 10, 20);
            model.prediction(marsHabitatPricer, onMarsResult);
        }
    }

    private function onLoadMobileNetTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(loadMobileNetBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            loadMobileNetBtn.touchable = false;
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
    }

    private function onLoadMarsTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(loadMarsBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            loadMarsBtn.touchable = false;
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
//        var modelDescription:ModelDescription = model.description;
//        if (modelDescription) {
//            trace(modelDescription.metadata.description);
//            trace("predictedFeatureName:", modelDescription.predictedFeatureName);
//            trace("predictedProbabilitiesName:", modelDescription.predictedProbabilitiesName);
//        }
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


    }


}
}
