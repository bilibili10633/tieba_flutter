import 'dart:core';

final Uri getRecommendThreadUrl = Uri(
    scheme: "https",
    host: "tieba.baidu.com",
    path: "mg/o/getRecommPage",
    queryParameters: {"load_type": "1", "page_thread_count": "50"});
//"https://tieba.baidu.com/mg/p/getPbData?kz=8244921446&rn=20&pn=1&only_post=1";

Uri getThreadDetailUri(String tid, String pageNum) {
  return Uri(
      scheme: "http",
      host: "tieba.baidu.com",
      path: "mg/p/getPbData",
      queryParameters: {
        "kz": tid,
        "rn": "20",
        "pn": pageNum,
        "only_post": "2"
      });
}

Uri getFavoriteForumUri(String pageNum) =>
    Uri.parse("http://tieba.baidu.com/f/like/mylike?pn=$pageNum");

const String appSecret =
    "tiebaclient!!!";
//app密钥，在MD5签名时作为盐加入。或者不加盐直接加在请求体后面，签名得出的效果是一样的



const String tiebaWatchPostUrl =
    "http://c.tieba.baidu.com:80/c/f/frs/page";
//进入某个吧后看帖的地址，请求方法是POST，请求体格式为URL-Encoded，需要BDUSS（可选），kw（吧名）和sign（MD5加盐加密）参数
const String tiebaUserInfoUrl =
    "https://tieba.baidu.com/f/user/json_userinfo";
//带着Cookie访问，如果已经登陆则返回用户信息
const String getBaiduRSAPubKeyUrl =
    "https://passport.baidu.com/v2/getpublickey?token=%s&tpl=tb&apiver=v3&tt=%s&gid=&loginversion=v4&traceid=";
const String tiebaUrl = "https://tieba.baidu.com/";

const String userAvatarPrefix =
    "https://gss0.baidu.com/7Ls0a8Sm2Q5IlBGlnYG/sys/portraith/item/";
//头像前缀，后面接上portrait可以获取到用户头像

const String tiebaAuthURL =
    "http://passport.baidu.com/v3/login/api/auth/?tpl=tb&jump=&return_type=3&u=https%3A%2F%2Ftieba.baidu.com%2Findex.html";
//重要，需要cookie携带PTOKEN和BDUSS访问获取STOKEN
const String tiebaRecommendForum =
    "http://c.tieba.baidu.com:80/c/f/forum/forumrecommend";
//获取关注的吧接口（app接口），请求方法：POST，返回：JSON

Uri getFloorInFloorUri(String tid,String pid)=>Uri(
  scheme: 'http',
  host: 'tieba.baidu.com',
  path: '/mg/o/getFloorData',
  queryParameters: {
    //?pn=1&rn=20&tid=8293253725&pid=147014789199
    'pn':'1',
    'rn':'20',
    'tid':tid,
    'pid':pid
  }
);//楼中楼



//帖子信息
const String postThreadDetail="http://c.tieba.baidu.com/c/f/pb/page";
//回复我的
const String getTiebaMessagesUri="http://c.tieba.baidu.com/c/u/feed/replyme";
//@我的
const String getTiebaAtMeUri="http://c.tieba.baidu.com/c/u/feed/atme";
//点赞
const String getTiebaAgreeMeUri="http://c.tieba.baidu.com/c/u/feed/agreeme";

//发帖url.发帖时需要获取tbs
const String tiebaNewPostUrl="http://tieba.baidu.com/f/commit/post/add";
//获取tbs，一些操作会用到，具体用途未知
const String tiebaGetTbs="http://tieba.baidu.com/dc/common/tbs";
//上传图片url，返回的地址在发帖时用
const String tiebaUploadUrl="https://uploadphotos.baidu.com/upload/pic?tbs=77d596470c5f2e2a016811285040125500_1&save_yun_album=1&picWaterType=1039999";
//图片tag，帖子附带的图片
const String tiebaPostImageTag="[img pic_type=0 width=*width* height=*height*]*url*[/img]";
//贴吧表情前缀
const String tiebaEmojiPrefix="http://static.tieba.baidu.com/tb/editor/images/client/";