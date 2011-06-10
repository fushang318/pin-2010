// 发表观点
pie.load(function(){
  
  jQuery('.page-show-add-viewpoint .subm .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var psav_elm = elm.closest('.page-show-add-viewpoint');
    var feed_id = psav_elm.attr('data-feed-id');
    var content = psav_elm.find('.add-viewpoint-inputer .inputer').val();

    //   post /feeds/:id/viewpoint params[:content]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/viewpoint',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var vp_elm = jQuery(res);
        jQuery('.page-feed-viewpoints').append(vp_elm);
        vp_elm.hide().fadeIn('fast');
        jQuery('.page-show-add-viewpoint').addClass('vp-added');
      }
    })
  });
  
});

//针对观点的评论
pie.load(function(){
  
  var comment_form_str =
    '<div class="comment-form">'+
      '<div class="ipt"><textarea class="inputer"/></div>'+
      '<div class="btns">'+
        '<a class="button editable-submit" href="javascript:;">发送</a>'+
        '<a class="button editable-cancel" href="javascript:;">取消</a>'+
      '</div>'+
    '</div>';
    
  var prefix = '.page-feed-viewpoints .viewpoint ';

  // 针对观点的评论
  jQuery(prefix + '.add-comment a').live('click',function(){
    var add_comment_elm = jQuery(this).closest('.add-comment');
    var vp_elm = add_comment_elm.closest('.viewpoint');

    if(vp_elm.find('.comment-form').length == 0){
      add_comment_elm.after(comment_form_str);
      add_comment_elm.hide();
    }
  });

  //取消
  jQuery(prefix + '.comment-form .btns .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var form_elm = vp_elm.find('.comment-form');
    var add_comment_elm = vp_elm.find('.add-comment');

    form_elm.remove();
    add_comment_elm.show();
  })

  // 确定，提交
  jQuery(prefix + '.comment-form .btns .editable-submit').live('click',function(){
    //post /viewpoints/:id/comments params[:content]
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var viewpoint_id = vp_elm.attr('data-id');

    var form_elm = vp_elm.find('.comment-form');
    var content = form_elm.find('.ipt .inputer').val();

    var add_comment_elm = vp_elm.find('.add-comment');

    jQuery.ajax({
      url : '/viewpoints/'+viewpoint_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_comments_elm = jQuery(res);

        var old_comments_elm = vp_elm.find('.comments');

        if(old_comments_elm.length == 0){
          //原来没有评论
          old_comments_elm.remove();
          add_comment_elm.before(new_comments_elm);
          new_comments_elm.hide().fadeIn(200);
        }else{
          //原来已经有评论
          var c_elm = new_comments_elm.find('.comment');
          old_comments_elm.append(c_elm);
          c_elm.hide().fadeIn(200);
        }

        form_elm.remove();
        add_comment_elm.show();
      }
    })
  });

  //删除观点的评论
  jQuery(prefix + '.comments .comment .delete').live('click',function(){
    var elm = jQuery(this);
    var comments_elm = elm.closest('.comments');
    var comment_elm = elm.closest('.comment');
    var comment_id = comment_elm.attr('data-id');

    elm.confirm_dialog('确定要删除这条评论吗',function(){
      // delete /viewpoint_comments/:id
      jQuery.ajax({
        url : '/viewpoint_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut(200,function(){
            comment_elm.remove();
            if(comments_elm.find('.comment').length == 0){
              comments_elm.remove();
            }
          });
        }
      })
    });
  });

  //回复其他人的评论
  jQuery(prefix + '.comments .comment .reply').live('click',function(){
    var elm = jQuery(this);
    var user_name = elm.closest('.comment').attr('data-creator-name');
    var vp_elm = elm.closest('.viewpoint');
    var addc_elm = vp_elm.find('.add-comment');

    if(vp_elm.find('.comment-form').length == 0){
      addc_elm.after(comment_form_str);
      addc_elm.hide();
    }

    vp_elm.find('.comment-form .inputer').val('回复@'+user_name+':').focus();
  })

});


