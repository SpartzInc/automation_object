module AutomationObject
  module HookHelpers
    def do_hook_action(action, timing, created_window_handle = false)
      self.before_mutex_lock if action == 'before'

      #Return out if it doesn't meet the given requirements
      return unless self.configuration.class == Hash
      return unless self.configuration[action].class == Hash
      return unless self.configuration[action][timing].class == Hash

      hook_configuration = self.configuration[action][timing].clone
      self.hook(hook_configuration, created_window_handle)

      self.after_mutex_lock if action == 'after'
    end

    def before_mutex_lock
      return unless Thread.current == Thread.main
      self.framework_object.screen_monitor_mutex_object.lock
    end

    def after_mutex_lock
      return unless Thread.current == Thread.main
      self.framework_object.screen_monitor_mutex_object.unlock
    end
  end
end