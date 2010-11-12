if(typeof(Mindpin)=='undefined'){
  Mindpin = {}
}
Mindpin.MindpinSidebar = {
  init: function(){
    // 处理 statusbar 状态
    getSidebarWindow().addEventListener("unload", function(e) {
      Mindpin.MindpinSidebar.unload_side_bar();
    }, false);
    Mindpin.MindpinSidebar.load_side_bar();
    // 显示上次用户选择的页签
    getSidebarWindow().$('#mindpin_tab_list').attr("selectedIndex",Mindpin.MindpinSidebar.get_select_tab())
    Mindpin.MindpinSidebar.loading_ui();
    Mindpin.MindpinSidebar.show();
    // 给 websitecomments browser 注册 时间
    getSidebarWindow().$("#web_site_comments")[0].addProgressListener(Mindpin.MindpinSidebar.WebSiteCommentsListener);
    // 给 browse_histroies browser 注册 时间
    getSidebarWindow().$("#side_browse_histories")[0].addProgressListener(Mindpin.MindpinSidebar.BrowseHistoriesInfosListener);
  },

  load_side_bar: function(){
    Mindpin.FireFoxWindow.$("#status-bar-img").attr("class","open_status");
  },
  unload_side_bar:function(){
    Mindpin.FireFoxWindow.$("#status-bar-img").attr("class","close_status");
//    Mindpin.CollectorClip.cancel_clip();
    Mindpin.CollectorClip.cancel_all_tab_browser_clip();
  },
  register: function(){
    var gbrowser = getFireFoxWindow().gBrowser;
    var tab = gbrowser.addTab(Mindpin.REGISTER_URL);
    gbrowser.selectedTab = tab;
  },
  login: function(){
    var login_success = function(){}
    Mindpin.LoginManager.promptUserLogin(login_success)
  },
  logout: function(){
    Mindpin.LoginManager.logout();
  },
  is_open: function(){
    var bar = Mindpin.FireFoxWindow.$('#sidebar-box');
    var is_mbar = (bar.attr('sidebarcommand') == "mindpin_siderbar")
    return (bar && !bar.hidden && is_mbar)
  },
  // 正在载入界面
  loading_ui: function(){
    getSidebarWindow().$("#login_action").attr("hidden",true);
    getSidebarWindow().$("#unlogin_action").attr("hidden",true);
    
    // 隐藏 tabbox
    getSidebarWindow().$('#mindpin_tab_list').attr("hidden",true);
    // 显示提示内容
    getSidebarWindow().$("#mindpin_tab_tip_label").attr("value","正在载入..");
    getSidebarWindow().$("#mindpin_tab_tip_label").attr("hidden",false);
    getSidebarWindow().$("#mindpin_tab_loading").attr("hidden",false);
    getSidebarWindow().$("#mindpin_tab_tip_box").attr("hidden",false);
    
    getSidebarWindow().$("#web_site_info")[0].contentWindow.document.body.innerHTML = "正在载入.."
    getSidebarWindow().$("#web_site_comments")[0].contentWindow.document.body.innerHTML = "正在载入.."
    getSidebarWindow().$("#side_browse_histories")[0].contentWindow.document.body.innerHTML = "正在载入.."
    getSidebarWindow().$("#current_page_info_box").attr("value","正在载入..")
    
  },
  // 没有登录界面
  unlogin_ui: function(){
    getSidebarWindow().$("#login_action").attr("hidden",true);
    getSidebarWindow().$("#unlogin_action").attr("hidden",false);
    
    // 隐藏 tabbox
    getSidebarWindow().$('#mindpin_tab_list').attr("hidden",true);
    // 显示提示内容
    getSidebarWindow().$("#mindpin_tab_tip_label").attr("value","请先登录");
    getSidebarWindow().$("#mindpin_tab_tip_label").attr("hidden",false);
    getSidebarWindow().$("#mindpin_tab_loading").attr("hidden",true);
    getSidebarWindow().$("#mindpin_tab_tip_box").attr("hidden",false);
  },
  // 已登录界面
  logined_ui: function(user){
    getSidebarWindow().$("#lbl_user_name").attr("value",user.name); 
    getSidebarWindow().$("#lbl_user_avatar").attr("src",user.avatar);
    getSidebarWindow().$("#login_action").attr("hidden",false);
    getSidebarWindow().$("#unlogin_action").attr("hidden",true);
    
    Mindpin.MindpinSidebar.show_web_site_info();
    Mindpin.MindpinSidebar.show_web_site_comments();
    Mindpin.MindpinSidebar.show_browse_histories();
    setTimeout(Mindpin.MindpinSidebar.show_current_page_content,0)

    getSidebarWindow().$('#mindpin_tab_list').attr("hidden",false);
    getSidebarWindow().$('#mindpin_tab_tip_box').attr("hidden",true);  
  },
  
  // 不支持网页页面
  nonsupport_ui: function(){
    var window = getSidebarWindow();
    window.$("#login_action").xhide();
    window.$("#unlogin_action").xhide();
    
    // 隐藏 tabbox
    window.$('#mindpin_tab_list').xhide();
    // 显示提示内容
    window.$("#mindpin_tab_tip_label").attr("value","插件不支持这个网页。");
    window.$("#mindpin_tab_tip_label").xshow();
    window.$("#mindpin_tab_loading").xhide();
    window.$("#mindpin_tab_tip_box").xshow();
  },

  is_nonsupport_url: function(url){
    return url == "about:blank" || (/^chrome:/.test(url))
  },
  show_web_site_info: function(){
    var current_url = getWebWindow().location;
    var src = Mindpin.WEB_SITE_INFOS_URL + "?url=" + encodeURIComponent(current_url)
    var wsibro = getSidebarWindow().$("#web_site_info")[0]
    wsibro.src = src
    wsibro.loadURI(src)
  },
  show_web_site_comments: function(){
    var current_url = getWebWindow().location;
    var src = Mindpin.WEB_SITE_COMMENTS_URL + "?url=" + encodeURIComponent(current_url)
    var wsibro = getSidebarWindow().$("#web_site_comments")[0]
    wsibro.src = src
    wsibro.loadURI(src)
  },
  show_browse_histories: function(){
    var current_url = getWebWindow().location;
    var src = Mindpin.BROWSE_HISTORIES_URL;
    var wsibro = getSidebarWindow().$("#side_browse_histories")[0];
    wsibro.src = src;
    wsibro.loadURI(src);
  },
  asyn_post_browse_history: function(){
    // 如果是本地地址，提前返回
    var current_url = getWebWindow().location;
    if(Mindpin.MindpinSidebar.is_nonsupport_url(current_url)){
      return;
    }
    
    var user = Mindpin.LoginManager.get_logined_user();
    if(user){
      var current_tab = getWebWindow();
      var url = current_tab.location.href;
      var title = current_tab.document.title;
      var content = current_tab.document.body.innerHTML;
      var success = function(){};

      $.ajax({
        url: Mindpin.SUBMIT_BROWSE_HISTORIES_URL, 
        type: "post",
        async: true,
        data: {
          'url':url,
          'content':content,
          'title':title
        },
        dataType: "text",
        success: success
      });
    }
  },
  // 解析页面信息
  show_current_page_content: function(){
    var sidebar = getSidebarWindow();
    if(getWebWindow().document.readyState == "loading"){
      sidebar.$("#parse_page_info_loading").attr("hidden","false")
      sidebar.$("#parse_page_info").attr("hidden","true")
    }else{
      sidebar.$("#parse_page_info_loading").attr("hidden","false")
      sidebar.$("#parse_page_info").attr("hidden","true")

      Mindpin.PageParse.init();

      sidebar.$("#parse_page_info_loading").attr("hidden","true")
      sidebar.$("#parse_page_info").attr("hidden","false")
    }

  },
  // 设置选中的页签 index
  select_tab: function(index){
    Mindpin.Preferences.set_int("select_tab",index);
  },
  // 读取选中的页签 index
  get_select_tab: function(){
    return Mindpin.Preferences.get_int("select_tab",0);
  },
  // 根据是否支持页面以及是否登录，渲染侧边栏界面
  show: function(){
    // 首先检测地址栏地址，是否支持，不支持的则直接给出提示
    var current_url = getWebWindow().location;
    if(Mindpin.MindpinSidebar.is_nonsupport_url(current_url)){
      return Mindpin.MindpinSidebar.nonsupport_ui();
    }
    // 检测是否登录
    var user = Mindpin.LoginManager.get_logined_user();
    if(user){
      Mindpin.MindpinSidebar.logined_ui(user);
    }else{
      Mindpin.MindpinSidebar.unlogin_ui();
    }
  },

  check_open_and_show:function(){
    if(this.is_open()){
      this.loading_ui();
      this.show();
    }
  }
};

