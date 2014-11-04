module AutomationObject
  module Driver
    class Anonymous
      def initialize(driver_object, object)
        @driver_object = driver_object
        @object = object
      end

      def respond_to?(method_symbol, include_private = false)
        @driver_object.mutex_object.synchronize do
          return @object.respond_to?(method_symbol, include_private)
        end
      end

      def method_missing(method_symbol, *arguments, &block)
        start_time = Time.new.to_f

        @driver_object.mutex_object.synchronize do
          object_return = @object.send(method_symbol, *arguments, &block)

          total_time_taken = (Time.new.to_f-start_time)
          return object_return
        end
      end
    end
  end
end