require 'test_helper'

class DigTest < ActiveSupport::TestCase

  # 只用blog来测试
  # 具体什么时候能挖，在具体的diggable类里测试
  # 这里只测试基本的计数器和是否是重复挖
  def setup
    @user = UserFactory.create
    @character = GameCharacterFactory.create :user_id => @user.id
    @game = @character.game
  
    # create 4 friends
    @friend = UserFactory.create
    FriendFactory.create @user, @friend
    
    # create stranger
    @stranger = UserFactory.create

    # create same-game-user
    @same_game_user = UserFactory.create
    @character2 = GameCharacterFactory.create :game_id => @character.game_id, :area_id => @character.area_id, :server_id => @character.server_id, :race_id => @character.race_id, :profession_id => @character.profession_id, :user_id => @same_game_user.id
  
    @blog = BlogFactory.create :poster_id => @user.id, :game_id => @game.id
  end

  test "counter" do
    assert @blog.dug_by(@user)
    @blog.reload
    assert_equal @blog.digs_count, 1

    assert @blog.dug_by(@friend)
    @blog.reload
    assert_equal @blog.digs_count, 2

    assert @blog.dug_by(@same_game_user)
    @blog.reload
    assert_equal @blog.digs_count, 3

    assert @blog.dug_by(@stranger)
    @blog.reload
    assert_equal @blog.digs_count, 4
  end

  test "dig repeatedly" do
    assert @blog.dug_by(@user)
    @blog.reload
    assert_equal @blog.digs_count, 1

    assert !@blog.dug_by(@user)
    @blog.reload
    assert_equal @blog.digs_count, 1

    assert !@blog.dug_by(@user)
    @blog.reload
    assert_equal @blog.digs_count, 1
  end

end