Mindpin.MindpinSidebar.WebSiteCommentsLoad = function(){
  var wsw = getSidebarWindow().$("#web_site_comments")[0].contentWindow;
  $(".share_comment",wsw.document).live("click",function(){
    Mindpin.CollectionTextWindow.share_comments_ui($(this));
  });
  $(".send_comment",wsw.document).live("click",function(){
    Mindpin.CollectionTextWindow.send_comments_ui($(this));
  });
};

Mindpin.MindpinSidebar.WebSiteCommentsListener = {
  QueryInterface: function(aIID) {  
    if (aIID.equals(Components.interfaces.nsIWebProgressListener) ||  
      aIID.equals(Components.interfaces.nsISupportsWeakReference) ||
      aIID.equals(Components.interfaces.nsISupports))
      return this;  
    throw Components.results.NS_NOINTERFACE;  
  },
  onLocationChange: function(aProgress, aRequest, aURI){
    aProgress.DOMWindow.document.addEventListener("DOMContentLoaded",Mindpin.MindpinSidebar.WebSiteCommentsLoad,false);
  },
  onStateChange: function(aWebProgress, aRequest, aFlag, aStatus){},
  onProgressChange: function(aWebProgress, aRequest, curSelf, maxSelf, curTot, maxTot) {},  
  onStatusChange: function(aWebProgress, aRequest, aStatus, aMessage) {},  
  onSecurityChange: function(aWebProgress, aRequest, aState) {}
};

