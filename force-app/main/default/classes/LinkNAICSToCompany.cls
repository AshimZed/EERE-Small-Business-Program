public class LinkNAICSToCompany {

    public class CompanyInput {
        @InvocableVariable(label='Company Id')
        public Id companyId;

        @InvocableVariable(label='NAICS Code')
        public String codeNAICS;
    }

    public class LinkNAICSResultFlag {
        @InvocableVariable(label='Established Relationship?')
        public Boolean hasRelationship;
    }

    @InvocableMethod(label='')
    public static List<LinkNAICSResultFlag> linkNAICS(List<CompanyInput> inputs) {
        
        System.debug('linkNAICS has been called');

        // Create lists for our variables
        List<Account> companiesToUpdate = new List<Account>();
        List<LinkNAICSResultFlag> results = new List<LinkNAICSResultFlag>();

        // Loop through the inputs
        for (CompanyInput input : inputs) {
            LinkNAICSResultFlag result = new LinkNAICSResultFlag();
            try {

                // Query for the NAICS records that match the NAICS Code
                Industry__c naics = [SELECT Id FROM Industry__c WHERE NAICS_Code__c = :input.codeNAICS LIMIT 1];

                // If a matching NAICS Industry is located, set the lookup field on the company
                if (naics != null) {
                    Account currentAccount = new Account(Id=input.companyId, Industry_NAICS__c=naics.Id);
                    companiesToUpdate.add(currentAccount);
                    System.debug('Added: ' + currentAccount + 'to companies to update');

                    result.hasRelationship = True; // Set the flag as true
                    results.add(result);
                } else {
                    result.hasRelationship = False; // Set the flag as false
                    results.add(result);
                }
            } catch (Exception e) {
                result.hasRelationship = False; // Set the flag as false
                results.add(result);
                System.debug('Error linking NAICS: ' + e.getMessage());
            }
        }

        // Update the companies if there are any to update
        if (!companiesToUpdate.isEmpty()) {
            UpdateWithExceptions.SafeUpdate(companiesToUpdate);
        }

        return results;
    }
}