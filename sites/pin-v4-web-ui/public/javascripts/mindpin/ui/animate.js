pie.inputflash = function(input_dom){
  var elm = jQuery(input_dom)
  var current = elm.attr('data-current-bg-color');
  if(!current){
    current =  elm.css('background-color');
    elm.attr('data-current-bg-color',current);
  }
  
  elm
    .animate({'backgroundColor': '#FFB49C'}, 200)
    .animate({'backgroundColor': current}, 200)
    .animate({'backgroundColor': '#FFB49C'}, 200)
    .animate({'backgroundColor': current}, {
      duration:200,
      complete:function(){
        elm.css('backgroundColor',current);
      }
    });
}

pie.load(function(){
  var ani = function(elm){
    elm.css('backgroundColor','#292929')
      .animate({'backgroundColor': '#E9B51C'}, 1000)
      .animate({'backgroundColor': '#292929'}, {
        duration:1000,
        complete:function(){
          ani(elm);
        }
      });
  }

  var ani1 = function(elm){
    elm
      .animate({'opacity': 0.6}, 500)
      .animate({'opacity': 1}, {
        duration:500,
        complete:function(){
          ani1(elm);
        }
      });
  }

  if(pie.env == 'development'){
    jQuery('.devdraft').each(function(){
      var elm = jQuery(this);
      ani(elm);
    })
    
    jQuery('[dev-note]').each(function(){
      var elm = jQuery(this);
      var felm = jQuery('<div class="dev-note-float"></div>');
      var o = elm.offset();
      felm.css('left',o.left).css('top',o.top);
      jQuery('body').append(felm);

      felm.tipsy({html:true,title:function(){
        var tip = elm.attr('dev-note')
        var doms = jQuery(tip)
        if(doms.length == 0) return tip;
        return doms.html();
      }});

      felm.bind('dblclick',function(){
        jQuery(this).remove();
        jQuery('.tipsy').remove();
      })

      ani1(felm);
    });
  }
});