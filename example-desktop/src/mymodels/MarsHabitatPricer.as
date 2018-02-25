package mymodels {
public class MarsHabitatPricer {
    public var input:MarsHabitatPricerInput;

    public function MarsHabitatPricer(solarPanels:Number, greenhouses:Number, size:Number) {
        input = new MarsHabitatPricerInput(solarPanels, greenhouses, size);
    }
}
}