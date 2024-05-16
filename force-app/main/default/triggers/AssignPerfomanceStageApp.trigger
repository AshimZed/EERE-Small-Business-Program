trigger AssignPerfomanceStageApp on Application__c (before update) {

    // Make a list of applications to set in queues
    List<Application__c> appsToQueue = new List<Application__c>();

    // Loop through updated applications
    for (Application__c app : Trigger.new) {
        String oldStage = Trigger.oldMap.get(app.Id).Stage__c;

        // Check if the stage was changed to Project Performance
        if (app.Stage__c != oldStage && app.Stage__c == 'Project Performance') {
            appsToQueue.add(app); // Add the application to the apps to queue
        }
    }

    // Grab related company IDs and store in a set
    Set<Id> companyIds = new Set<Id>();
    for (Application__c app : appsToQueue) {
        if (app.Company__c != null) {
            companyIds.add(app.Company__c);
        }
    }

    // Grab all related companies and store in a map
    Map<Id, Account> companies = new Map<Id, Account>(
        [SELECT Id, Region__c FROM Account WHERE Id IN :companyIds]
    );

    // Grab all service queues and store them in a map
    Map<String, Group> queues = new Map<String, Group>();
    for (Group queue : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name LIKE '%Service%']) {
        queues.put(queue.Name, queue);
    }

    // Process each application and find the appropriate queue to assign as owner
    for (Application__c app : appsToQueue) {
        if (app.Company__c != null && companies.containsKey(app.Company__c)) {
            Account company = companies.get(app.Company__c);
            String region = company.Region__c;

            // Find the queue that matches the region
            for (String queueName : queues.keySet()) {
                if (queueName.contains(region)) {
                    app.OwnerId = queues.get(queueName).Id;
                    break; // Exit loop once the correct queue is found
                }
            }
        }
    }

}