public class ApplicationOrderCheck {

    public static Map<String,Integer> stageOrder = new Map<String,Integer>{
        'Concept Paper'       => 1,
        'Full Application'    => 2,
        'Selection'           => 3,
        'Negotiation'         => 4,
        'Project Performance' => 5
    };

    public static Boolean isValidStageTransition(String oldStage, String newStage) {
        Integer newPlace = stageOrder.get(newStage);
        Integer oldPlace = stageOrder.get(oldStage);
        return newPlace == oldPlace + 1 || newPlace == oldPlace;
    }

    public static Boolean isBackwardsStageTransition(String oldStage, String newStage) {
        return stageOrder.get(newStage) < stageOrder.get(oldStage);
    }
}