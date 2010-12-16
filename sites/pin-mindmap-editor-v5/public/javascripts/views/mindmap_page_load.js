pie.MindmapUser = Class.create({
  initialize:function(user_name,mindmap_id){
    this.user_name = user_name;
    this.mindmap_id = mindmap_id;
  },
  say:function(text){
    try{
      var json = Object.toJSON({
        'username':this.user_name,
        'text':text
      });
      var pars = 'channel='+'mindmap_'+this.mindmap_id;
      new Ajax.Request("/mindmaps/push?"+pars,{
        method:'POST',
        postBody:json,
        onSuccess:function(trans){
          //
        }
      });
    }catch(ex){
      console.log(ex);
    }
  }
});

pie.MindmapPageLoader = {
  load_editor_page:function(mindmap_id){
    $("mindmap-canvas").update('');

    window.mindmap = new pie.mindmap.BasicMapPaper("mindmap-canvas",{
      id:mindmap_id,
      loader: new pie.mindmap.JSONLoader({
        url:'/mindmaps/' + mindmap_id
      }),
      editmode: true,
      after_load:function(){
        mindmap.root.select();
      },
      save_status_label:$("save_status")
    }).load();

    this.mindmap_resize();
    Event.observe(window,"resize",this.mindmap_resize);
    //this.show_comments(mindmap_id);

    //new TimeKeeper("/mindmaps/ajax_test");
    this.pull(mindmap_id);
  },
  mindmap_resize:function(){
    var height = document.viewport.getHeight() - 40 - 38;
    var width = $('mindmap-toolbar').getWidth() - 210;
    $('mindmap-main').setStyle({
      'height':height + 'px'
    });
    $('mindmap-resizer').setStyle({
      'height':height + 'px',
      'width':width + 'px'
    });
  },
  show_comments:function(mindmap_id){
    new Ajax.Updater("comments-list","/mindmaps/"+mindmap_id+"/comments",{
      method:'GET',
      onCreate:function(){
        $("comments-list").update('<div class="loading"></div>');
      }
    });
  },
  pull:function(mindmap_id){
    var pars = 'channel='+'mindmap_'+mindmap_id;
    new Ajax.Request("/mindmaps/pull?"+pars,{
      parameters:pars,
      method:'GET',
      onSuccess:function(trans){
        var json = trans.responseText.evalJSON();
        this.add_chat(json);
        this.pull(mindmap_id);
      }.bind(this)
    });
  },
  add_chat:function(chat_json){
    var username = chat_json.username;
    var text = chat_json.text;
    var cl = $$('.chat-list')[0];
    var node = Builder.node('div',{'class':'chat-line'},[
      Builder.node('span',{'class':'username'},username+': '),
      Builder.node('span',{},text)
    ]);
    cl.appendChild(node);
  }
}

TimeKeeper = Class.create({
  initialize : function(url){
    this.url = url;
    this.frequence = 0;
    this.ave_time = 0;
    this.total_time = 0;
    this.request_per_half_minute();
  },
  request_per_half_minute : function(){
    new PeriodicalExecuter(function() {
      var begin_time = new Date();
      new Ajax.Request(this.url,{
        method: 'get',
        onSuccess:function(response){
          var respond_time = (new Date()-begin_time);
          this.total_time = this.total_time + respond_time;
          this.frequence = this.frequence + 1;
          this.ave_time = this.total_time/this.frequence;
          $$("#net_condition .last_respond span.time")[0].update(respond_time)
          $$("#net_condition .average_respond span.time")[0].update(Math.round(this.ave_time))
        }.bind(this)
      })
    }.bind(this), 30);
  }
});


