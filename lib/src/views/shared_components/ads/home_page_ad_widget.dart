// import 'dart:math';
//
// import 'package:cluein_app/src/utils/screen_utils.dart';
// import 'package:cluein_app/src/views/shared_components/ads/bloc/ad_bloc.dart';
// import 'package:cluein_app/src/views/shared_components/ads/bloc/ad_event.dart';
// import 'package:cluein_app/src/views/shared_components/ads/bloc/ad_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:logging/logging.dart';
//
// class HomePageAdWidget extends StatefulWidget {
//   final double maxHeight;
//
//   const HomePageAdWidget({
//     super.key,
//     required this.maxHeight
//   });
//
//   @override
//   State createState() {
//     return HomePageAdWidgetState();
//   }
// }
//
// class HomePageAdWidgetState extends State<HomePageAdWidget> {
//
//   final logger = Logger("HomePageAdWidgetState");
//
//   late AdBloc _adBloc;
//   bool initialLoad = true;
//
//   BannerAd? _bannerAd;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _adBloc = BlocProvider.of<AdBloc>(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AdBloc, AdState>(
//       listener: (context, state) {
//         if (state is NewAdLoadRequested) {
//           setState(() {
//             _loadAd(state.adUnitId);
//           });
//         }
//         else if (state is AdUnitIdFetched) {
//           _adBloc.add(const FetchNewAd());
//         }
//       },
//       child: BlocBuilder<AdBloc, AdState>(
//         builder: (context, state) {
//           if (state is NewAdLoadRequested) {
//             if (initialLoad) {
//               _loadAd(state.adUnitId);
//               initialLoad = false;
//             }
//             return Container(
//               color: Colors.white,
//               child: _displayAd(),
//             );
//           }
//           else {
//             return const CircularProgressIndicator(
//               color: ConstantUtils.primaryAppColor,
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   _displayAd() {
//     if (_bannerAd != null) {
//       return Align(
//         alignment: Alignment.bottomCenter,
//         child: SafeArea(
//           child: SizedBox(
//             width: max(_bannerAd!.size.width.toDouble(), ScreenUtils.getScreenWidth(context)),
//             height: min(_bannerAd!.size.height.toDouble(), widget.maxHeight),
//             child: AdWidget(ad: _bannerAd!),
//           ),
//         ),
//       );
//     }
//     else {
//       return const Align(
//         alignment: Alignment.bottomCenter,
//         child: SafeArea(
//           child: Center(
//             child:  CircularProgressIndicator(
//               color: ConstantUtils.primaryAppColor,
//             ),
//           ),
//         ),
//       );
//     }
//   }
//
//   Future<void> _loadAd(String adUnitId) async {
//     // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
//     final AnchoredAdaptiveBannerAdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
//         MediaQuery.of(context).size.width.truncate()
//     );
//
//     if (size == null) {
//       logger.info('Unable to get height of anchored banner.');
//       return;
//     }
//
//     _bannerAd = BannerAd(
//       adUnitId: adUnitId,
//       size: size,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) {
//           logger.info('$ad loaded: ${ad.responseInfo}');
//           setState(() {
//             // When the ad is loaded, get the ad size and use it to set
//             // the height of the ad container.
//             _bannerAd = ad as BannerAd;
//           });
//         },
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           logger.info('Anchored adaptive banner failedToLoad: $error');
//           ad.dispose();
//         },
//       ),
//     );
//     return _bannerAd!.load();
//   }
//
// }