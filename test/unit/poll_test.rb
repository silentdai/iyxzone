require 'test_helper'

class PollTest < ActiveSupport::TestCase

  def setup
    @user = UserFactory.create
    @friend = UserFactory.create
    FriendFactory.create @user, @friend
    @stranger = UserFactory.create

    @character1 = GameCharacterFactory.create :user_id => @user.id
    @character2 = GameCharacterFactory.create @character1.game_info.merge({:user_id => @friend.id})
    @game = @character1.game

    @sensitive = '政府'
  end

  #
  # case0
  # create/destroy poll
  #
  test "case0" do
    @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 1, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}]
    @user.reload
    assert_equal @user.polls_count, 1
  
    @poll.votes.create :voter_id => @user.id, :answer_ids => [@poll.answers.first.id]
    @user.reload
    assert_equal @user.participated_polls_count, 0
 
    @poll.votes.create :voter_id => @friend.id, :answer_ids => [@poll.answers.first.id]
    @friend.reload
    assert_equal @friend.participated_polls_count, 1

    @poll.destroy
    @user.reload and @friend.reload
    assert_equal @user.participated_polls_count, 0
    assert_equal @user.polls_count, 0
    assert_equal @friend.participated_polls_count, 0
  end

  #
  # case1
  # simply create a poll with no deadline and public privilege and maximum 1
  # then vote
  #
  test "case1" do
    assert_difference "Poll.count" do
      @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 1, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}]
    end
    @answer1 = @poll.answers[0]
    @answer2 = @poll.answers[1]
    @answer3 = @poll.answers[2]
    @poll.reload
    assert_equal @poll.answers_count, 3
    assert_equal @poll.votes_count, 0
    assert_equal @poll.voters_count, 0 
    assert_equal @answer1.votes_count, 0
    assert_equal @answer2.votes_count, 0
    assert_equal @answer3.votes_count, 0

    assert_no_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => []
    end

    assert_no_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => ['invalid']
    end

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => [@answer1.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 1
    assert_equal @poll.voters_count, 1 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 0
    assert_equal @answer3.votes_count, 0

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @friend.id, :answer_ids => [@answer2.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 2
    assert_equal @poll.voters_count, 2 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 1
    assert_equal @answer3.votes_count, 0

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @stranger.id, :answer_ids => [@answer3.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 3
    assert_equal @poll.voters_count, 3 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 1
    assert_equal @answer3.votes_count, 1
  end

  #
  # case2
  # simply create a poll with deadline and public privilege and maximum 1
  # then vote
  #
  test "case2" do
    assert_difference "Poll.count" do
      @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}]
    end
    @answer1 = @poll.answers[0]
    @answer2 = @poll.answers[1]
    @answer3 = @poll.answers[2]
    @poll.reload
    assert !@poll.expired?
    assert_equal @poll.answers_count, 3
    assert_equal @poll.votes_count, 0
    assert_equal @poll.voters_count, 0 
    assert_equal @answer1.votes_count, 0
    assert_equal @answer2.votes_count, 0
    assert_equal @answer3.votes_count, 0

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => [@answer1.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 1
    assert_equal @poll.voters_count, 1 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 0
    assert_equal @answer3.votes_count, 0

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @friend.id, :answer_ids => [@answer2.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 2
    assert_equal @poll.voters_count, 2 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 1
    assert_equal @answer3.votes_count, 0

    @poll.update_attributes(:deadline => 1.days.ago)
    assert @poll.expired?

    assert_no_difference "Vote.count" do
      @poll.votes.create :voter_id => @stranger.id, :answer_ids => [@answer3.id]
    end
  end

  #
  # case3
  # simply create a poll with deadline and friend privilege and maximum 1
  # then vote
  #
  test "case3" do
    assert_difference "Poll.count" do
      @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 2, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}]
    end
    @answer1 = @poll.answers[0]
    @answer2 = @poll.answers[1]
    @answer3 = @poll.answers[2]
    @poll.reload
    assert !@poll.expired?
    assert @poll.is_votable_by?(@user)
    assert @poll.is_votable_by?(@friend)
    assert !@poll.is_votable_by?(@stranger)
    assert_equal @poll.answers_count, 3
    assert_equal @poll.votes_count, 0
    assert_equal @poll.voters_count, 0 
    assert_equal @answer1.votes_count, 0
    assert_equal @answer2.votes_count, 0
    assert_equal @answer3.votes_count, 0

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => [@answer1.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 1
    assert_equal @poll.voters_count, 1 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 0
    assert_equal @answer3.votes_count, 0

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @friend.id, :answer_ids => [@answer2.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 2
    assert_equal @poll.voters_count, 2 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 1
    assert_equal @answer3.votes_count, 0

    assert_no_difference "Vote.count" do
      @poll.votes.create :voter_id => @stranger.id, :answer_ids => [@answer3.id]
    end
  end

  #
  # case4
  # simply create a poll with no deadline and public privilege and maximum 2
  # then vote
  #
  test "case4" do
    assert_difference "Poll.count" do
      @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 1, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}], :max_multiple => 2
    end
    @answer1 = @poll.answers[0]
    @answer2 = @poll.answers[1]
    @answer3 = @poll.answers[2]
    @poll.reload
    assert_equal @poll.answers_count, 3
    assert_equal @poll.votes_count, 0
    assert_equal @poll.voters_count, 0 
    assert_equal @answer1.votes_count, 0
    assert_equal @answer2.votes_count, 0
    assert_equal @answer3.votes_count, 0

    assert_no_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => [@answer1.id, 'invalid']
    end

    assert_no_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => [@answer1.id, @answer2.id, @answer3.id]
    end

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @user.id, :answer_ids => [@answer1.id, @answer2.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 2
    assert_equal @poll.voters_count, 1 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 1
    assert_equal @answer3.votes_count, 0

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @friend.id, :answer_ids => [@answer2.id, @answer3.id, @answer3.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 4
    assert_equal @poll.voters_count, 2 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 2
    assert_equal @answer3.votes_count, 1

    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @stranger.id, :answer_ids => [@answer3.id, @answer3.id, @answer3.id]
    end
    @poll.reload and @answer1.reload and @answer2.reload and @answer3.reload
    assert_equal @poll.votes_count, 5
    assert_equal @poll.voters_count, 3 
    assert_equal @answer1.votes_count, 1
    assert_equal @answer2.votes_count, 2
    assert_equal @answer3.votes_count, 2
  end

  #
  # case5
  # create poll without answers
  #
  test "case5" do
    assert_no_difference "Poll.count" do
      @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 1, :name => 'name', :answers => nil
    end    
  end

  #
  # case6
  # user's polls list and participated polls list
  #
  test "case6" do
    @poll1 = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 1, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}], :max_multiple => 2
    sleep 1
    @poll2 = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 1, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}], :max_multiple => 2
    sleep 1
    @poll3 = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 1, :no_deadline => 1, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}], :max_multiple => 2

    @user.reload
    assert_equal @user.polls, [@poll3, @poll2, @poll1]

    @poll1.votes.create :voter_id => @user.id, :answer_ids => [@poll1.answers.first.id]
    @poll2.votes.create :voter_id => @user.id, :answer_ids => [@poll2.answers.first.id]
    @user.reload
    assert_equal @user.participated_polls, []
    assert_equal @user.participated_polls_count, 0

    @poll1.votes.create :voter_id => @friend.id, :answer_ids => [@poll1.answers.first.id]
    @poll2.votes.create :voter_id => @friend.id, :answer_ids => [@poll2.answers.first.id]
    @friend.reload
    assert_equal @friend.participated_polls, [@poll2, @poll1]
    assert_equal @friend.participated_polls_count, 2

    @poll1.unverify
    @user.reload and @friend.reload
    assert_equal @user.participated_polls_count, 0
    assert_equal @friend.participated_polls_count, 1

    @poll1.verify
    @user.reload and @friend.reload
    assert_equal @user.participated_polls_count, 0
    assert_equal @friend.participated_polls_count, 2
  end

  #
  # case7
  # poll feed and vote feed
  #
  test "case7" do
    @guild1 = GuildFactory.create :character_id => @character1.id
    @guild2 = GuildFactory.create :character_id => @character2.id
    @guild2.member_memberships.create :user_id => @user.id, :character_id => @character1.id

    @user.is_idol = true
    @user.save
    @fan = UserFactory.create
    Fanship.create :fan_id => @fan.id, :idol_id => @user.id

    @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 2, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}], :max_multiple => 2
 
    assert @friend.recv_feed?(@poll)
    assert @game.recv_feed?(@poll)
    assert @user.profile.recv_feed?(@poll)
    assert @guild1.recv_feed?(@poll)
    assert @guild2.recv_feed?(@poll)
    assert @fan.recv_feed?(@poll)

    @vote = @poll.votes.create :voter_id => @user.id, :answer_ids => [@poll.answers.first.id]

    @friend.reload and @game.reload and @user.reload and @guild1.reload and @guild2.reload and @fan.reload   
    assert @friend.recv_feed?(@vote)
    assert @game.recv_feed?(@vote)
    assert @user.profile.recv_feed?(@vote)
    assert @guild1.recv_feed?(@vote)
    assert @guild2.recv_feed?(@vote)
    assert @fan.recv_feed?(@vote)

    @poll.unverify

    @friend.reload and @game.reload and @user.reload and @guild1.reload and @guild2.reload and @fan.reload
    assert !@friend.recv_feed?(@poll)
    assert !@game.recv_feed?(@poll)
    assert !@user.profile.recv_feed?(@poll)
    assert !@guild1.recv_feed?(@poll)
    assert !@guild2.recv_feed?(@poll)
    assert !@fan.recv_feed?(@poll)
    assert @friend.recv_feed?(@vote)
    assert @game.recv_feed?(@vote)
    assert @user.profile.recv_feed?(@vote)
    assert @guild1.recv_feed?(@vote)
    assert @guild2.recv_feed?(@vote)
    assert @fan.recv_feed?(@vote)  

    @poll.verify

    @friend.reload and @game.reload and @user.reload and @guild1.reload and @guild2.reload and @fan.reload
    assert @friend.recv_feed?(@poll)
    assert @game.recv_feed?(@poll)
    assert @user.profile.recv_feed?(@poll)
    assert @guild1.recv_feed?(@poll)
    assert @guild2.recv_feed?(@poll)
    assert @fan.recv_feed?(@poll)
    assert @friend.recv_feed?(@vote)
    assert @game.recv_feed?(@vote)
    assert @user.profile.recv_feed?(@vote)
    assert @guild1.recv_feed?(@vote)
    assert @guild2.recv_feed?(@vote)
    assert @fan.recv_feed?(@vote)
  end

  #
  # case8
  # comment poll
  #
  test "case8" do
    @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 2, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}], :max_multiple => 2

    assert @poll.is_commentable_by?(@user)
    assert @poll.is_commentable_by?(@friend)
    assert @poll.is_commentable_by?(@stranger)
  end

  #
  # case9
  # dig poll
  #
  test "case9" do
    @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 2, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}, {:description => "answer3"}], :max_multiple => 2

    assert @poll.is_diggable_by?(@user)
    assert @poll.is_diggable_by?(@friend)
    assert @poll.is_diggable_by?(@stranger)
  end

  #
  # case10
  # add answers
  #
  test "case10" do
    @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 2, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}], :max_multiple => 2

    @poll.update_attributes(:answers => [{:description => 'answer3'}, {:description => 'answer4'}])
    @poll.reload
    assert_equal @poll.answers_count, 4
  end

  #
  # case11
  # sensitive poll
  #
  test "case11" do
    @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 2, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}], :max_multiple => 2
    
    assert_difference "Vote.count" do
      @poll.votes.create :voter_id => @friend.id, :answer_ids => [@poll.answers.first.id]
    end

    @poll.reload and @user.reload and @friend.reload
    assert @poll.accepted?
    assert_equal @user.polls_count, 1
    assert_equal @friend.participated_polls_count, 1

    @poll.unverify
    @poll.reload and @user.reload and @friend.reload
    assert @poll.rejected?
    assert_equal @user.polls_count, 0
    assert_equal @friend.participated_polls_count, 0

    @poll.verify
    @poll.reload and @user.reload and @friend.reload
    assert @poll.accepted?
    assert_equal @user.polls_count, 1
    assert_equal @friend.participated_polls_count, 1

    @poll.update_attributes(:description => @sensitive)
    assert @poll.unverified?

    @poll.update_attributes(:answers => [{:description => @sensitive}])
    @poll.reload
    assert @poll.unverified?

    @poll.unverify
    @poll.destroy
    @user.reload and @friend.reload
    assert_equal @user.polls_count, 0
    assert_equal @friend.participated_polls_count, 0
  end

  #
  # case12
  # invite some friends
  #
  test "case12" do
    @poll = Poll.create :poster_id => @user.id, :game_id => @game.id, :privilege => 2, :no_deadline => 0, :deadline => 1.day.from_now, :name => 'name', :answers => [{:description => "answer1"}, {:description => "answer2"}], :max_multiple => 2

    assert_difference "PollInvitation.count" do
      @poll.update_attributes(:invitees => [@friend.id])
    end

    @friend.reload
    assert_equal @friend.poll_invitations_count, 1

    assert_no_difference "PollInvitation.count" do
      @poll.update_attributes(:invitees => [@friend.id])
    end

    assert_no_difference "PollInvitation.count" do
      @poll.update_attributes(:invitees => ['invalid', @stranger.id])
    end
  end

end
