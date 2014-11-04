module AutomationObject
  class Modal < Screen
    def initialize(modal_name, params)
      super(params)
      self.framework_location = self.framework_location + ".#{modal_name}"
    end
  end
end