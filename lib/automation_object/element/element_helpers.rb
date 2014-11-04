module AutomationObject
  module ElementHelpers
    def get_selector_params(configuration)
      params = Hash.new
      if configuration['xpath']
        params[:selector_method] = :xpath
        params[:selector] = configuration['xpath']
      elsif configuration['css']
        params[:selector_method] = :css
        params[:selector] = configuration['css']
      else
        raise(ArgumentError, 'xPath and CSS are the only element selectors available')
      end

      params
    end

    def is_multiple?
      return true if self.configuration['multiple'] == true
      return false
    end

    def in_iframe?
      return false unless configuration.is_a?(Hash)
      return false unless configuration.has_key?('in_iframe')
      return true if configuration['in_iframe']
    end
  end
end