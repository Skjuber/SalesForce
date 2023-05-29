trigger Task2Trigger on Sale__c (before insert, before update) {
    // Get Account Ids from the incoming Sales records
    Set<Id> accountIds = new Set<Id>();
    for(Sale__c sale : Trigger.new) {
        accountIds.add(sale.Account__c);
    }
    
    // Query the Accounts related to these Sales
    Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
    
    // Now we go through the list of Sales again and update the 'Custom Name' field
    for (Sale__c sale : Trigger.new) {
        // Get the associated Account's name and combine it with the Sale's record number
        Account a = accounts.get(sale.Account__c);
        if (a != null) {
            sale.Custom_Name__c = a.Name + '-' + sale.Name;
        }
    }
}
