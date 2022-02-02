@isTest
public with sharing class FindTextTest {


    @isTest static void CanFindPrefixedID() {
        String testText = 'Email Text Body: User User has requested your approval for the following item: https://ruby-force-1213-dev-ed.cs97.my.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id=04i0U000000eAKS Please click this link to approve or reject this record.';
        String length = '15';
        String prefix = 'id=';
        String searchType = 'prefixSearch';

       
        FindText.Requests curRequest = new FindText.Requests();
        curRequest.inputString = testText;
        curRequest.length = length;
        curRequest.prefix = prefix;
        curRequest.searchType = searchType;

        List<FindText.Requests> curRequests = new  List<FindText.Requests>();
        curRequests.add(curRequest);
        List<FindText.Results> results = FindText.execute(curRequests);
        FindText.Results result =  results[0] ;
        System.assertEquals('04i0U000000eAKS', result.foundString);
        
    }

    @isTest static void CanFindBetween() {
        String testText = 'Email Text Body: User User has requested your approval for the following item: https://ruby-force-1213-dev-ed.cs97.my.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id=04i0U000000eAKS Please click this link to approve or reject this record.';
        String prefix = 'id=';
        String suffix = ' Please';
        String searchType = 'betweenSearch';

       
        FindText.Requests curRequest = new FindText.Requests();
        curRequest.inputString = testText;
        curRequest.suffix = suffix;
        curRequest.prefix = prefix;
        curRequest.searchType = searchType;

        List<FindText.Requests> curRequests = new  List<FindText.Requests>();
        curRequests.add(curRequest);
        List<FindText.Results> results = FindText.execute(curRequests);
        FindText.Results result =  results[0] ;
        System.assertEquals('04i0U000000eAKS', result.foundString);
        
    }

    @isTest static void CanFindPrefixedToEndID() {
        String testText = 'Email Text Body: User User has requested your approval for the following item: https://ruby-force-1213-dev-ed.cs97.my.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id=04i0U000000eAKS Please click this link to approve or reject this record.';
        String prefix = 'id=';
        String searchType = 'prefixtoendSearch';

        FindText.Requests curRequest = new FindText.Requests();
        curRequest.inputString = testText;
        curRequest.prefix = prefix;
        curRequest.searchType = searchType;

        List<FindText.Requests> curRequests = new  List<FindText.Requests>();
        curRequests.add(curRequest);
        List<FindText.Results> results = FindText.execute(curRequests);
        FindText.Results result =  results[0] ;
        System.assertEquals('04i0U000000eAKS Please click this link to approve or reject this record.', result.foundString);
        
    }

    @isTest static void InvalidFind() {
        String testText = 'Email Text Body: User User has requested your approval for the following item: https://ruby-force-1213-dev-ed.cs97.my.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id=04i0U000000eAKS Please click this link to approve or reject this record.';
        String prefix = 'id=';
        String suffix = ' Please';
        String searchType = 'Invalid';

       
        FindText.Requests curRequest = new FindText.Requests();
        curRequest.inputString = testText;
        curRequest.suffix = suffix;
        curRequest.prefix = prefix;
        curRequest.searchType = searchType;

        List<FindText.Requests> curRequests = new  List<FindText.Requests>();


        try {
            curRequests.add(curRequest);
            List<FindText.Results> results = FindText.execute(curRequests);
            FindText.Results result =  results[0] ;
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('currently the supported search types for the FindText action are'), 'message=' + e.getMessage());
        }

        
    }
}