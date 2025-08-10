import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fplayer/fplayer.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'app_bar.dart';

class VideoScreen extends StatefulWidget {
  final String url;

  const VideoScreen({super.key, required this.url});

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  final FPlayer player = FPlayer();

  // 视频列表
  List<VideoItem> videoList = [
    VideoItem(
      title: '第一集',
      subTitle: '视频1副标题',
      url: 'http://player.alicdn.com/video/aliyunmedia.mp4',
    ),
    VideoItem(
      title: '第二集',
      subTitle: '视频2副标题',
      url: 'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
    ),
    VideoItem(
      title: '第三集',
      subTitle: '视频3副标题',
      url: 'http://player.alicdn.com/video/aliyunmedia.mp4',
    ),
    VideoItem(
      title: '第四集',
      subTitle: '视频4副标题',
      url: 'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
    ),
    VideoItem(
      title: '第五集',
      subTitle: '视频5副标题',
      url: 'http://player.alicdn.com/video/aliyunmedia.mp4',
    ),
    VideoItem(
      title: '第六集',
      subTitle: '视频6副标题',
      url: 'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
    ),
    VideoItem(
      title: '第七集',
      subTitle: '视频7副标题',
      url: 'http://player.alicdn.com/video/aliyunmedia.mp4',
    )
  ];

  // 倍速列表
  Map<String, double> speedList = {
    "2.0": 2.0,
    "1.5": 1.5,
    "1.0": 1.0,
    "0.5": 0.5,
  };

  // 清晰度列表
  Map<String, ResolutionItem> resolutionList = {
    "480P": ResolutionItem(
      value: 480,
      url: 'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
    ),
    "270P": ResolutionItem(
      value: 270,
      url: 'http://player.alicdn.com/video/aliyunmedia.mp4',
    ),
  };

  // 视频索引,单个视频可不传
  int videoIndex = 0;

  // 模拟播放记录视频初始化完需要跳转的进度
  int seekTime = 100000;

  VideoScreenState();

  @override
  void initState() {
    super.initState();
    startPlay();
  }

  void startPlay() async {
    // 视频播放相关配置
    await player.setOption(FOption.hostCategory, "enable-snapshot", 1);
    await player.setOption(FOption.hostCategory, "request-screen-on", 1);
    await player.setOption(FOption.hostCategory, "request-audio-focus", 1);
    await player.setOption(FOption.playerCategory, "reconnect", 20);
    // 丢帧（解码速度慢时）
    await player.setOption(FOption.playerCategory, "framedrop", 30);
    await player.setOption(FOption.playerCategory, "enable-accurate-seek", 1);
    // await player.setOption(FOption.playerCategory, "mediacodec", 1);
    // 关闭缓冲
    await player.setOption(FOption.playerCategory, "soundtouch", 1);

    // 关闭 AVFormat 缓冲
    player.setOption(FOption.formatCategory, "fflags", "nobuffer");
    player.setOption(FOption.formatCategory, "flush_packets", 1);

    // 网络优化
    // 减小探测包大小，加快打开速度
    player.setOption(FOption.formatCategory, "probesize", 512);
    // 减小分析时长
    player.setOption(FOption.formatCategory, "analyzeduration", 100);


    //skip_loop_filter这个是解码的一个参数，叫环路滤波，设置成48和0，图像清晰度对比，0比48清楚，理解起来就是，0是开启了环路滤波，过滤的是大部分，而48基本没启用环路滤波，所以清晰度更低，但是解码性能开销小
    //skip_loop_filter（环路滤波）简言之：
    //a:环路滤波器可以保证不同水平的图像质量。
    //b:环路滤波器更能增加视频流的主客观质量，同时降低解码器的复杂度。
    player.setOption(FOption.codecCategory, "skip_loop_filter", 0);
    //视频帧率
    player.setOption(FOption.playerCategory, "fps", 30);
    //设置无packet缓存
    player.setOption(FOption.playerCategory, "packet-buffering", 0);
    //不限制拉流缓存大小
    player.setOption(FOption.playerCategory, "infbuf", 1);
    //设置最大缓存数量
    player.setOption(FOption.formatCategory, "max-buffer-size", 1024);
    //设置最小解码帧数
    player.setOption(FOption.playerCategory, "min-frames", 3);
    //启动预加载
    player.setOption(FOption.playerCategory, "start-on-prepared", 1);
    //设置分析流时长，即播放前的探测时间
    // player.setOption(FOption.formatCategory, "analyzeduration", "2000000");
    //开启硬解码，如果打开硬解码失败，再自动切换到软解码
    player.setOption(FOption.playerCategory, "mediacodec", 1);
    player.setOption(FOption.playerCategory, "mediacodec-auto-rotate", 1);
    player.setOption(FOption.playerCategory, "mediacodec-handle-resolution-change", 1);

    //player.setOption(FOption.playerCategory, "overlay-format", FOption.SDL_FCC_YV12);
    //如果是rtsp协议，可以优先用tcp(默认是用udp)
    player.setOption(FOption.formatCategory, "rtsp_transport", "tcp");


    // 最大缓冲cache是3s， 有时候网络波动，会突然在短时间内收到好几秒的数据
    // 因此需要播放器丢包，才不会累积延时
    // 这个和第三个参数packet-buffering无关。
    player.setOption(FOption.playerCategory, "max_cached_duration", 300);

    // 设置在解析的 url 之前 （这里设置超时为5秒）
    // 如果没有设置stimeout，在解析时（也就是avformat_open_input）把网线拔掉，av_read_frame会阻塞（时间单位是微妙）
    player.setOption(FOption.formatCategory, "stimeout", "5000000");
    // 最大延迟 (ms)
    player.setOption(FOption.playerCategory, "max_delay", 100);

    // 直播特有优化
    // 用于 RTMP live 模式
    // player.setOption(FOption.formatCategory, "rtmp_live", 1);

    // 播放传入的视频
    setVideoUrl(widget.url);

    // 播放视频列表的第一个视频
    // setVideoUrl(videoList[videoIndex].url);
  }

