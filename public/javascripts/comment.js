/**
 * TODO:
 * 点击document.body时候，能够触发hideForm事件
 */

Iyxzone.Comment = {
  version: '1.1',
  author: ['高侠鸿'],
  changeLog: '修正了wall message的一个bug'
};

Object.extend(Iyxzone.Comment, {

  pluralize: function(str){
    if(str == 'status')
      return 'statuses';
    else
      return str + 's';
  },

  validate: function(content){
    if(content.value.length == 0){
      error('评论不能为空');
      return false;
    }
    if(content.value.length > 140){
      error('评论最多140个字节');
      return false;
    }
    return true;
  },

  showForm: function(commentableType, commentableID, login, recipientID){
    $('add_' + commentableType + '_comment_' + commentableID).hide();
    $(commentableType + '_comment_' + commentableID).show();
    $(commentableType + '_comment_recipient_' + commentableID).value = recipientID;
    $(commentableType + '_comment_content_' + commentableID).focus();
    if(login == null)
      $(commentableType + '_comment_content_' + commentableID).value = "";
    else
      $(commentableType + '_comment_content_' + commentableID).value = "回复" + login + "：";
  },

  hideForm: function(commentableType, commentableID, event){
    Event.stop(event);
    $(commentableType + '_comment_' + commentableID).hide();
    $('add_' + commentableType + '_comment_' + commentableID).show();
  },

  save: function(commentableType, commentableID, button, event){
    Event.stop(event);
    if(Iyxzone.Comment.validate($(commentableType + '_comment_content_' + commentableID))){
      new Ajax.Request('/comments', { 
        method: 'post',
        parameters: $(commentableType+'_comment_form_' + commentableID).serialize(),
        onLoading: function(){
          Iyxzone.disableButton(button, '请等待..');
        },
        onComplete: function(){
          Iyxzone.enableButton(button, '发布');
          $(commentableType + '_comment_' + commentableID).hide();
          $('add_' + commentableType + '_comment_' + commentableID).show();
        }
      });
    }
  },

  set: function(commentableType, commentableID, login, commentorID){
    this.showForm(commentableType, commentableID, login, commentorID);
    
    Element.scrollTo(commentableType + '_comment_form_' + commentableID);
  },

  more: function(commentableType, commentableID, link){
    link.innerHTML = '<img src="/images/loading.gif" />';
    new Ajax.Request('/comments?commentable_id=' + commentableID + '&commentable_type=' + commentableType, {
      method: 'get',
      onSuccess: function(transport){
//        $(commentableType + '_comments_' + commentableID).innerHTML = transport.responseText;
        $(commentableType + '_comments_' + commentableID).update( transport.responseText);
      }
    });
  },

  toggleBox: function(commentableType, commentableID, commentsCount){
    var box = $(commentableType + '_comment_box_' + commentableID);
    var link = $(commentableType + '_comment_link_' + commentableID);
    if(!box.visible()){
      Effect.BlindDown(box);
      if(link)
        link.update('收起回复')
    }else{
      Effect.BlindUp(box);
      if(link)
        link.update(commentsCount + '条回复')
    }
  }

});

Iyxzone.WallMessage = Class.create({});

Object.extend(Iyxzone.WallMessage, {

  recipientID: null, // initialize this in your page

  validate: function(content){
    if(content.value.length == 0){
      error('留言不能为空');
      return false;
    }
    if(content.value.length > 140){
      error('留言最多140个字节');
      return false;
    }
    return true; 
  },

  save: function(wallType, wallID, button, form){
		if(this.validate($('comment_content'))){
			new Ajax.Request('/wall_messages', {
        method: 'post',
        onLoading: function(){
          Iyxzone.disableButton(button, '请等待..');
        }.bind(this),
        onComplete: function(){
          Iyxzone.enableButton(button, '发布');
          $('comment_recipient_id').value = this.recipientID;
          $('comment_content').focus();
        }.bind(this),
				parameters: $(form).serialize()
      });
		} 
  },

  fetch: function(wallType, wallID){
    new Ajax.Request('/wall_messages?wall_type=' + wallType + '&wall_id=' + wallID, {
      method: 'get',
      onLoading: function(){
        $('comments').innerHTML = '<img src="images/loading.gif" />';
      },
      onSuccess: function(transport){
//        $('comments').innerHTML = transport.responseText;
        $('comments').update( transport.responseText);
      }
    });
  },

  set: function(login, id){
    $('comment_recipient_id').value = id;
    $('comment_content').focus();
    $('comment_content').value = '回复' + login + '：';
  }

});