//修改观点
pie.load(function(){
  
  var form_elm = jQuery(
    '<div class="viewpoint-edit-form">'+
      '<div class="btns">'+
        '<a class="button editable-submit" href="javascript:;">发送</a>'+
        '<a class="button editable-cancel" href="javascript:;">取消</a>'+
      '</div>'+
    '</div>'
  )
  
  //修改观点
  jQuery('.page-feed-viewpoints .viewpoint .edit-vp .edit').live('click',function(){
    var ori_form_elm = jQuery('.page-show-add-viewpoint .point-form .add-viewpoint-inputer');
    form_elm.find('.btns').before(ori_form_elm);

    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');
    var vote_elm = vp_elm.find('.vote-ops');
    var footmisc_elm = vp_elm.find('.footmisc');

    main_elm.hide();
    vote_elm.hide();
    footmisc_elm.hide();
    main_elm.after(form_elm);
    form_elm.show();
  });

  //确定
  jQuery('.page-feed-viewpoints .viewpoint .viewpoint-edit-form .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    var content = form_elm.find('.inputer').val();

    //   post /feeds/:id/viewpoint params[:content]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/viewpoint',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_vp_elm = jQuery(res);
        vp_elm.after(new_vp_elm);
        vp_elm.remove();

        pie.highlight(new_vp_elm);
      }
    })
  });


  //取消
  jQuery('.page-feed-viewpoints .viewpoint .viewpoint-edit-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');
    var vote_elm = vp_elm.find('.vote-ops');
    var footmisc_elm = vp_elm.find('.footmisc');

    main_elm.show();
    vote_elm.show();
    footmisc_elm.show();
    form_elm.remove();
  });

});


//修改主题正文
pie.load(function(){
  
  jQuery('.page-feed-show .detail-data .edit-detail .edit').live('click',function(){
    var form_elm = jQuery('.feed-detail-edit-form')
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');

    form_elm.show();
    detail_elm.hide();
  });

  //确定
  jQuery('.page-feed-show .feed-detail-edit-form .editable-submit').live('click',function(){
    var form_elm = jQuery('.feed-detail-edit-form')
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');
    var feed_id = feed_elm.attr('data-id');
    var content = form_elm.find('.detail-inputer').val();

    //  put /feeds/:id/update_detail params[:detail]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/update_detail',
      type : 'put',
      data : 'detail='+encodeURIComponent(content),
      success : function(res){
        var new_feed_elm = jQuery(res);
        feed_elm.after(new_feed_elm);
        feed_elm.remove();
        form_elm.hide();
      }
    })
  });


  //取消
  jQuery('.page-feed-show .feed-detail-edit-form .editable-cancel').live('click',function(){
    var form_elm = jQuery('.feed-detail-edit-form')
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');
    detail_elm.show();
    form_elm.hide();
  });

});


//修改主题页的标题
pie.load(function(){
  
  jQuery('.feed-show-page-head .ftitle .edit-feed-title .edit').live('click',function(){
    var form_elm = jQuery('.feed-title-edit-form')
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');
    var content_elm = head_elm.find('.ftitle .feed-title');

    form_elm.show();
    content_elm.hide();
  });

  //取消
  jQuery('.feed-show-page-head .ftitle .feed-title-edit-form .editable-cancel').live('click',function(){
    var form_elm = jQuery('.feed-title-edit-form')
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');
    var content_elm = head_elm.find('.ftitle .feed-title');

    form_elm.hide();
    content_elm.show();
  });

  //确定
  jQuery('.feed-show-page-head .ftitle .feed-title-edit-form .editable-submit').live('click',function(){
    var form_elm = jQuery('.feed-title-edit-form')
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    var content = form_elm.find('.content-inputer').val();

    //  put /feeds/:id/update_content params[:detail]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/update_content',
      type : 'put',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_ftitle_elm = jQuery(res).find('.ftitle');
        var old_ftitle_elm = head_elm.find('.ftitle');
        old_ftitle_elm.after(new_ftitle_elm);
        old_ftitle_elm.remove();
      }
    })
  });
  
});


