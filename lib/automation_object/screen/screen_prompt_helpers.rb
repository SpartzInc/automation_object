module AutomationObject
  module ScreenPromptHelpers
    include AutomationObject::HookHelpers

    def accept
      AutomationObject::Logger::add('Accepting Alert Prompt', [self.framework_location])

      self.do_hook_action('accept', 'before')

      if self.driver_object.respond_to?(:alert_accept)
        self.driver_object.alert_accept
      else
        alert = self.driver_object.switch_to.alert
        alert.accept
      end

      self.do_hook_action('accept', 'after')
    end

    def dismiss
      AutomationObject::Logger::add('Dismissing Alert Prompt', [self.framework_location])

      self.do_hook_action('dismiss', 'before')

      if self.driver_object.respond_to?(:alert_dismiss)
        self.driver_object.alert_dismiss
      else
        alert = self.driver_object.switch_to.alert
        alert.dismiss
      end

      self.do_hook_action('dismiss', 'after')
    end
  end
end