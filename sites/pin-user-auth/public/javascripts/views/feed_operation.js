//发送feed
pie.load(function(){
  jQuery('.feed-form .ipter .feed-content').val('');

  jQuery('.feed-form .subm .subbtn').live('click',function(){
    var inputer_elm = jQuery('.feed-form .ipter .feed-content');
    var content = inputer_elm.val();

    var channel_id = jQuery('.feed-form .ipter .channel-id').val();

    var data;
    if(channel_id){
      data = 'content='+encodeURIComponent(content)+'&channel_id='+channel_id;
    }else{
      data = 'content='+encodeURIComponent(content);
    }

    pie.log(content)
    if(jQuery.string(content).blank()){
      pie.inputflash(inputer_elm);
      return;
    }

    jQuery.ajax({
      url  : pie.pin_url_for('pin-user-auth','/newsfeed/do_say'),
      type : 'post',
      data : data,
      success : function(res){
        //创建成功
        inputer_elm.val('');
        var dom_elm = jQuery(res);
        var lis = dom_elm.find('li');
        jQuery('#mplist_feeds').prepend(lis);
        lis.hide().slideDown(400);
      }
    });
  });
})

pie.load(function(){
  //标记
  jQuery('.newsfeed .feed .ops .fav').live('click',function(){
    var elm = jQuery(this);
    var f_elm = elm.closest('.f');
    var id = f_elm.attr('data-id');

    var is_on = elm.hasClass('on');

    if(is_on){
      pie.show_loading_bar();
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id+'/unfav'),
        type :'delete',
        success : function(res){
          elm.removeClass('on').addClass('off');
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      });
    }else{
      pie.show_loading_bar();
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id+'/fav'),
        type :'post',
        success : function(res){
          elm.removeClass('off').addClass('on');
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      });
    }
  });
});

pie.load(function(){
  //传播
  var ftelm = jQuery('<div class="feed-transmit-form popdiv">'+
    '<div class="title">传播一个话题</div>'+
    '<div class="flash-success"><span>发送成功</span></div>'+
    '<div class="ori-feed"></div>'+
    '<div class="ipt"><textarea class="transmit-inputer"></textarea></div>'+
    '<div class="btns">'+
      '<a class="button editable-submit" href="javascript:;">发送</a>'+
      '<a class="button editable-cancel" href="javascript:;">取消</a>'+
    '</div>'+
  '</div>');
  
  jQuery('.newsfeed .feed .ops .transmit').live('click',function(){
    var elm = jQuery(this);
    var off = elm.offset();
    var fct = elm.closest('.feed').find('.ct').html();
    var feed_id = elm.closest('.f').attr('data-id');

    if(feed_id == ftelm.attr('data-feed-id')){
      ftelm.remove();
      ftelm.attr('data-feed-id','');
      ftelm.find('textarea').val('');
      ftelm.find('.ori-feed').html('');
    }else{
      ftelm.css('left',off.left - 200).css('top',off.top + elm.outerHeight() + 2);
      ftelm.attr('data-feed-id',feed_id);
      ftelm.find('.ori-feed').html(fct);
      ftelm.find('.flash-success').hide();
      jQuery('body').append(ftelm);
    }
  });

  //取消按钮
  jQuery('.feed-transmit-form .editable-cancel').live('click',function(){
    ftelm.remove();
    ftelm.attr('data-feed-id','');
    ftelm.find('textarea').val('');
  });

  //确定按钮
  jQuery('.feed-transmit-form a.button.editable-submit').live('click',function(){
    var quote_of_id = ftelm.attr('data-feed-id');
    var content = ftelm.find('textarea').val();

    pie.show_loading_bar();
    jQuery.ajax({
      url  : '/feeds/quote',
      type : 'POST',
      data : 'quote_of='+quote_of_id+
             '&content=' + encodeURIComponent(content),
      success : function(res){
        ftelm.find('.flash-success').fadeIn(200);
        setTimeout(function(){
          ftelm.remove();
          ftelm.attr('data-feed-id','');
          ftelm.find('textarea').val('');
        },400)
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    });
  });


  //删除feed
  jQuery('.newsfeed .feed .ops .del').live('click',function(){
    var elm = jQuery(this);
    var f_elm = elm.closest('.feed.mpli').find('.f');
    var id = f_elm.attr('data-id');
    

    var li_elm = f_elm.closest('li');

    elm.confirm_dialog('确定要删除这个话题吗',function(){
      li_elm.slideUp({
        complete : function(){
          li_elm.remove();
        }
      })

      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id),
        type :'delete',
        success : function(res){

        },
        error : function(data){
        }
      });
    })
  });

})


pie.load(function(){
  //显示较长观点的全文
  jQuery('.short-content a.show-detail').live('click',function(){
    var elm = jQuery(this);
    var short_elm = elm.closest('.short-content');
    var detail_elm = short_elm.next('.detail-content');
    short_elm.hide();
    detail_elm.fadeIn('fast');
  })
})

pie.load(function(){
  //confirm对话框，取代系统默认
  jQuery.fn.confirm_dialog = function(str,func){
    var elm = jQuery(this);
    var off = elm.offset();

    func == func || function(){};

    var dialog_elm = jQuery(
      '<div class="jq-confirm-dialog popdiv">'+
        '<div class="d">'+
          '<div class="data"><div class="icon">?</div>'+str+'</div>'+
          '<div class="btns">'+
            '<a class="button editable-submit" href="javascript:;">确定</a>'+
            '<a class="button editable-cancel" href="javascript:;">取消</a>'+
          '</div>'+
        '</div>'+
      '</div>'
    );

    jQuery('.jq-confirm-dialog').remove();
    dialog_elm.css('left',off.left - 100 + elm.outerWidth()/2).css('top',off.top - 83);
    jQuery('body').append(dialog_elm);

    //IE下面这样写有问题，估计是append之后不能立即fadeIn
    dialog_elm.hide().fadeIn();
    
    jQuery('.jq-confirm-dialog .editable-submit').unbind();
    jQuery('.jq-confirm-dialog .editable-submit').bind('click',function(){
      jQuery('.jq-confirm-dialog').remove();
      func();
    });
  }
  
  jQuery('.jq-confirm-dialog .editable-cancel').live('click',function(){
    jQuery('.jq-confirm-dialog').remove();
  })
});