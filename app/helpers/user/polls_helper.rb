module User::PollsHelper

  def max_multiple_select_tag
    options = []
    10.times do |i|
      options << ["#{i+1}项", i+1]
    end
    select_tag 'poll[max_multiple]', options_for_select(options, 1)
  end

  def generate_percentage_bar(answer, poll)
    answer_votes = answer.votes_count
    poll_votes = poll.votes_count == 0 ? 1 : poll.votes_count
    "<script language='javascript'>Iyxzone.Poll.drawPercentBar(200, #{100*answer_votes/poll_votes}, '#{cycle 'blue', 'green', 'purple', 'red', 'gold', 'black'}', #{answer.votes_count}); </script>"
  end

  def votable? poll, user
    user == poll.poster || poll.privilege == 1 || (poll.privilege == 2 and poll.poster.friends.include? user)
  end

end
