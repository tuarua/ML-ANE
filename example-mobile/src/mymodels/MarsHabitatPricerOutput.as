package mymodels {
public class MarsHabitatPricerOutput {
    public var price:Number;
    public function MarsHabitatPricerOutput(mapFrom:Object) {
        try {
            this.price = mapFrom.price.doubleV;
        } catch (e:Error) {
            trace("MarsHabitatPricerOutput", e.message);
        }
    }
}
}
