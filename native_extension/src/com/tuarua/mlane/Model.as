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
import com.tuarua.mlane.events.CompileEvent;
import com.tuarua.mlane.events.ModelEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class Model extends EventDispatcher {
    private var _description:ModelDescription;
    private static var _path:String;
    private static var _fileName:String;
    private var argsAsJSON:Object;

    public function Model(contentsOf:String = null) {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        if (contentsOf && getExtension(contentsOf) != "mlmodelc") {
            throw new Error("contentsOf must be of file type mlmodelc");
        }
        _path = contentsOf;
        _fileName = fileNameFromUrl(_path);
    }

    public function get description():ModelDescription {
        return _description;
    }

    private function safetyCheck():Boolean {
        return (MLANEContext.context);
    }

    public function load(onLoaded:Function = null, onError:Function = null):void {
        if (safetyCheck()) {
            MLANEContext.context.addEventListener(StatusEvent.STATUS, function (event:StatusEvent):void {
                switch (event.level) {
                    case ModelEvent.LOADED:
                        _description = MLANEContext.context.call("getDescription") as ModelDescription;
                        if (onLoaded) {
                            onLoaded.call(null, new ModelEvent(event.level, event.code));
                        }
                        break;
                    case ModelEvent.ERROR:
                        if (onError) {
                            onError.call(null, new ModelEvent(event.level, null, event.code));
                        }
                        break;
                    default:
                        break;
                }
            });
            MLANEContext.context.call("loadModel", _path);
        }
    }

    public static function fromUrl(url:String, onProgress:Function = null, onComplete:Function = null,
                                   onCompiled:Function = null, onError:Function = null):Model {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        if (getExtension(url) != "mlmodel") {
            throw new Error("contentsOf must be of file type mlmodelc");
        }
        var request:URLRequest = new URLRequest(url);
        var downloader:URLLoader = new URLLoader();
        downloader.dataFormat = URLLoaderDataFormat.BINARY;
        if (onProgress) {
            downloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }
        if (onComplete) {
            downloader.addEventListener(Event.COMPLETE, onComplete);
        }
        downloader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var path:String = File.applicationStorageDirectory.resolvePath(fileNameFromUrl(url)).nativePath;
            writeBytesToFile(path, event.target.data as ByteArray);
            MLANEContext.context.addEventListener(StatusEvent.STATUS, function (event:StatusEvent):void {
                switch (event.level) {
                    case CompileEvent.COMPLETE:
                        _path = event.code;
                        if (onCompiled) {
                            onCompiled.call(null, new CompileEvent(event.level, event.code));
                        }
                        break;
                    default:
                        break;
                }
            });
            MLANEContext.context.call("compileModel", path);
        });
        downloader.load(request);
        return new Model();
    }

    public static function fromPath(path:String, onCompiled:Function = null):Model {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        if (getExtension(path) != "mlmodel") {
            throw new Error("contentsOf must be of file type mlmodelc");
        }
        MLANEContext.context.addEventListener(StatusEvent.STATUS, function (event:StatusEvent):void {
            switch (event.level) {
                case CompileEvent.COMPLETE:
                    _path = event.code;
                    _fileName = fileNameFromUrl(_path);
                    if (onCompiled) {
                        onCompiled.call(null, new CompileEvent(event.level, event.code));
                    }
                    break;
                default:
                    break;
            }
        });
        MLANEContext.context.call("compileModel", path);
        return new Model();
    }

    public function prediction(inputs:Object):void {
        MLANEContext.context.call("prediction", inputs);
    }

    private static function fileNameFromUrl(path:String):String {
        var arr:Array = path.split("/");
        return arr[arr.length - 1];
    }

    private static function writeBytesToFile(fileName:String, data:ByteArray):void {
        var outFile:File = File.desktopDirectory;
        outFile = outFile.resolvePath(fileName);
        var outStream:FileStream = new FileStream();
        outStream.open(outFile, FileMode.WRITE);
        outStream.writeBytes(data, 0, data.length);
        outStream.close();
    }

    private static function getExtension(file:String):String {
        return file.substring(file.lastIndexOf(".") + 1, file.length);
    }

    public function get path():String {
        return _path;
    }

    public function get fileName():String {
        return _fileName;
    }
}
}
