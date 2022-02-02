public with sharing class FindText {

    @InvocableMethod
    public static List<Results> execute(List<Requests> requests) {
        List<Results> responseWrapper = new List<Results>();
        for (Requests curRequest : requests) {
            Results response = new Results();
            response.foundStringCollection = new List<String>();      
            
            switch on curRequest.searchType {
                when 'prefixSearch' {		
                    //the regex id=(.{15}) captures the first 15 characters following the string 'id='

                    String matchPattern = '(?<=' + curRequest.prefix + ').{' + curRequest.length + '}';
                    Pattern MyPattern = Pattern.compile(matchPattern);

                    Matcher MyMatcher = MyPattern.matcher(curRequest.inputString);
                    while (MyMatcher.find())
                    {
                        System.debug('Start index: '+ MyMatcher.start());
                        System.debug(' End index: ' + MyMatcher.end() + ' ');
                        System.debug(MyMatcher.group());
                        response.foundStringCollection.add(MyMatcher.group());
                    }
                    System.debug('done finding');
                }	
                when 'betweenSearch' {		
                    // this substring function will find the prefix (value before) and sufix (value after) and return a string between.
                    String substring = curRequest.inputString.substringAfter(curRequest.prefix).substringBefore(curRequest.suffix);
                    response.foundStringCollection.add(substring);
                }	
                when 'prefixtoendSearch' {		
                    // this substring will take a prefix (value before) and go to the end of the text
                    String substring = curRequest.inputString.substringAfter(curRequest.prefix);
                    response.foundStringCollection.add(substring);
                }	                
                when else {		  // default block, optional
                    throw new InvocableErrorException('currently the supported search types for the FindText action are: prefixSearch, betweenSearch, prefixtoendSearch');  
                }
            }
            if (!response.foundStringCollection.isEmpty()) {
                response.foundString = response.foundStringCollection[0];
                System.debug('found a string: ' + response.foundString);
            }                           
            //Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
            responseWrapper.add(response);
        }
        return responseWrapper;
    }    

    public class InvocableErrorException extends Exception {
    }


    public class Requests {

        @InvocableVariable
        public String searchType;  //default is 'prefix'

        @InvocableVariable
        public String prefix;
        
        @InvocableVariable
        public String suffix; //value that will end the string

        @InvocableVariable
        public String length; // number of characters

        @InvocableVariable
        public String inputString; // number of characters



    }

    public class Results {

        @InvocableVariable
        public String foundString;

        @InvocableVariable
        public List<String> foundStringCollection;


    }
}