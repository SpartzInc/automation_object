module AutomationObject
  module BluePrintValidation
    module KeyValueConstants
      ELEMENT_KEYS = ['length', 'exists?', 'click', 'visible?', 'invisible?',
                      'id', 'href', 'scroll_to_view', 'x', 'y', 'width', 'height', 'drag_to_element',
                      'get_element_center', 'name', 'value', 'type', 'clear', 'tag_name', 'text',
                      'size', 'location', 'rel_location', 'send_keys', 'set_value', 'displayed?', 'selected?',
                      'attribute', 'clear', 'attribute', 'click', 'css_value', 'displayed?', 'enabled?',
                      'location', 'location_once_scrolled_into_view', 'ref', 'selected?', 'send_keys',
                      'size', 'submit', 'tag_name', 'text', 'content']

      HOOK_KEYS = ['live?', 'before_load', 'accept', 'dismiss', 'scroll_up', 'scroll_down', 'scroll_right', 'scroll_left']

      BASE_PAIR_TYPES = {
          'base_url' => String,
          'default_screen' => String,
          'throttle_element_interactions' => Hash,
          'throttle_element_methods' => Hash,
          'throttle_driver_methods' => Hash,
          'screen_transition_sleep' => Numeric,
          'views' => Hash,
          'screens' => Hash
      }

      THROTTLE_ELEMENT_PAIR_TYPES = Hash[*ELEMENT_KEYS.collect { |v| [v, Numeric] }.flatten]

      SCREEN_PAIR_TYPES = {
          'modals' => Hash,
          'included_views' => Array,
          'automatic_screen_changes' => Array,
          'elements' => Hash,
          'element_groups' => Hash
      }.merge(Hash[*HOOK_KEYS.collect { |v| [v, Hash] }.flatten])

      MODAL_PAIR_TYPES = SCREEN_PAIR_TYPES

      ELEMENT_PAIR_TYPES = {
          'in_iframe' => String,
          'css' => String,
          'xpath' => String,
          'multiple' => TrueClass,
          'multiple_ios_fix' => TrueClass,
          'define_elements_by' => String,
          'custom_methods' => Hash,
          'custom_range' => Hash,
          'remove_duplicates' => String
      }.merge(Hash[*ELEMENT_KEYS.collect { |v| [v, Hash] }.flatten])

      ELEMENT_CUSTOM_METHOD_PAIR_TYPES = {
          'element_method' => String,
          'evaluate' => String
      }

      HOOK_PAIR_TYPES = {
          'before' => Hash,
          'after' => Hash,
          'elements' => Array
      }

      HOOK_ACTION_PAIR_TYPES = {
          'wait_for_new_window' => TrueClass,
          'show_modal' => String,
          'close_window' => TrueClass,
          'change_screen' => String,
          'sleep' => Numeric,
          'wait_for_elements' => Array,
          'change_to_previous_screen' => TrueClass,
          'close_modal' => TrueClass,
          'automatic_onload_modals' => Array,
          'reset_screen' => TrueClass,
          'possible_screen_changes' => Array
      }
    end
  end
end