package mymodels {
public class MarsHabitatPricerInput {
    public var solarPanels:Number;
    public var greenhouses:Number;
    public var size:Number;

    public function MarsHabitatPricerInput(solarPanels:Number, greenhouses:Number, size:Number) {
        this.solarPanels = solarPanels;
        this.greenhouses = greenhouses;
        this.size = size;
    }

    public function getProperties():Array { //used in ANE
        return ["solarPanels", "greenhouses", "size"];
    }
}
}
