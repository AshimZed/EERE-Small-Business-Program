public class LinkFOAToLead {

    // Class definition to facilitate input:
    public class LeadInput {
        @InvocableVariable(label='Lead Id')
        public Id leadId;

        @InvocableVariable(label='FOA Number')
        public String foaNumber;
    }

    public class LinkFOAResultFlag {
        @InvocableVariable(label='Relationship Flag')
        public Boolean hasRelationship;
    }

    // Method to link FOA
    @InvocableMethod(label='Link FOA to Lead')
    public static List<LinkFOAResultFlag> linkFOA(List<LeadInput> inputs) {

        System.debug('linkFOA has been called');

        // Create a list to store our result flags
        List<LinkFOAResultFlag> results = new List<LinkFOAResultFlag>();

        // Create a list to store our leads that need to update
        List<Lead> leadsToUpdate = new List<Lead>();

        // Loop through the inputs
        for (LeadInput input : inputs) { 
            LinkFOAResultFlag result = new LinkFOAResultFlag();
            
            try {
                // Query for the FOA records that match the FOA number
                Funding_Opportunity_Announcement__c foa = Database.query('SELECT Id FROM Funding_Opportunity_Announcement__c WHERE Name = \'' + input.foaNumber + '\' LIMIT 1');

                // If a matching FOA is located, set the lookup field on the lead
                if (foa != null) {
                    Lead currentLead = new Lead(Id=input.leadId, Funding_Opportunity_Announcement__c=foa.Id);
                    leadsToUpdate.add(currentLead);
                    System.debug('Added ' + currentLead + 'to leads to update');

                    result.hasRelationship = True; // Set the flag as true
                    results.add(result);
                } else {
                result.hasRelationship = False; // Set the flag as false
                results.add(result);
                }
            } catch (Exception e) {
                result.hasRelationship = False; // Set the flag as false
                results.add(result);
                System.debug('Error linking FOAs: ' + e.getMessage());
            }
        }

        // Update the leads if there are any to update
        if (!leadsToUpdate.isEmpty()) {
            UpdateWithExceptions.SafeUpdate(leadsToUpdate);
        }

        return results;
    }
}