  Future<void> setVideoUrl(String url) async {
    try {
      await player.setDataSource(url, autoPlay: true, showCover: true);
    } catch (error) {
      print("播放-异常: $error");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size size = mediaQueryData.size;
    double videoHeight = size.width * 9 / 16;
    return Scaffold(
      appBar: const FAppBar.defaultSetting(title: "Video"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FView(
              player: player,
              width: double.infinity,
              height: videoHeight,
              color: Colors.black,
              fsFit: FFit.contain, // 全屏模式下的填充
              fit: FFit.fill, // 正常模式下的填充
              panelBuilder: fPanelBuilder(
                // 单视频配置
                title: '视频标题',
                subTitle: '视频副标题',
                // 右下方截屏按钮
                isSnapShot: true,
                // 右上方按钮组开关
                isRightButton: true,
                // 右上方按钮组
                rightButtonList: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(5),
                        ),
                      ),
                      child: Icon(
                        Icons.thumb_up,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                ],
                // 字幕功能：待内核提供api
                // caption: true,
                // 视频列表开关
                isVideos: true,
                // 视频列表列表
                videoList: videoList,
                // 当前视频索引
                videoIndex: videoIndex,
                // 全屏模式下点击播放下一集视频按钮
                playNextVideoFun: () {
                  setState(() {
                    videoIndex += 1;
                  });
                },
                settingFun: () {
                  print('设置按钮点击事件');
                },
                // 自定义倍速列表
                speedList: speedList,
                // 清晰度开关
                isResolution: true,
                // 自定义清晰度列表
                resolutionList: resolutionList,
                // 视频播放错误点击刷新回调
                onError: () async {
                  await player.reset();
                  setVideoUrl(videoList[videoIndex].url);
                },
                // 视频播放完成回调
                onVideoEnd: () async {
                  var index = videoIndex + 1;
                  if (index < videoList.length) {
                    await player.reset();
                    setState(() {
                      videoIndex = index;
                    });
                    setVideoUrl(videoList[index].url);
                  }
                },
                onVideoTimeChange: () {
                  // 视频时间变动则触发一次，可以保存视频播放历史
                },
                onVideoPrepared: () async {
                  // 视频初始化完毕，如有历史记录时间段则可以触发快进
                  try {
                    if (seekTime >= 1) {
                      /// seekTo必须在FState.prepared
                      print('seekTo');
                      await player.seekTo(seekTime);
                      // print("视频快进-$seekTime");
                      seekTime = 0;
                    }
                  } catch (error) {
                    print("视频初始化完快进-异常: $error");
                  }
                },
              ),
            ),
            // 自定义小屏列表
            Container(
              width: double.infinity,
              height: 30,
              margin: const EdgeInsets.all(20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  bool isCurrent = videoIndex == index;
                  Color textColor = Theme.of(context).primaryColor;
                  Color bgColor = Theme.of(context).primaryColorDark;
                  Color borderColor = Theme.of(context).primaryColor;
                  if (isCurrent) {
                    textColor = Theme.of(context).primaryColorDark;
                    bgColor = Theme.of(context).primaryColor;
                    borderColor = Theme.of(context).primaryColor;
                  }
                  return GestureDetector(
                    onTap: () async {
                      await player.reset();
                      setState(() {
                        videoIndex = index;
                      });
                      setVideoUrl(videoList[index].url);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: index == 0 ? 0 : 10),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: bgColor,
                        border: Border.all(
                          width: 1.5,
                          color: borderColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        videoList[index].title,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      print(e);
      throw 'Failed to reset brightness';
    }
    player.release();
  }
}
