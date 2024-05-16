trigger AssignApplicationToQueue on Application__c (before insert) {

    // Grab related company IDs and store in a set
    Set<Id> companyIds = new Set<Id>();
    for (Application__c app : Trigger.new) {
        if (app.Company__c != null) {
            companyIds.add(app.Company__c);
        }
    }

    // Grab all related companies and store in a map
    Map<Id, Account> companies = new Map<Id, Account>(
        [SELECT Id, Region__c FROM Account WHERE Id IN :companyIds]
    );
    
    // Grab all sales queues and store them in a map
    Map<String, Group> queues = new Map<String, Group>();
    for (Group queue : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name LIKE '%Sales%']) {
        queues.put(queue.Name, queue);
    }

    // Process each application and find the appropriate queue to assign as owner
    for (Application__c app : Trigger.new) {
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