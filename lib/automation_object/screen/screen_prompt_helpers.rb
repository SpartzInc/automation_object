module AutomationObject
  module ScreenPromptHelpers
    include AutomationObject::HookHelpers

    def accept
      AutomationObject::Logger::add('Accepting Alert Prompt', [self.framework_location])

      self.do_hook_action('accept', 'before')
      self.driver_object.accept_prompt
      self.do_hook_action('accept', 'after')
    end

    def dismiss
      AutomationObject::Logger::add('Dismissing Alert Prompt', [self.framework_location])

      self.do_hook_action('dismiss', 'before')
      self.driver_object.dismiss_prompt
      self.do_hook_action('dismiss', 'after')
    end
  end
end