# A metrics interface which does not record metrics
module Warehouse
  class Analytics
    class NullMetrics
      def increment(_key, _value)
      end

      def gauge(_key, _value)
      end

      def time(_key)
        yield
      end
    end
  end
end
