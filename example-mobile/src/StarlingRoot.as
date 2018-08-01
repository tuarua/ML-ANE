package {

import com.tuarua.MLANE;
import com.tuarua.mlane.Model;
import com.tuarua.mlane.ModelDescription;
import com.tuarua.mlane.events.ModelEvent;
import com.tuarua.mlane.events.VisionEvent;
import com.tuarua.mlane.models.MobileNet;
import com.tuarua.mlane.models.MobileNetOutput;
import com.tuarua.mlane.permissions.PermissionEvent;
import com.tuarua.mlane.permissions.PermissionStatus;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.utils.Dictionary;

import mymodels.MarsHabitatPricer;
import mymodels.MarsHabitatPricerOutput;

import starling.core.Starling;

import starling.display.Image;

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

    private var menuContainer:Sprite = new Sprite();
    private var maskContainer:Sprite = new Sprite();
    private var screenMasks:Dictionary = new Dictionary();

    private var hotdog:Image = new Image(Assets.getAtlas().getTexture("hotdog"));
    private var nothotdog:Image = new Image(Assets.getAtlas().getTexture("nothotdog"));

    private var loadMobileNetBtn:SimpleButton = new SimpleButton("Get MobileNet Model");
    private var predictMobileNetBtn:SimpleButton = new SimpleButton("Predict");
    private var predictMarsBtn:SimpleButton = new SimpleButton("Predict");
    private var loadMarsBtn:SimpleButton = new SimpleButton("Get Mars Model");
    private var closeBtn:SimpleButton = new SimpleButton("Close");

    private var loadHotDogBtn:SimpleButton = new SimpleButton("Get HotDog Not HotDog Model");
    private var predictHotDogBtn:SimpleButton = new SimpleButton("Launch Camera");

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
        loadMobileNetBtn.addEventListener(TouchEvent.TOUCH, onLoadMobileNetClick);
        closeBtn.x = predictHotDogBtn.x = loadHotDogBtn.x = predictMarsBtn.x = loadMarsBtn.x =
                predictMobileNetBtn.x = loadMobileNetBtn.x = (stage.stageWidth - 200) / 2;
        loadMobileNetBtn.y = 80;

        predictMobileNetBtn.addEventListener(TouchEvent.TOUCH, onPredictMobileNetClick);
        predictMobileNetBtn.y = loadMobileNetBtn.y;
        predictMobileNetBtn.visible = false;

        mobileNetStatusLabel = new TextField(stage.stageWidth, 100, "");
        marsStatusLabel = new TextField(stage.stageWidth, 100, "");
        hotDogStatusLabel = new TextField(stage.stageWidth, 100, "");

        loadMarsBtn.addEventListener(TouchEvent.TOUCH, onLoadMarsClick);
        loadMarsBtn.y = loadMobileNetBtn.y + 180;

        predictMarsBtn.addEventListener(TouchEvent.TOUCH, onPredictMarsClick);
        predictMarsBtn.y = loadMarsBtn.y;
        predictMarsBtn.visible = false;

        loadHotDogBtn.addEventListener(TouchEvent.TOUCH, onLoadHotDogClick);
        loadHotDogBtn.y = loadMarsBtn.y + 180;

        predictHotDogBtn.addEventListener(TouchEvent.TOUCH, onPredictHotDogClick);
        predictHotDogBtn.y = loadHotDogBtn.y;
        predictHotDogBtn.visible = false;

        mobileNetStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        mobileNetStatusLabel.touchable = false;
        mobileNetStatusLabel.y = loadMobileNetBtn.y + 75;

        marsStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        marsStatusLabel.touchable = false;
        marsStatusLabel.y = loadMarsBtn.y + 75;

        hotDogStatusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        hotDogStatusLabel.touchable = false;
        hotDogStatusLabel.y = loadHotDogBtn.y + 75;

        closeBtn.addEventListener(TouchEvent.TOUCH, onCloseClick);
        closeBtn.y = 80;

        menuContainer.addChild(loadMobileNetBtn);
        menuContainer.addChild(predictMobileNetBtn);
        menuContainer.addChild(loadMarsBtn);
        menuContainer.addChild(predictMarsBtn);
        menuContainer.addChild(loadHotDogBtn);
        menuContainer.addChild(predictHotDogBtn);
        menuContainer.addChild(mobileNetStatusLabel);
        menuContainer.addChild(marsStatusLabel);
        menuContainer.addChild(hotDogStatusLabel);
        menuContainer.addChild(hotDogStatusLabel);
        addChild(menuContainer);

        nothotdog.x = hotdog.x = (stage.stageWidth - 120) / 2;
        hotdog.y = nothotdog.y = 160;
        hotdog.visible = false;

        maskContainer.addChild(closeBtn);
        maskContainer.addChild(hotdog);
        maskContainer.addChild(nothotdog);
        maskContainer.visible = false;
        addChild(maskContainer);

    }

    private function getScreenMask(forScreen:String):BitmapData {
        if (screenMasks[forScreen]) return screenMasks[forScreen];
        var maskBmd:BitmapData = new BitmapData(Starling.current.nativeStage.fullScreenWidth,
                Starling.current.nativeStage.fullScreenHeight, true, 0x00FFFFFF); //the full size mask
        var sf:Number = Starling.current.contentScaleFactor;
        var spriteBmd:BitmapData = new BitmapData(maskContainer.width * sf,
                maskContainer.height * sf, true, 0xFFFFFFFF);
        maskContainer.drawToBitmapData(spriteBmd);
        maskBmd.copyPixels(spriteBmd, spriteBmd.rect,
                new Point(maskContainer.bounds.x * sf, maskContainer.bounds.y * sf));
        var bmd:BitmapData = new Bitmap(maskBmd).bitmapData;
        screenMasks[forScreen] = bmd;
        return bmd;
    }

    private function onPredictMobileNetClick(event:TouchEvent):void {
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


    private function onCloseClick(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(closeBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            coreml.closeCamera();
            maskContainer.visible = false;
            menuContainer.visible = true;
        }
    }

    private function onPredictMarsClick(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(predictMarsBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            predictMarsBtn.touchable = false;
            predictMarsBtn.alpha = 0.5;
            var marsHabitatPricer:MarsHabitatPricer = new MarsHabitatPricer(50, 10, 20);
            model.prediction(marsHabitatPricer, onMarsResult);
        }
    }

    private function onLoadMobileNetClick(event:TouchEvent):void {
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

    private function onLoadMarsClick(event:TouchEvent):void {
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

    private function onLoadHotDogClick(event:TouchEvent):void {
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

    private function onPredictHotDogClick(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(predictHotDogBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            // Hint: point camera at picture of hotdog
            //TODO mask
            menuContainer.visible = false;
            maskContainer.visible = true;
            coreml.inputFromCamera(model, onHotDogResult, null, getScreenMask("hotdog"));
        }
    }

    private function onHotDogResult(event:VisionEvent):void {
        // trace(event.result.label, event.result.confidence);
        if (hotDogStatus != event.result.label) {
            hotDogStatus = event.result.label;
            hotdog.visible = (hotDogStatus == "hotdog");
            nothotdog.visible = !hotdog.visible;
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
