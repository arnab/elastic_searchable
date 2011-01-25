module ElasticSearchable
  module Callbacks
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def add_indexing_callbacks
        backgrounded :update_index_on_create => {:queue => 'searchindex'}, :update_index_on_update => {:queue => 'searchindex'}
        class << self
          backgrounded :delete_id_from_index => {:queue => 'searchindex'}
        end

        define_callbacks :after_index_on_create, :after_index_on_update, :after_index
        after_commit_on_create :update_index_on_create_backgrounded
        after_commit_on_update :update_index_on_update_backgrounded
        after_commit_on_destroy Proc.new {|o| o.class.delete_id_from_index_backgrounded(o.id) }
      end
    end

    def update_index_on_create
      local_index_in_elastic_search :lifecycle => :create
    end
    def update_index_on_update
      local_index_in_elastic_search :lifecycle => :update
    end
  end
end
