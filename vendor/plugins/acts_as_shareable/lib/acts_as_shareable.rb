# ActsAsShareable
module Shareable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def acts_as_shareable opts={}
      # 只能有一个
      has_one :share, :as => 'shareable', :dependent => :destroy

      include Shareable::InstanceMethods

      extend Shareable::SingletonMethods
      
      # register this resource with share class
      ::Share.register(self.name, opts.delete(:path_reg) || /\/[^\/]+\/([\d]+)/)

      cattr_accessor :share_opts

      self.share_opts = opts

    end

  end

  module SingletonMethods
  end

  module InstanceMethods

    def sharings_count
      share.blank? ? 0 : share.sharings_count
    end

    def shared_by? user
      share && !share.sharings.find_by_poster_id(user.id).blank?
    end

    def share_by user, title='', reason=''
      # find or create a share
      share = Share.find_or_create(:shareable_type => self.class.base_class.name, :shareable_id => self.id)
      sharing = share.sharings.build(:poster_id => user.id, :title => title, :reason => reason)
      if sharing.save
        true 
      else
        share.destroy if share.sharings_count == 0
        false
      end
    end

    def is_shareable_by? user
      proc = self.class.share_opts[:create_conditions] || lambda { true }
      proc.call user, self 
    end

    def first_sharer
      share.blank? ? nil : share.first_sharer
    end

    def default_share_title
      @default_share_title unless @default_share_title.blank?
      proc = self.class.share_opts[:default_title] || lambda { '' }
      @default_share_title = proc.call self 
    end

  end

end

ActiveRecord::Base.send(:include, Shareable)
