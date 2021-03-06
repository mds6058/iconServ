
require "open-uri"
require "public_suffix"
require "em-http-request"

class NetworkHelper
  include EM::Deferrable
  
  def self.getValidUrl(domain)
    
    #Remove "www" (or http) if it is there
    domain = domain.sub(/^https?\:\/\//, '').sub(/^www./,'')
    
    urlString = "http://#{domain}/"
    
    #Check to make sure the url is valid
    if !urlString.match /\A#{URI::regexp(['http', 'https'])}\z/
    
      urlString = nil
        
    end
    
    #Check to make sure domain is real
    if urlString and self.getRealDomainName(urlString) == nil
      
      urlString = nil
      
    end
    
    if urlString
      

      
      url = URI.parse(urlString)
    end
    
    return url
    
  end
  
  
  #Get the "real" domain name - the top level name + the TLD (i.e. "google.com", not "www.google.com")
  def self.getRealDomainName(urlString)
    
    uri = URI.parse(urlString)
    
    begin
      domainObject = PublicSuffix.parse(uri.host)
      domain = domainObject.domain
    rescue
      domain = nil
    end
    
    return domain
    
    
  end
  
  #Checks to see if the url supplied is the "real" url.  Supplies a redirected url if it is not
  
  def self.getRealUrlLocation(urlString)
    
    begin
    
      url = URI.parse(urlString)
      req = EM::HttpRequest.new(urlString).get
      req.callback {
        
        if req.response_header.status == 200
          returnUrl = urlString
        #Redirect (300 codes)
        elsif req.response_header.status / 100 == 3
          returnUrl = req.response_header['location']
        else
          returnUrl = ""
        end
        
        yield returnUrl
        
      }
      req.errback {
        yield ""
      }
      
    rescue
        yield ""
    end
         
  end
  
end