//修改主题页的tag
pie.load(function(){
  
  jQuery('.feed-show-page-head .ftag .edit-tags .edit').live('click',function(){
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var form_elm = head_elm.find('.feed-tags-edit-form')
    var tags_elm = head_elm.find('.feed-tags');

    form_elm.show();
    tags_elm.hide();
  });

  //确定
  jQuery('.feed-show-page-head .ftag .feed-tags-edit-form .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var form_elm = head_elm.find('.feed-tags-edit-form')

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    var tag_names = form_elm.find('.tags-inputer').val();

    //  post /feeds/:id/add_tags        params[:tag_names]

    jQuery.ajax({
      url : '/feeds/'+feed_id+'/change_tags',
      type : 'put',
      data : 'tag_names='+encodeURIComponent(tag_names),
      success : function(res){
        var new_ftag_elm = jQuery(res).find('.ftag');
        var old_ftag_elm = head_elm.find('.ftag');
        old_ftag_elm.after(new_ftag_elm);
        old_ftag_elm.remove();
      }
    })
  });

  //取消
  jQuery('.feed-show-page-head .ftag .feed-tags-edit-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var form_elm = head_elm.find('.feed-tags-edit-form')
    var tags_elm = head_elm.find('.feed-tags');

    form_elm.hide();
    tags_elm.show();
  });
  
})


//show页面的关注
pie.load(function(){

  jQuery('.show-page-ops .fav').live('click',function(){
    var fav_elm = jQuery('.show-page-ops .fav');
    var unfav_elm = jQuery('.show-page-ops .unfav');
    var feed_id = jQuery('.page-feed-show').attr('data-id');

    jQuery.ajax({
      url  :pie.pin_url_for('pin-user-auth','/feeds/'+feed_id+'/fav'),
      type :'post',
      success : function(res){
        fav_elm.hide();
        unfav_elm.show();
      }
    });
  });

  jQuery('.show-page-ops .unfav').live('click',function(){
    var fav_elm = jQuery('.show-page-ops .fav');
    var unfav_elm = jQuery('.show-page-ops .unfav');
    var feed_id = jQuery('.page-feed-show').attr('data-id');

    jQuery.ajax({
      url  :pie.pin_url_for('pin-user-auth','/feeds/'+feed_id+'/unfav'),
      type :'delete',
      success : function(res){
        fav_elm.show();
        unfav_elm.hide();
      }
    });
  });
  
});


//针对主题的评论
pie.load(function(){
  
  var comment_form_str =
    '<div class="comment-form">'+
      '<div class="ipt"><textarea class="inputer"/></div>'+
      '<div class="btns">'+
        '<a class="button editable-submit" href="javascript:;">发送</a>'+
        '<a class="button editable-cancel" href="javascript:;">取消</a>'+
      '</div>'+
    '</div>';

  jQuery('.page-feed-show .add-comment a').live('click',function(){
    var add_comment_elm = jQuery(this).closest('.add-comment');
    var feed_elm = add_comment_elm.closest('.page-feed-show');

    if(feed_elm.find('.comment-form').length == 0){
      add_comment_elm.after(comment_form_str);
      add_comment_elm.hide();
    }
  });

  //取消
  jQuery('.page-feed-show .comment-form .btns .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var form_elm = feed_elm.find('.comment-form');
    var add_comment_elm = feed_elm.find('.add-comment');

    form_elm.remove();
    add_comment_elm.show();
  })

  // 确定，提交
  jQuery('.page-feed-show .comment-form .btns .editable-submit').live('click',function(){
    //post /viewpoints/:id/comments params[:content]
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var feed_id = feed_elm.attr('data-id');

    var form_elm = feed_elm.find('.comment-form');
    var content = form_elm.find('.ipt .inputer').val();

    var add_comment_elm = feed_elm.find('.add-comment');

    jQuery.ajax({
      url  : '/feeds/reply_to',
      type : 'post',
      data : 'reply_to='+feed_id
              + '&content=' + encodeURIComponent(content),
      success : function(res){
        var new_comments_elm = jQuery(res);

        var old_comments_elm = feed_elm.find('.comments');

        if(old_comments_elm.length == 0){
          //原来没有评论
          old_comments_elm.remove();
          add_comment_elm.before(new_comments_elm);
          new_comments_elm.hide().fadeIn(200);
        }else{
          //原来已经有评论
          var c_elm = new_comments_elm.find('.comment');
          old_comments_elm.append(c_elm);
          c_elm.hide().fadeIn(200);
        }

        form_elm.remove();
        add_comment_elm.show();
      }
    })
  });

  //删除观点的评论
  jQuery('.page-feed-show .comments .comment .delete').live('click',function(){
    var elm = jQuery(this);
    var comments_elm = elm.closest('.comments');
    var comment_elm = elm.closest('.comment');
    var comment_id = comment_elm.attr('data-id');

    elm.confirm_dialog('确定要删除这条评论吗',function(){
      // delete /viewpoint_comments/:id
      jQuery.ajax({
        url : '/feed_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut(200,function(){
            comment_elm.remove();
            if(comments_elm.find('.comment').length == 0){
              comments_elm.remove();
            }
          });
        }
      })
    });
  });

  //回复其他人的评论
  jQuery('.page-feed-show .comments .comment .reply').live('click',function(){
    var elm = jQuery(this);
    var user_name = elm.closest('.comment').attr('data-creator-name');
    var feed_elm = elm.closest('.page-feed-show');
    var addc_elm = feed_elm.find('.add-comment');

    if(feed_elm.find('.comment-form').length == 0){
      addc_elm.after(comment_form_str);
      addc_elm.hide();
    }

    feed_elm.find('.comment-form .inputer').val('回复@'+user_name+':').focus();
  })

});

