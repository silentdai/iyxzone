class Tag < ActiveRecord::Base

	has_many :taggings, :dependent => :delete_all

	named_scope :game_tags, :conditions => {:taggable_type => 'Game'}

	named_scope :profile_tags, :conditions => {:taggable_type => 'Profile'}

  #needs_verification 
 
  acts_as_pinyin :name => "pinyin"

  searcher_column :pinyin, :name

  validates_presence_of :name, :message => "不能为空"

  validates_size_of :name, :within => 1..15, :too_short => "最短1个字符", :too_long => "最长15个字符", :allow_blank => true

  validates_bytes_of :name, :within => 1..30, :too_short => "最短1个字节", :too_long => "最长30个字节", :allow_blank => true

  validates_presence_of :taggable_type, :message => "不能为空"

  validates_uniqueness_of :name, :scope => :taggable_type, :message => "已经有了", :if => "!name.blank? and !taggable_type.blank?"

end
