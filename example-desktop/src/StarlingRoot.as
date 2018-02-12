package {

import com.tuarua.CommonDependencies;
import com.tuarua.MLANE;
import com.tuarua.mlane.ClassificationType;
import com.tuarua.mlane.VisionClassification;
import com.tuarua.mlane.events.CompileEvent;
import com.tuarua.mlane.events.ModelEvent;
import com.tuarua.mlane.events.VisionClassificationEvent;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.Align;

import views.SimpleButton;

public class StarlingRoot extends Sprite {
    [Embed(source="ttf/fira-sans-embed.ttf", embedAsCFF="false", fontFamily="Fira Sans", fontWeight="SemiBold")]
    private static const firaSansEmbedded:Class;

     [Embed(source="dog.jpg")]
     public static const TestImage:Class;

    //noinspection JSUnusedLocalSymbols
    private var commonDependenciesANE:CommonDependencies = new CommonDependencies();//must create before all others
    private var loadBtn:SimpleButton;
    private var classifyBtn:SimpleButton;
    private var statusLabel:TextField = new TextField(800, 400, "");
    private var coreml:MLANE;
    private var modelDownloader:URLLoader;

    private static const modelUrl:String = "https://docs-assets.developer.apple.com/coreml/models/MobileNet.mlmodel";
    private static const modelFileName:String = "MobileNet.mlmodel";
    private static const modelCompiledFileName:String = "MobileNet.mlmodelc";

    // https://docs-assets.developer.apple.com/coreml/models/SqueezeNet.mlmodel
    // https://docs-assets.developer.apple.com/coreml/models/GoogLeNetPlaces.mlmodel
    public function StarlingRoot() {
        super();
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
    }

    public function start():void {
        loadBtn = new SimpleButton("Get Model");
        loadBtn.addEventListener(TouchEvent.TOUCH, onLoadTouch);
        loadBtn.useHandCursor = true;
        loadBtn.x = (stage.stageWidth - loadBtn.width) / 2;
        loadBtn.y = 80;

        classifyBtn = new SimpleButton("Classify");
        classifyBtn.addEventListener(TouchEvent.TOUCH, onClassifyTouch);
        classifyBtn.useHandCursor = true;
        classifyBtn.x = (stage.stageWidth - classifyBtn.width) / 2;
        classifyBtn.y = 80;
        classifyBtn.visible = false;

        coreml = MLANE.coreml;
        coreml.addEventListener(ModelEvent.LOADED, onModelLoaded);
        coreml.addEventListener(CompileEvent.ERROR, onCompileError);
        coreml.addEventListener(CompileEvent.COMPLETE, onCompileComplete);
        coreml.addEventListener(VisionClassificationEvent.RESULT, onVisionClassificationResult);

        // only add buttons if
        if (coreml.isSupported) {
            addChild(loadBtn);
            addChild(classifyBtn);
        } else {
            trace("Core ML is only support on Mac OSX 10.13+");
        }

        statusLabel.format.setTo("Fira Sans", 13, 0x222222, Align.CENTER, Align.TOP);
        statusLabel.y = 160;
        addChild(statusLabel);

    }

    private function onModelLoaded(event:ModelEvent):void {
        statusLabel.text = "model loaded";
    }

    private function onVisionClassificationResult(event:VisionClassificationEvent):void {
        statusLabel.text = "";
        for each (var classification:VisionClassification in event.results) {
            statusLabel.text += classification.confidence.toFixed(3) + " " +classification.identifier + "\n";
        }
    }

    private function onClassifyTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(classifyBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            classifyBtn.touchable = false;
            classifyBtn.alpha = 0.5;
            classifyWithVision();
        }
    }

    private function onCompileComplete(event:CompileEvent):void {
        statusLabel.text = "model compiled";
        loadModel();
    }

    private function onCompileError(event:CompileEvent):void {
        trace(event.error);
    }

    private function onLoadTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(loadBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            loadBtn.touchable = false;
            loadBtn.alpha = 0.5;
            if (File.applicationStorageDirectory.resolvePath(modelCompiledFileName).exists) {
                statusLabel.text = "already compiled, load model";
                loadModel();
            } else {
                // download model
                var request:URLRequest = new URLRequest(modelUrl);
                modelDownloader = new URLLoader();
                modelDownloader.dataFormat = URLLoaderDataFormat.BINARY;
                modelDownloader.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
                modelDownloader.addEventListener(Event.COMPLETE, onDownloadComplete);
                modelDownloader.load(request);
            }

        }
    }

    private function compileModel():void {
        var model:File = File.applicationStorageDirectory.resolvePath(modelFileName);
        if (model.exists) {
            coreml.compileModel(model.nativePath);
        }
    }

    private function loadModel():void {
        var model:File = File.applicationStorageDirectory.resolvePath(modelCompiledFileName);
        if (model.exists) {
            coreml.loadModel(model.nativePath);
            loadBtn.visible = false;
            classifyBtn.visible = true;
        }
    }

    private function classifyWithVision():void {
        //
        // var testImage:Bitmap = new TestImage() as Bitmap;
        // coreml.classifyImage(0, null, testImage.bitmapData);

        var file:File = File.applicationDirectory.resolvePath("dog.jpg");
        if (file.exists) {
            coreml.classifyImage(ClassificationType.VISION, file.nativePath);
        }
    }

    private function onDownloadComplete(event:Event):void {
        writeBytesToFile(File.applicationStorageDirectory.resolvePath(modelFileName).nativePath,
                event.target.data as ByteArray);
        compileModel();
    }

    private function onDownloadProgress(event:ProgressEvent):void {
        statusLabel.text = Math.floor((event.bytesLoaded / event.bytesTotal) * 100) + "% downloaded";
    }

    private static function writeBytesToFile(fileName:String, data:ByteArray):void {
        var outFile:File = File.desktopDirectory;
        outFile = outFile.resolvePath(fileName);
        var outStream:FileStream = new FileStream();
        outStream.open(outFile, FileMode.WRITE);
        outStream.writeBytes(data, 0, data.length);
        outStream.close();
    }

    private function onExiting(event:Event):void {


    }


}
}
