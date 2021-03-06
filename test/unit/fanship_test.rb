require 'test_helper'

class FanshipTest < ActiveSupport::TestCase
  
  def setup
    @user1 = UserFactory.create
    @user2 = UserFactory.create
    @friend = UserFactory.create
    FriendFactory.create @user1, @friend

    @idol1 = UserFactory.create :is_idol => true 
    @idol2 = UserFactory.create :is_idol => true 
  end

  test "relationship" do
    @fanship = Fanship.create :fan_id => @user1.id, :idol_id => @idol1.id
    @user1.reload and @idol1.reload
    assert_equal @user1.relationship_with(@idol1), 'friend'
    assert_equal @idol1.relationship_with(@user1), 'friend'
  end

  test "counter" do
    assert_difference "Fanship.count" do
      @fanship = Fanship.create :fan_id => @user1.id, :idol_id => @idol1.id
    end
    @idol1.reload and @user1.reload
    assert_equal @idol1.fans_count, 1
    assert_equal @user1.idols_count, 1

    assert_difference "Fanship.count" do
      @fanship = Fanship.create :fan_id => @user2.id, :idol_id => @idol1.id
    end
    @idol1.reload and @user2.reload
    assert_equal @idol1.fans_count, 2
    assert_equal @user2.idols_count, 1

    assert_difference "Fanship.count" do
      @fanship = Fanship.create :fan_id => @user2.id, :idol_id => @idol2.id
    end
    @idol2.reload and @user2.reload
    assert_equal @idol2.fans_count, 1
    assert_equal @user2.idols_count, 2
  
    assert_difference "Fanship.count", -1 do
      @fanship.destroy
    end
    @idol2.reload and @user2.reload
    assert_equal @idol2.fans_count, 0
    assert_equal @user2.idols_count, 1
  end

  test "associations" do
    assert_difference "Fanship.count" do
      @fanship = Fanship.create :fan_id => @user1.id, :idol_id => @idol1.id
    end
    @idol1.reload and @user1.reload
    assert @idol1.has_fan? @user1
    assert @user1.has_idol? @idol1

    assert_difference "Fanship.count" do
      @fanship = Fanship.create :fan_id => @user2.id, :idol_id => @idol1.id
    end
    @idol1.reload and @user2.reload
    assert @idol1.has_fan? @user2
    assert @user2.has_idol? @idol1

    assert_difference "Fanship.count", -1 do
      @fanship.destroy
    end
    @idol1.reload
    assert !@idol1.has_fan?(@user2)
  end

  test "create fanship" do
    # 偶像不存在
    assert_no_difference "Fanship.count" do
      Fanship.create :fan_id => @user1.id, :idol_id => 'invalid'
    end

    # 加自己为偶像
    assert_no_difference "Fanship.count" do
      Fanship.create :fan_id => @idol1.id, :idol_id=> @idol1.id
    end

    # @user2 不是偶像人物
    assert_no_difference "Fanship.count" do
      Fanship.create :fan_id => @user1.id, :idol_id => @user2.id 
    end

    # 好友不能同时是偶像
    assert_no_difference "Fanship.count" do
      Fanship.create :fan_id => @user1.id, :idol_id => @friend.id
    end

    # 不是好友，不是粉丝可以加为偶像
    assert_difference "Fanship.count" do
      Fanship.create :fan_id => @user1.id, :idol_id => @idol1.id
    end

    # 不能重复加偶像
    assert_no_difference "Fanship.count" do
      Fanship.create :fan_id => @user1.id, :idol_id => @idol1.id
    end
  end

  test "friendship and fanship" do
    assert_difference "Fanship.count" do
      Fanship.create :fan_id => @user1.id, :idol_id => @idol1.id
    end

    # 已经是偶像－粉丝关系了，那就没发成为好友关系
    assert_no_difference "Friendship.count" do
      Friendship.create :user_id => @user1.id, :friend_id => @idol1.id, :status => Friendship::Request
    end

    assert_no_difference "Friendship.count" do
      Friendship.create :user_id => @idol1.id, :friend_id => @user1.id, :status => Friendship::Request
    end

    # 偶像能和不是偶像－粉丝关系的人加为好友，无论那人是不是偶像
    assert_difference "Friendship.count" do
      Friendship.create :user_id => @idol1.id, :friend_id => @idol2.id, :status => Friendship::Request
    end 

    assert_difference "Friendship.count" do
      Friendship.create :user_id => @idol1.id, :friend_id => @friend.id, :status => Friendship::Request
    end 
  end

end
