public class UpdateWithExceptions {
    public static void SafeUpdate(List<SObject> inputs) {
        try {
            update inputs;
        } catch (DmlException e) {
            System.debug('DML Exception Thrown: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Exception Thrown: ' + e.getMessage());
        }
    }
}