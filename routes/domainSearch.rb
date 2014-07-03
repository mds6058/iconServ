
#require_relative '../controllers/testController'
require_relative '../controllers/domainSearchController'

class MyApp < Sinatra::Application
  
  aget '/*' do
    
   path = params[:splat].first
   
   content_type :json
   
   domainSearchController = DomainSearchController.new
   
   domainSearchController.findIconForDomain(path) { |jsonArray|
      
      body { jsonArray } 
     
   }
   
  end
  

  
end