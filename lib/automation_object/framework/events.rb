module AutomationObject
  module FrameworkEvents
    def screen_change_emit(screen_class_symbol)
      screen_name = self.translate_class_to_string(screen_class_symbol)
      self.emit(:screen_change, screen_name)
    end
  end
end