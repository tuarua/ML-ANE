package {

import com.tuarua.MLANE;
import com.tuarua.mlane.Model;
import com.tuarua.mlane.ModelDescription;
import com.tuarua.mlane.events.ModelEvent;
import com.tuarua.mlane.events.VisionEvent;
import com.tuarua.mlane.models.MobileNet;
import com.tuarua.mlane.models.MobileNetOutput;
import com.tuarua.mlane.display.*;
import com.tuarua.mlane.permissions.PermissionEvent;
import com.tuarua.mlane.permissions.PermissionStatus;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
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

    [Embed(source="close.png")]
    private static const CloseButton:Class;

    [Embed(source="hotdog.png")]
    private static const HotDogImage:Class;

    [Embed(source="nothotdog.png")]
    private static const NotHotDogImage:Class;

    private var closeButtonBmp:Bitmap = new CloseButton() as Bitmap;
    private var closeButton:NativeButton = new NativeButton(closeButtonBmp.bitmapData);

    private var hotDogBmp:Bitmap = new HotDogImage() as Bitmap;
    private var notHotDogBmp:Bitmap = new NotHotDogImage() as Bitmap;
    private var hotDogImage:NativeImage = new NativeImage(hotDogBmp.bitmapData);
    private var notHotDogImage:NativeImage = new NativeImage(notHotDogBmp.bitmapData);

    private var loadMobileNetBtn:SimpleButton;
    private var predictMobileNetBtn:SimpleButton;
    private var predictMarsBtn:SimpleButton;
    private var loadMarsBtn:SimpleButton;

    private var loadHotDogBtn:SimpleButton;
    private var predictHotDogBtn:SimpleButton;

    private var mobileNetStatusLabel:TextField;
    private var marsStatusLabel:TextField;
    private var hotDogStatusLabel:TextField;
    private var coreml:MLANE;

    //other image examples SqueezeNet.mlmodel - GoogLeNetPlaces.mlmodel
    private static const mobileNetFileName:String = "MobileNet.mlmodel";
    private static const mobileNetCompiledFileName:String = mobileNetFileName + "c";
    private static const mobileNetUrl:String = "https://docs-assets.developer.apple.com/coreml/models/" + mobileNetFileName;

    private static const marsFileName:String = "MarsHabitatPricer.mlmodel";
    private static const marsCompiledFileName:String = marsFileName + "c";

    private static const hotDogFileName:String = "HotDogOrNot.mlmodel";
    private static const hotDogUrl:String = "https://github.com/praeclarum/HotDogOrNot/" +
            "blob/master/HotDogOrNot.iOS/Resources/" + hotDogFileName + "?raw=true";
    private static const hotDogCompiledFileName:String = hotDogFileName + "c";
    private var hotDogStatus:String;
    private var model:Model;

    public function StarlingRoot() {
        super();
        TextField.registerCompositor(Fonts.getFont("fira-sans-semi-bold-13"), "Fira Sans Semi-Bold 13");
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
        closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
    }

    public function start():void {
        trace(File.applicationStorageDirectory.nativePath);

        coreml = MLANE.coreml;
        if (!coreml.isSupported) {
            trace("Core ML is only supported on Mac OSX 10.13+ and iOS 11.0+");
            return;
        }
        coreml.addEventListener(PermissionEvent.STATUS_CHANGED, onPermissionsStatus);
        coreml.requestPermissions();
    }

    private function initMenu():void {
        loadMobileNetBtn = new SimpleButton("Get MobileNet Model");
        loadMobileNetBtn.addEventListener(TouchEvent.TOUCH, onLoadMobileNetTouch);
        loadMobileNetBtn.x = (stage.stageWidth - loadMobileNetBtn.width) / 2;
        loadMobileNetBtn.y = 80;

        predictMobileNetBtn = new SimpleButton("Predict");
        predictMobileNetBtn.addEventListener(TouchEvent.TOUCH, onPredictMobileNetTouch);
        predictMobileNetBtn.x = (stage.stageWidth - predictMobileNetBtn.width) / 2;
        predictMobileNetBtn.y = loadMobileNetBtn.y;
        predictMobileNetBtn.visible = false;

        mobileNetStatusLabel = new TextField(stage.stageWidth, 100, "");
        marsStatusLabel = new TextField(stage.stageWidth, 100, "");
        hotDogStatusLabel = new TextField(stage.stageWidth, 100, "");

        loadMarsBtn = new SimpleButton("Get Mars Model");
        loadMarsBtn.addEventListener(TouchEvent.TOUCH, onLoadMarsTouch);
        loadMarsBtn.x = (stage.stageWidth - loadMarsBtn.width) / 2;
        loadMarsBtn.y = loadMobileNetBtn.y + 180;

        predictMarsBtn = new SimpleButton("Predict");
        predictMarsBtn.addEventListener(TouchEvent.TOUCH, onPredictMarsTouch);
        predictMarsBtn.x = (stage.stageWidth - predictMarsBtn.width) / 2;
        predictMarsBtn.y = loadMarsBtn.y;
        predictMarsBtn.visible = false;

        loadHotDogBtn = new SimpleButton("Get HotDog Not HotDog Model");
        loadHotDogBtn.addEventListener(TouchEvent.TOUCH, onLoadHotDogTouch);
        loadHotDogBtn.x = (stage.stageWidth - loadHotDogBtn.width) / 2;
        loadHotDogBtn.y = loadMarsBtn.y + 180;

        predictHotDogBtn = new SimpleButton("Launch Camera");
        predictHotDogBtn.addEventListener(TouchEvent.TOUCH, onPredictHotDogTouch);
        predictHotDogBtn.x = (stage.stageWidth - predictHotDogBtn.width) / 2;
        predictHotDogBtn.y = loadHotDogBtn.y;
        predictHotDogBtn.visible = false;

        addChild(loadMobileNetBtn);
        addChild(predictMobileNetBtn);
        addChild(loadMarsBtn);
        addChild(predictMarsBtn);
        addChild(loadHotDogBtn);
        addChild(predictHotDogBtn);

        mobileNetStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        mobileNetStatusLabel.touchable = false;
        mobileNetStatusLabel.y = loadMobileNetBtn.y + 75;
        addChild(mobileNetStatusLabel);

        marsStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        marsStatusLabel.touchable = false;
        marsStatusLabel.y = loadMarsBtn.y + 75;
        addChild(marsStatusLabel);

        addChild(hotDogStatusLabel);
        hotDogStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        hotDogStatusLabel.touchable = false;
        hotDogStatusLabel.y = loadHotDogBtn.y + 75;
        addChild(hotDogStatusLabel);
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

    private function addCloseButton():void {
        coreml.addChild(closeButton);
    }

    private function addHotDogImages():void {
        notHotDogImage.x = hotDogImage.x = stage.stageWidth - 80;
        notHotDogImage.y = hotDogImage.y = 20;
        hotDogImage.visible = false;
        notHotDogImage.visible = false;
        coreml.addChild(hotDogImage);
        coreml.addChild(notHotDogImage);
    }

    private function onCloseClick(event:MouseEvent):void {
        trace(event);
        coreml.closeCamera();
        coreml.removeChild(closeButton);
        coreml.removeChild(hotDogImage);
        coreml.removeChild(notHotDogImage);
        this.visible = true;
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
                model = Model.fromUrl(mobileNetUrl, onDownloadMobileNetProgress, onDownloadMobileNetComplete, onMobileNetCompiled);
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

    private function onLoadHotDogTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(loadHotDogBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            loadHotDogBtn.touchable = false;
            loadHotDogBtn.alpha = 0.5;
            var modelFile:File = File.applicationStorageDirectory.resolvePath(hotDogCompiledFileName);
            if (modelFile.exists) {
                hotDogStatusLabel.text = "already compiled, load model";
                model = new Model(modelFile.nativePath);
                model.load(onHotDogLoaded);
            } else {
                hotDogStatusLabel.text = "downloading model";
                model = Model.fromUrl(hotDogUrl, onDownloadHotDogProgress, onDownloadHotDogComplete, onHotDogCompiled);
            }
        }
    }

    private function onPredictHotDogTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(predictHotDogBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            predictHotDogBtn.touchable = false;
            predictHotDogBtn.alpha = 0.5;
            // Hint: point camera at picture of hotdog
            coreml.inputFromCamera(model, onHotDogResult);
            addCloseButton();
            addHotDogImages();
            this.visible = false;
        }
    }

    private function onHotDogResult(event:VisionEvent):void {
        // trace(event.result.label, event.result.confidence);
        if(hotDogStatus != event.result.label) {
            hotDogStatus = event.result.label;
            hotDogImage.visible = (hotDogStatus == "hotdog");
            notHotDogImage.visible = !hotDogImage.visible;
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

    private function onDownloadMobileNetProgress(event:ProgressEvent):void {
        mobileNetStatusLabel.text = Math.floor((event.bytesLoaded / event.bytesTotal) * 100) + "% downloaded";
    }

    private function onDownloadMobileNetComplete(event:Event):void {
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

    private function onDownloadHotDogProgress(event:ProgressEvent):void {
        hotDogStatusLabel.text = Math.floor((event.bytesLoaded / event.bytesTotal) * 100) + "% downloaded";
    }

    private function onDownloadHotDogComplete(event:Event):void {
        hotDogStatusLabel.text = "Download complete, start compile";
    }

    private function onHotDogCompiled(event:ModelEvent):void {
        hotDogStatusLabel.text = "Compile complete";
        model.load(onHotDogLoaded);
    }

    private function onHotDogLoaded(event:ModelEvent):void {
        hotDogStatusLabel.text = "model loaded";
        loadHotDogBtn.visible = false;
        predictHotDogBtn.visible = true;
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
        var modelDescription:ModelDescription = model.description;
        if (modelDescription) {
            trace(modelDescription.metadata.description);
            trace("predictedFeatureName:", modelDescription.predictedFeatureName);
            trace("predictedProbabilitiesName:", modelDescription.predictedProbabilitiesName);
        }
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

    private function onPermissionsStatus(event:PermissionEvent):void {
        if (event.status == PermissionStatus.ALLOWED) {
            initMenu();
        } else if (event.status == PermissionStatus.NOT_DETERMINED) {
        } else {
            trace("Allow camera for CoreML Vision usage");
        }
    }

    private function onExiting(event:Event):void {
        MLANE.dispose();
    }


}
}
