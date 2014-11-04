require_relative 'automation_object/version'

#Third-Party
require 'event_emitter'
require 'thread'
require 'colorize'
require 'awesome_print'
require 'yaml'

#Convience methods
require_relative 'automation_object/hash'
require_relative 'automation_object/object'
require_relative 'automation_object/logger'

#Driver Object that has Mutex for keeping Thread Safe!
require_relative 'automation_object/driver/anonymous'
require_relative 'automation_object/driver/element'
require_relative 'automation_object/driver/driver'

#HookHelper Module
require_relative 'automation_object/hook_helpers'

#BluePrintValidation Module
require_relative 'automation_object/blue_print_validation/key_value_constants'
require_relative 'automation_object/blue_print_validation/formatted_errors'
require_relative 'automation_object/blue_print_validation/common_methods'
require_relative 'automation_object/blue_print_validation/base_validation'
require_relative 'automation_object/blue_print_validation/screen_modal_common_methods'
require_relative 'automation_object/blue_print_validation/screen_validation'
require_relative 'automation_object/blue_print_validation/modal_validation'
require_relative 'automation_object/blue_print_validation/element_validation'
require_relative 'automation_object/blue_print_validation/hook_validation'
require_relative 'automation_object/blue_print_validation/validation_object'

#BluePrint
require_relative 'automation_object/blue_print'

#Framework Object
require_relative 'automation_object/framework_helpers'
require_relative 'automation_object/framework_window_helpers'
require_relative 'automation_object/framework_print_objects'
require_relative 'automation_object/framework_screen_routing'
require_relative 'automation_object/framework_screen_monitor'
require_relative 'automation_object/framework_events'
require_relative 'automation_object/framework'

#Screen/Modal Objects
require_relative 'automation_object/screen/screen_window_helpers'
require_relative 'automation_object/screen/screen_hook_helpers'
require_relative 'automation_object/screen/screen_prompt_helpers'
require_relative 'automation_object/screen/screen_modal_helpers'
require_relative 'automation_object/screen/screen'
require_relative 'automation_object/screen/modal'

#Element/ElementHash/ElementArray Objects
require_relative 'automation_object/element/element_helpers'
require_relative 'automation_object/element/elements_helpers'
require_relative 'automation_object/element/element_methods'
require_relative 'automation_object/element/element'
require_relative 'automation_object/element/element_array'
require_relative 'automation_object/element/element_hash'

#ElementGroup
require_relative 'automation_object/element/element_group'
require_relative 'automation_object/element/element_cell'

module AutomationObject
  @@debug_mode = false

  def self.debug_mode
    @@debug_mode
  end

  def self.debug_mode=(value)
    @@debug_mode = value
  end
end
