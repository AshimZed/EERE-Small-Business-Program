trigger ValidateApplicationOrder on Application__c (before update) {

    for (Application__c app : Trigger.new) {
        Application__c oldApp = Trigger.oldMap.get(app.Id);

        // Set up check values
        Boolean isValidTransition = ApplicationOrderCheck.isValidStageTransition(oldApp.Stage__c, app.Stage__c)
                                    || ApplicationOrderCheck.isBackwardsStageTransition(oldApp.Stage__c, app.Stage__c);

        // Check if the old stage is directly before the new stage
        if (!isValidTransition) {
            app.addError('You cannot skip stages. Please complete the stages in order.'); // Throw error if stages are not in order
        }
    }

}