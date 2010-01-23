Iyxzone.Guild = {
  version: '1.0',
  author: ['高侠鸿'],
  Builder: {},
  Feeder: {},
  Editor: {}
};

Object.extend(Iyxzone.Guild.Builder, {

  validate: function(){
    if($('guild_name').value == ''){
      error('名字不能为空');
      return false;
    }
    if($('guild_game_id') && $('guild_game_id').value == ''){
      error('游戏类别不能为空');
      return false;
    }
    if($('guild_name').value.length >= 100){
      error('名字最长100个字符');
      return false;
    }
    if($('guild_description').value.length >= 1000){
      error('描述最多1000个字符');
      return false;
    }
    return true;
  },

  save: function(event){
    Event.stop(event);
    if(this.validate()){
      var form = $('guild_form');
      form.action = '/guilds';
      form.method = 'post';
      form.submit();
    }
  },

  update: function(guildID, event){
    Event.stop(event);
    if(this.validate()){
      var form = $('guild_form');
      form.action = '/guilds/' + guildID;
      form.method = 'put';
      form.submit();
    }
  }

});

Object.extend(Iyxzone.Guild.Feeder, {
  
  idx: 0,

  moreFeeds: function(guildID){
    // show loading page
    $('more_feed').innerHTML = '<img src="/images/loading.gif" />';

    // send ajax request
    new Ajax.Request('/guilds/' + guildID + '/more_feeds?idx=' + this.idx, {
      method: 'get',
      onSuccess: function(){
        this.idx++;
      }
    });
  }

});

