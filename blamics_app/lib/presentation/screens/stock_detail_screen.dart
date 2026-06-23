import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_colors.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Append NSE: prefix based on user request
    final tradingViewSymbol = 'NSE:${widget.symbol}';

    final htmlString = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,minimum-scale=1.0,user-scalable=no">
        <style>
          body { margin: 0; padding: 0; background-color: #0A0E17; height: 100vh; overflow: hidden; }
          .tradingview-widget-container { height: 100%; width: 100%; }
        </style>
      </head>
      <body>
        <div class="tradingview-widget-container">
          <div id="tradingview_123" style="height:100%;width:100%"></div>
          <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
          <script type="text/javascript">
          new TradingView.widget(
          {
          "autosize": true,
          "symbol": "$tradingViewSymbol",
          "interval": "D",
          "timezone": "Etc/UTC",
          "theme": "dark",
          "style": "1",
          "locale": "en",
          "enable_publishing": false,
          "backgroundColor": "#0A0E17",
          "gridColor": "#1E293B",
          "hide_top_toolbar": false,
          "hide_legend": false,
          "save_image": false,
          "container_id": "tradingview_123"
        }
          );
          </script>
        </div>
      </body>
      </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..loadHtmlString(htmlString, baseUrl: 'https://in.tradingview.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
