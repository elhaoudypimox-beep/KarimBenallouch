/* Barrages – Android download bridge (additive; does not change app logic).
   WebView cannot save <a download> links (data:/blob:). On native Android we
   write the file with @capacitor/filesystem and open the share sheet. */
(function(){
  var C=window.Capacitor;
  if(!C||!C.isNativePlatform||!C.isNativePlatform())return;
  function P(n){return C.Plugins&&C.Plugins[n]}
  function toB64(blob){return new Promise(function(res,rej){var r=new FileReader;r.onload=function(){res(String(r.result).split(',')[1]||'')};r.onerror=rej;r.readAsDataURL(blob)})}
  async function save(href,name){
    try{
      var FS=P('Filesystem'),SH=P('Share');
      var blob=await (await fetch(href)).blob();
      var data=await toB64(blob);
      name=(name||'fichier').replace(/[\\/:*?"<>|]/g,'_');
      var w=await FS.writeFile({path:name,data:data,directory:'CACHE'});
      await SH.share({title:name,url:w.uri,dialogTitle:name});
    }catch(e){if(e&&/cancel/i.test(String(e.message||e)))return;alert('Téléchargement impossible : '+(e&&e.message||e))}
  }
  var origClick=HTMLAnchorElement.prototype.click;
  HTMLAnchorElement.prototype.click=function(){
    if(this.hasAttribute('download')&&this.href){save(this.href,this.getAttribute('download'));return}
    return origClick.apply(this,arguments)
  };
  document.addEventListener('click',function(e){
    var a=e.target&&e.target.closest&&e.target.closest('a[download]');
    if(a&&a.href){e.preventDefault();e.stopPropagation();save(a.href,a.getAttribute('download'))}
  },true);
})();