Object.extend(Iyxzone.Guild.Editor, {

  attendanceRulesHTML: null,

  editAttendanceRulesHTML: null,

  loading: function(div){
    $(div).innerHTML = '<img src="/images/loading.gif"/>';
  },

  editAttendanceRules: function(guildID){
    this.attendanceRulesHTML = $('attendance_rule_frame').innerHTML;
    this.loading('attendance_rule_frame');
    if(this.editAttendanceRulesHTML){
      $('attendance_rule_frame').innerHTML = this.editAttendanceRulesHTML;
    }else{
      new Ajax.Request('/guilds/' + guildID + '/rules?type=0', {
        method: 'get',
        onSuccess: function(transport){
          $('attendance_rule_frame').innerHTML = transport.responseText;
        }.bind(this)
      });
    }
  },

  updateAttendanceRules: function(guildID){
    new Ajax.Request('/guilds/' + guildID + '/rules/create_or_update?type=0', {
      method: 'post',
      parameters: $('attendance_rules_form').serialize(),
      onSuccess: function(transport){
        $('attendance_rule_frame').innerHTML = transport.responseText;
        this.attendanceRulesHTML = null;
        this.editAttendanceRulesHTML = null;
      }.bind(this)
    });
  },

  cancelEditAttendanceRules: function(guildID){
    this.editAttendanceRulesHTML = $('attendance_rule_frame').innerHTML;
    $('attendance_rule_frame').innerHTML = this.attendanceRulesHTML;
  },
  
  basicRulesHTML: null,

  editBasicRulesHTML: null,
 
  basicRulesCount: 0,

  editBasicRules: function(guildID){
    this.basicRulesHTML = $('basic_rule_frame').innerHTML;
    this.loading('basic_rule_frame');
    if(this.editBasicRulesHTML){
      $('basic_rule_frame').innerHTML = this.editBasicRulesHTML;
    }else{
      new Ajax.Request('/guilds/' + guildID + '/rules?type=1', {
        method: 'get',
        onSuccess: function(transport){
          $('basic_rule_frame').innerHTML = transport.responseText;
        }.bind(this)
      });
    }
  },

  newBasicRule: function(){
    var div = new Element('div');
    var html = "<div><label>原因: </label></div>";
    html += "<div><input type='text' name='guild[new_rules][new_" + this.basicRulesCount + "][reason]' /></div>";
    html += "<div><label>赏罚：</label></div>";
    html += "<div><input type='text' name='guild[new_rules][new_" + this.basicRulesCount + "][outcome]' /></div>";
    html += "<a onclick='Iyxzone.Guild.Editor.removeNewBasicRule(this)' href=# >x</a>";
    div.innerHTML = html;
    Element.insert($('basic_rules'), {bottom: div});
    this.basicRulesCount++;  
  },

  updateBasicRules: function(guildID){
    new Ajax.Request('/guilds/' + guildID + '/rules/create_or_update?type=1', {
      method: 'post',
      parameters: $('basic_rules_form').serialize(),
      onSuccess: function(transport){
        $('basic_rule_frame').innerHTML = transport.responseText;
        this.basicRulesHTML = null;
        this.editBasicRulesHTML = null;
      }.bind(this)
    });
  },

  cancelEditBasicRules: function(guildID){
    this.editBasicRulesHTML = $('basic_rule_frame').innerHTML;
    $('basic_rule_frame').innerHTML = this.basicRulesHTML;
  },

  removeBasicRule: function(ruleID, guildID, token){
    new Ajax.Request('/guilds/' + guildID + '/rules/' + ruleID, {
      method: 'delete',
      parameters: 'authenticity_token=' + encodeURIComponent(token)
    });
  },

  removeNewBasicRule: function(div){
    div.up().remove();
  },

  bossesHTML: null,

  editBossesHTML: null,

  bossesCount: 0,

  editBosses: function(guildID){
    this.bossesHTML = $('boss_frame').innerHTML;
    this.loading('boss_frame');
    if(this.editBossesHTML){
      $('boss_frame').innerHTML = this.editBossesHTML;
    }else{
      new Ajax.Request('/guilds/' + guildID + '/bosses', {
        method: 'get',
        onSuccess: function(transport){
          $('boss_frame').innerHTML = transport.responseText;
        }.bind(this)
      });
    }
  },

  newBoss: function(){
    var div = new Element('div');
    var html = "<div><label>名称: </label></div>";
    html += "<div><input type='text' name='guild[new_bosses][new_" + this.bossesCount + "][name]' /></div>";
    html += "<div><label>奖励: </label></div>";
    html += "<div><input type='text' name='guild[new_bosses][new_" + this.bossesCount + "][reward]' /></div>";
    html += "<a onclick='Iyxzone.Guild.Editor.removeNewBoss(this)' href=# >x</a>";
    div.innerHTML = html;
    Element.insert($('guild_bosses'), {bottom: div});
    this.bossesCount++; 
  },

  updateBosses: function(guildID){
    new Ajax.Request('/guilds/' + guildID + '/bosses/create_or_update', {
      method: 'post',
      parameters: $('bosses_form').serialize(),
      onSuccess: function(transport){
        $('boss_frame').innerHTML = transport.responseText;
        this.bossesHTML = null;
        this.editBossesHTML = null;
      }.bind(this)
    });
  },

  cancelEditBosses: function(guildID){
    this.editBossesHTML = $('boss_frame').innerHTML;
    $('boss_frame').innerHTML = this.bossesHTML;
  },

  removeBoss: function(bossID, guildID, token){
    new Ajax.Request('/guilds/' + guildID + '/bosses/' + bossID, {
      method: 'delete',
      parameters: 'authenticity_token=' + encodeURIComponent(token)
    });
  },

  removeNewBoss: function(div){
    div.up().remove();
  },

  gearsHTML: null,

  editGearsHTML: null,

  gearsCount: 0,

  editGears: function(guildID){
    this.gearsHTML = $('gear_frame').innerHTML;
    this.loading('gear_frame');
    if(this.editGearsHTML){
      $('gear_frame').innerHTML = this.editGearsHTML;
    }else{
      new Ajax.Request('/guilds/' + guildID + '/gears', {
        method: 'get',
        onSuccess: function(transport){
          $('gear_frame').innerHTML = transport.responseText;
        }.bind(this)
      });
    }
  },

  newGear: function(){
    var div = new Element('div');
    var html = "<div><label>名称: </label></div>";
    html += "<div><input type='text' name='guild[new_gears][new_" + this.gearsCount + "][name]' /></div>";
    html += "<div><label>奖励: </label></div>";
    html += "<div><input type='text' name='guild[new_gears][new_" + this.gearsCount + "][cost]' /></div>";
    html += "<a onclick='Iyxzone.Guild.Editor.removeNewGear(this)' href=# >x</a>";
    div.innerHTML = html;
    Element.insert($('guild_gears'), {bottom: div});
    this.gearsCount++;
  },

  updateGears: function(guildID){
    new Ajax.Request('/guilds/' + guildID + '/gears/create_or_update', {
      method: 'post',
      parameters: $('gears_form').serialize(),
      onSuccess: function(transport){
        $('gear_frame').innerHTML = transport.responseText;
        this.gearsHTML = null;
        this.editGearsHTML = null;
      }.bind(this)
    });
  },

  cancelEditGears: function(guildID){
    this.editGearsHTML = $('gear_frame').innerHTML;
    $('gear_frame').innerHTML = this.gearsHTML;
  },

  removeGear: function(gearID, guildID, token){
    new Ajax.Request('/guilds/' + guildID + '/gears/' + gearID, {
      method: 'delete',
      parameters: 'authenticity_token=' + encodeURIComponent(token)
    });
  },

  removeNewGear: function(div){
    div.up().remove();
  }


});