pie.load(function(){
  // 不值得讨论
  jQuery('.page-feed-show .ops .spam').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var feed_id = feed_elm.attr('data-id');
    elm.confirm_dialog('如果很多人都这么觉得，主题将被隐藏。',function(){
      // post /feeds/id/add_spam_mark
      jQuery.ajax({
        url : '/feeds/'+feed_id+'/add_spam_mark',
        type : 'post',
        success : function(res){
          var new_feed_elm = jQuery(res);
          feed_elm.after(new_feed_elm);
          feed_elm.remove();
          jQuery('.tipsy').remove();
          //重新加载tipr 在有更好的方法之前 此处暂时先这样写，
          new_feed_elm.find('[tipr]').tipsy({html:true,gravity:'w',title:function(){
            var tip = this.getAttribute('tipr')
            var doms = jQuery(tip)
            if(doms.length == 0) return tip;
            return doms.html();
          }});
        }
      })
    })
  })
})

pie.load(function(){
  // 投赞成
  jQuery('.page-feed-viewpoints .viewpoint .vote-up').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var vp_id = vp_elm.attr('data-id');

    // POST /viewpoints/:id/vote_up
    jQuery.ajax({
      url : '/viewpoints/'+vp_id+'/vote_up',
      type : 'post',
      success : function(res){
        resort_viewpoints(res,vp_id);
      }
    })
  });

  // 投反对
  jQuery('.page-feed-viewpoints .viewpoint .vote-down').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var vp_id = vp_elm.attr('data-id');

    // POST /viewpoints/:id/vote_up
    jQuery.ajax({
      url : '/viewpoints/'+vp_id+'/vote_down',
      type : 'post',
      success : function(res){
        resort_viewpoints(res,vp_id);
      }
    })
  });

  //取消投票
  jQuery('.page-feed-viewpoints .viewpoint .voted-up, .page-feed-viewpoints .viewpoint .voted-down')
  .live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var vp_id = vp_elm.attr('data-id');
    //delete /viewpints/:id/cancel_vote
    jQuery.ajax({
      url : '/viewpoints/'+vp_id+'/cancel_vote',
      type : 'delete',
      success : function(res){
        resort_viewpoints(res,vp_id);
      }
    })
  })

  //重新加载观点dom
  function resort_viewpoints(res,vp_id){
    var new_elm = jQuery('<div>'+res+'</div>');
    var new_vps_elm = new_elm.find('.page-feed-viewpoints');
    var old_vps_elm = jQuery('.page-feed-viewpoints');
    old_vps_elm.before(new_vps_elm).remove();
    jQuery('.page-feed-viewpoints .viewpoint[data-id='+vp_id+']').hide().fadeIn();
    jQuery('.tipsy').remove();

    //重新加载tipr 在有更好的方法之前 此处暂时先这样写，
    jQuery('.page-feed-viewpoints [tipr]').tipsy({html:true,gravity:'w',title:function(){
      var tip = this.getAttribute('tipr')
      var doms = jQuery(tip)
      if(doms.length == 0) return tip;
      return doms.html();
    }});
  }
});

