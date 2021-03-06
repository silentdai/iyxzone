class VideoFactory

  def self.create cond={}
    # create poster
    poster = Factory.create :user

    # create character
    game        = Factory.create :game
    area        = Factory.create :game_area, :game_id => game.id
    server      = Factory.create :game_server, :game_id => game.id, :area_id => area.id
    profession  = Factory.create :game_profession, :game_id => game.id
    race        = Factory.create :game_race, :game_id => game.id
    character   = Factory.create :game_character, {
      :user_id        => poster.id,
      :game_id        => game.id,
      :server_id      => server.id,
      :area_id        => area.id,
      :profession_id  => profession.id,
      :race_id        => race.id
    }

    # create blog
    Factory.create :video, {:video_url => 'http://v.youku.com/v_show/id_XMTY3NDE5Nzg4.html', :poster_id => poster.id, :game_id => character.game_id}.merge(cond)
  end

end