Mindpin.MindpinSidebar.BrowseHistoriesInfosLoad = function(){
  var wbhw = getSidebarWindow().$("#side_browse_histories")[0].contentWindow;
  $(".share_url",wbhw.document).live("click",function(){
    Mindpin.CollectionTextWindow.share_url_ui($(this));
  });
  $(".send_url",wbhw.document).live("click",function(){
    Mindpin.CollectionTextWindow.send_url_ui($(this));
  });
};

Mindpin.MindpinSidebar.BrowseHistoriesInfosListener = {
  QueryInterface: function(aIID) {
    if (aIID.equals(Components.interfaces.nsIWebProgressListener) ||  
      aIID.equals(Components.interfaces.nsISupportsWeakReference) ||
      aIID.equals(Components.interfaces.nsISupports))
      return this;  
    throw Components.results.NS_NOINTERFACE;  
  },
  onLocationChange: function(aProgress, aRequest, aURI){
    aProgress.DOMWindow.document.addEventListener("DOMContentLoaded",Mindpin.MindpinSidebar.BrowseHistoriesInfosLoad,false);
  },
  onStateChange: function(aWebProgress, aRequest, aFlag, aStatus){},
  onProgressChange: function(aWebProgress, aRequest, curSelf, maxSelf, curTot, maxTot) {},  
  onStatusChange: function(aWebProgress, aRequest, aStatus, aMessage) {},  
  onSecurityChange: function(aWebProgress, aRequest, aState) {}
};