pie.load(function(){
  //删除被邀请者
  jQuery('.show-page-be-invited-users .user .delete').live('click',function(){
    var elm = jQuery(this);
    var user_elm = elm.closest('.user');
    var user_id = user_elm.attr('data-id');
    var feed_id = jQuery('.page-feed-show').attr('data-id');
    // delete /feeds/:id/cancel_invite params[:user_id]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/cancel_invite',
      type : 'delete',
      data : 'user_id='+user_id,
      success : function(){
        user_elm.fadeOut(200,function(){user_elm.remove()});
      }
    })
  })
})

//邮件邀请
pie.load(function(){
  jQuery('.show-page-invite-email .send-invite-email').live('click',function(){
    var form_elm = jQuery('.show-page-feed-share-form');

    jQuery.facebox(
      '<h3 class="f_box">发送主题讨论邀请邮件</h3>'+
      '<div class="show-page-feed-share-form">'+
        '<div class="flash-success" style="display:none;"><span>邮件发送完毕</span></div>'+
        form_elm.html()+
      '</div>'
    )
  })

  jQuery('.show-page-feed-share-form .editable-cancel').live('click',function(){
    jQuery.facebox.close();
  })

  //发送邮件
  jQuery('.show-page-feed-share-form .editable-submit').live('click',function(){
//    post /feeds/id/send_invite_email
//      params[:email]
//      params[:title]
//      params[:postscript]
    var elm = jQuery(this);
    var form_elm = elm.closest('.show-page-feed-share-form');
    var email = form_elm.find('input.email').val();
    var title = form_elm.find('input.title').val();
    var postscript = form_elm.find('textarea.postscript').val();

    if(jQuery.string(email).blank()){
      pie.inputflash(form_elm.find('input.email'));
      return;
    }

    if(jQuery.string(title).blank()){
      pie.inputflash(form_elm.find('input.title'));
      return;
    }

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/send_invite_email',
      type : 'post',
      data : 'email='+encodeURIComponent(email)+
        '&title='+encodeURIComponent(title)+
        '&postscript='+encodeURIComponent(postscript),
      success : function(){
        form_elm.find('.flash-success').fadeIn(100);
        setTimeout(function(){jQuery.facebox.close();},500);
      }
    })

  })
})

//转发链接
pie.load(function(){
  jQuery('.show-page-invite-link-share .send-invite-link-share').live('click',function(){
    var form_elm = jQuery('.show-page-feed-link-share-form');

    jQuery.facebox(
      '<h3 class="f_box">转发主题链接地址</h3>'+
      '<div class="show-page-feed-link-share-form">'+
        form_elm.html()+
      '</div>'
    )

    var cnt_elm = jQuery('#facebox textarea');
    var start = 0;
    var end = cnt_elm.val().length;
    cnt_elm[0].setSelectionRange(start,end);
  })

  jQuery('.show-page-feed-link-share-form .editable-cancel').live('click',function(){
    jQuery.facebox.close();
  })
});

pie.feed_image_resize = function(elm){
  var width = elm.width();
  var height = elm.height();

  if(width<=600) return;

  // w/600 = h/x
  // x = 600h/w

  var new_height = 600 * height / width;
  elm.attr('width',600).attr('height',new_height)
}

// 管理员锁定主题
pie.load(function(){
  jQuery('.feed-show-page-head .show-page-lock a.admin-lock').live('click',function(){
    var feed_id = jQuery('.page-feed-show').attr('data-id');

    // put /feeds/id/lock
    jQuery.ajax({
      url : "/feeds/"+feed_id+'/lock',
      type : 'PUT',
      success : function(){
        location.reload(true);
      }
    });
  })

  jQuery('.feed-show-page-head .show-page-lock a.unlock').live('click',function(){
    var feed_id = jQuery('.page-feed-show').attr('data-id');

    // put /feeds/id/lock
    jQuery.ajax({
      url : "/feeds/"+feed_id+'/unlock',
      type : 'PUT',
      success : function(){
        location.reload(true);
      }
    });
  })
})