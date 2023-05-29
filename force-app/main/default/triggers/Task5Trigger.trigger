trigger Task5Trigger on Sale__c (before insert) {
    // Get Account Ids from the incoming Sales records
    Set<Id> accountIds = new Set<Id>();
    for(Sale__c sale : Trigger.new) {
        accountIds.add(sale.Account__c);
    }
    
    // Query for Primary Contact of these Accounts
    Map<Id, Contact> primaryContactByAccount = new Map<Id, Contact>();
    for(Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Primary__c = true]) {
        primaryContactByAccount.put(c.AccountId, c);
    }
    
    // Go through incoming Sale records again
    for(Sale__c sale : Trigger.new) {
        // Get primary contact for the Account of this Sale
        Contact primaryContact = primaryContactByAccount.get(sale.Account__c);
        if(primaryContact == null) {
            // If there is no primary contact, add an error
            sale.addError('No primary contact associated with this Account.');
        }
        // If the Contact__c field does not exist, commenting out the below line
        // sale.Contact__c = primaryContact.Id;
    }
    
    // After the trigger finished we have to update the Last_sale_date__c on the Account
    List<Account> accountsToUpdate = new List<Account>();
    for(Id accountId : accountIds) {
        accountsToUpdate.add(new Account(Id = accountId, Last_sale_date__c = Date.today()));
    }
    update accountsToUpdate;
}
