package com.tuarua.mlane {
public class Classification {
    public var label:String;
    public var confidence:Number;

    /** @private */
    public function Classification(label:String, confidence:Number) {
        this.label = label;
        this.confidence = confidence;
    }
}
}
