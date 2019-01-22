Win10.onReady(()=> {

    //设置壁纸
    Win10.setBgUrl({
        main: 'tools/img/wallpapers/main.jpg',
        mobile: 'tools/img/wallpapers/mobile.jpg',
    });

    Win10.setAnimated([
        'animated flip',
        'animated bounceIn',
    ], 0.01);


//    // if(location.search.includes("startup=myblog")){
//        //默认打开博客
//        setTimeout(()=> {
//            Win10.openUrl('https://blog.zhouzhipeng.com','周志鹏博客')
//        }, 1000);
//    // }

    //获取桌面快捷方式 数据列表
    $.get("https://api.zhouzhipeng.com/desktop/shortcut-list",(shortcuts)=>{
        console.log(shortcuts)



        let fullHtml="";
        for(let shortcut of shortcuts){
            let areaAttr='';
            if(shortcut.area_offset){
                areaAttr=`data-area-offset="${shortcut.area_offset.replace(/"/g,"'")}"`;
            }

            fullHtml+=`
              <div class="shortcut win10-open-window" data-url="${shortcut.url}" ${areaAttr}>
                    <img class="icon" src="${shortcut.icon}"/>
                    <div class="title">${shortcut.title}</div>
                </div>
            `;
        }

        $("#win10-shortcuts").html(fullHtml);

        Win10.renderShortcuts();
    });





});
