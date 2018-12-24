/* Copyright 2018 Tua Rua Ltd.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

package com.tuarua.mlane {
import com.tuarua.MLANEContext;
import com.tuarua.fre.ANEError;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class Model extends EventDispatcher {
    private var _description:ModelDescription;
    private static var _path:String;
    private static var _fileName:String;
    private static var _id:String;
    private static var _onLoaded:Function;
    private static var _onError:Function;
    private static var _onCompiled:Function;
    private static var _onResult:Function;

    /** Creates a Model from the given compiled CoreML model
     * @param contentsOf path to .mlmodelc file
     */
    public function Model(contentsOf:String = null) {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        _id = MLANEContext.context.call("createGUID") as String;
        if (contentsOf && getExtension(contentsOf) != "mlmodelc") {
            throw new Error("contentsOf must be of file type mlmodelc");
        }
        _path = contentsOf;
        _fileName = fileNameFromUrl(_path);
        MLANEContext.models[_id] = this;
    }

    /** @return */
    public function get description():ModelDescription {
        return _description;
    }
    /** @private */
    private function safetyCheck():Boolean {
        return (MLANEContext.context != null);
    }

    /**
     *
     * @param onLoaded
     * @param onError Function to call when there is an error comiling the model
     */
    public function load(onLoaded:Function = null, onError:Function = null):void {
        if (safetyCheck()) {
            _onLoaded = onLoaded;
            _onError = onError;
            var theRet:* = MLANEContext.context.call("loadModel", _id, _path);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /** Downloads model, compiles and makes available to run predictions on.
     *
     * @return Created model
     *
     * @param url Url of the mlmodel to download
     * @param onProgress
     * @param onComplete Function to call when model has completed downloading
     * @param onCompiled Function to call when model is compiled
     * @param onError Function to call when there is an error comiling the model
     */
    public static function fromUrl(url:String, onProgress:Function = null, onComplete:Function = null,
                                   onCompiled:Function = null, onError:Function = null):Model {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        if (getExtension(url) != "mlmodel") {
            throw new Error("contentsOf must be of file type mlmodel");
        }
        _onCompiled = onCompiled;
        var model:Model = new Model();
        MLANEContext.models[model.id] = model;
        var request:URLRequest = new URLRequest(url);
        var downloader:URLLoader = new URLLoader();
        downloader.dataFormat = URLLoaderDataFormat.BINARY;
        if (onProgress != null) {
            downloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }
        if (onComplete != null) {
            downloader.addEventListener(Event.COMPLETE, onComplete);
        }
        downloader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var path:String = File.applicationStorageDirectory.resolvePath(fileNameFromUrl(url)).nativePath;
            writeBytesToFile(path, event.target.data as ByteArray);
            MLANEContext.context.call("compileModel", model.id, path);
        });
        downloader.load(request);
        return model;
    }

    /** Loads model from file system, compiles and makes available to run predictions on.
     * @param path Path to .mlmodel file
     * @param onCompiled Function to call when model is compiled
     *
     * @return Created model
     *dictionaryV
     */
    public static function fromPath(path:String, onCompiled:Function = null):Model {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        if (getExtension(path) != "mlmodel") {
            throw new Error("contentsOf must be of file type mlmodel");
        }
        _onCompiled = onCompiled;
        var model:Model = new Model();
        MLANEContext.models[model.id] = model;
        var theRet:* = MLANEContext.context.call("compileModel", model.id, path);
        if (theRet is ANEError) throw theRet as ANEError;
        return model;
    }

    /**
     *
     * @param provider
     * @param onResult
     * @param maxResults
     *
     * @return Created model
     *
     */
    public function prediction(provider:Object, onResult:Function, maxResults:int = 5):void {
        _onResult = onResult;
        var theRet:* = MLANEContext.context.call("prediction", _id, provider, maxResults);
        if (theRet is ANEError) throw theRet as ANEError;
    }

    /** Disposes the model */
    public function dispose():void {
        var theRet:* = MLANEContext.context.call("disposeModel", _id);
        if (theRet is ANEError) throw theRet as ANEError;
        delete MLANEContext.models[_id];
    }

    /** @private */
    private static function fileNameFromUrl(path:String):String {
        if (path == null) return null;
        var arr:Array = path.split("/");
        return arr[arr.length - 1];
    }

    /** @private */
    private static function writeBytesToFile(fileName:String, data:ByteArray):void {
        var outFile:File = File.desktopDirectory;
        outFile = outFile.resolvePath(fileName);
        var outStream:FileStream = new FileStream();
        outStream.open(outFile, FileMode.WRITE);
        outStream.writeBytes(data, 0, data.length);
        outStream.close();
    }

    /** @private */
    private static function getExtension(file:String):String {
        var split:String = file.split("?")[0];
        return split.substring(split.lastIndexOf(".") + 1, split.length);
    }

    /**
     *
     * @return
     *
     */
    public function get path():String {
        return _path;
    }

    /** @private */
    public function set path(value:String):void {
        _path = value;
    }
    /** @private */
    public function get fileName():String {
        return _fileName;
    }
    /** @private */
    public function get id():String {
        return _id;
    }

    /** @private */
    public function get onCompiled():Function {
        return _onCompiled;
    }

    /** @private */
    public function get onResult():Function {
        return _onResult;
    }

    /** @private */
    public function set onResult(value:Function):void {
        _onResult = value;
    }

    /** @private */
    public function get onError():Function {
        return _onError;
    }

    /** @private */
    public function set onError(value:Function):void {
        _onError = value;
    }

    /** @private */
    public function get onLoaded():Function {
        return _onLoaded;
    }

    /** @private */
    public function set description(value:ModelDescription):void {
        _description = value;
    }


}
}
