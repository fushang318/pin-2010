pie.load(function(){

  var statuses_elm = jQuery('.page-web-weibo-statuses');

  // 全局排列
  statuses_elm.isotope({
    itemSelector : '.gi',
    masonry : { columnWidth : 186 },
    transformsEnabled: false
  });

  var show_olist_overlay = function(){
    jQuery('<div class="page-web-weibo-overlay"></div>')
      .css('height', jQuery(window).height())
//      .css('opacity', 0.4)
//      .appendTo(document.body)
      .css('opacity', 0)
      .appendTo(document.body)
      .animate({'opacity': 0.5}, 600);
  };

  var remove_olist_overlay = function(){
    jQuery('.page-web-weibo-overlay').remove();
  };

  // 绑定鼠标移入移出事件
  var bind_hover_intent_event = function(elms){
    elms.hoverIntent({
      sensitivity: 10,
      interval: 250,
      over: function(){
        var elm = jQuery(this);
        var status_elm = elm.closest('.status');

        show_olist_overlay();
        //jQuery('.page-web-weibo-statuses .status').addClass('boxhoverhide');

        status_elm.removeClass('boxhoverhide').addClass('boxhover');
      },
      timeout: 0,
      out: function(){
        var elm = jQuery(this);
        var status_elm = elm.closest('.status');

        remove_olist_overlay();
        //jQuery('.page-web-weibo-statuses .status').removeClass('boxhoverhide');
        
        status_elm.removeClass('boxhover');
      }
    });
  }

  bind_hover_intent_event(statuses_elm.find('.status .box'));

  var _is_out_of_the_bottom = function(elm){
    var bottom = jQuery(window).height() + jQuery(window).scrollTop();
    var elm_top = elm.offset().top;
    
    return bottom <= elm_top;
  }

  var lazy_load_photos = function(){
    statuses_elm.find('.status .photo:not(.-img-loaded-)').each(function(){
      var elm = jQuery(this);
      if(!_is_out_of_the_bottom(elm)){
        pie.load_cut_img(elm.data('src'), elm, elm);
        elm.addClass('-img-loaded-')
      }
    });

    statuses_elm.find('.status .avatar:not(.-img-loaded-)').each(function(){
      var elm = jQuery(this);
      if(!_is_out_of_the_bottom(elm)){
        jQuery('<img/>').attr('src',elm.data('src')).hide().fadeIn(200).appendTo(elm);
        elm.addClass('-img-loaded-')
      }
    })
  }

  lazy_load_photos();
  jQuery(window).bind('scroll', lazy_load_photos);

  // 翻页组件
  var load_more_elm = jQuery('a.page-web-weibo-load-more');
  var load_more = function(){
    if(load_more_elm.hasClass('loading')) return;

    var max_id = jQuery('.page-web-weibo-statuses .status').last().data('mid') - 1;
    var load_url = jQuery(this).data('url');

    pie.dont_show_loading_bar(); // 防止显示全局ajaxloadingbar
    jQuery.ajax({
      url  : load_url,
      type : 'GET',
      data : { 'max_id' : max_id },
      beforeSend : function(){
        load_more_elm.addClass('loading').find('span').html('LOADING');
      },
      success : function(res){
        var new_elms = jQuery(res);
        jQuery('.page-web-weibo-statuses').append(new_elms).isotope('appended', new_elms);
        lazy_load_photos();
        bind_hover_intent_event(new_elms.find('.box'))
      },
      complete : function(){
        load_more_elm.removeClass('loading').find('span').html('LOAD MORE');
      }
    });
  }
  
  load_more();
  load_more_elm.live('click', load_more);

  var auto_load_more = function(){
    if(!_is_out_of_the_bottom(load_more_elm)){
      load_more();
    }
  }
  jQuery(window).bind('scroll', auto_load_more);
})

pie.load(function(){

  jQuery('.page-web-weibo-statuses .status .cart .add').live('click',function(){
    // /weibo/cart/add
    var elm      = jQuery(this);
    var status_elm = elm.closest('.status');
    var mid      = status_elm.data('mid');

    var offset = elm.offset();
    var l1= offset.left;
    var t1= offset.top - jQuery(window).scrollTop();

    var l2 = 56;
    var t2 = 237;

    //pie.log(l1,t1,l2,t2)
    var added_elm = status_elm.find('.cart .added')

    var ani_elm = jQuery('<div class="page-web-weibo-cart-add-ani">1</div>');
    ani_elm
      .css({left:l1, top:t1})
      .appendTo(added_elm)
      .animate({left:[l2,'easeInSine'], top:[t2,'easeInExpo'], 'opacity':0.3}, 1000, function(){
        var count_elm = jQuery('.page-web-weibo-toolbar .cart .count');
        count_elm.html(parseInt(count_elm.html())+1);
        setTimeout(function(){ani_elm.remove()},1000)
      })

   elm.hide();
   added_elm.show();


//    jQuery.ajax({
//      url  : '/weibo/cart/add',
//      data : {'mid':mid},
//      type : 'POST',
//      success : function(){
//        elm.hide();
//        feed_elm.find('.cart .added').show();
//      }
//    })
  });

})