import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const StockMindsetApp());
}

class StockMindsetApp extends StatelessWidget {
  const StockMindsetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockMindset SMC Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080B10),
        cardColor: const Color(0xFF121721),
        primaryColor: const Color(0xFF2962FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121721),
          elevation: 0,
        ),
      ),
      home: const MainTerminalScreen(),
    );
  }
}

class MainTerminalScreen extends StatefulWidget {
  const MainTerminalScreen({Key? key}) : super(key: key);

  @override
  State<MainTerminalScreen> createState() => _MainTerminalScreenState();
}

class _MainTerminalScreenState extends State<MainTerminalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ૧. માસ્ટર કંટ્રોલ અને બોટ ઓપરેશન
  bool masterBotOn = true;
  String selectedMarket = 'Crypto (CoinDCX / Binance)';
  String selectedBroker = 'CoinDCX Futures';
  bool isEmergencyKilled = false;

  // ૨. SMC Rule Manager કસ્ટમાઇઝેશન સ્વિચિસ
  bool obFilterOn = true;
  bool fvgFilterOn = true;
  double fvgEntryLevel = 50.0;
  String obTapFilter = '1-Tap (Fresh Unmitigated)';
  double wickPercentage = 35.0;
  bool liquiditySweepOn = true;

  // ૩. લાઈવ ચાર્ટ અને વિઝ્યુઅલ કંટ્રોલ્સ
  String selectedCoin = 'BTCUSDT';
  String selectedTimeframe = '15m';
  bool autoDrawOn = true;
  bool cvdHeatmapOn = false;
  bool isReplayPlaying = false;
  int replaySpeed = 1;

  // ૪. એક્ઝિક્યુશન અને રિસ્ક મેનેજમેન્ટ
  bool manualApprovalMode = false;
  bool ghostSLOn = true;
  double riskPerTradePercent = 1.0;
  bool breakEvenLocked = false;

  // ૫. ડિસિપ્લિન અને પ્રોપ ફર્મ ગાર્ડ
  bool revengeTradingLock = true;
  bool weekendProfitLock = true;
  bool propFirmMode = true;

  // ૬. ઓટોમેશન અને એલર્ટ્સ
  bool voiceAlertsOn = true;
  bool floatingBubbleOn = false;
  bool multiAccountCopyOn = false;

  double livePrice = 80381.73;
  double liveChange = 2.4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'StockMindset Institutional Platform',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Founder: ANKIT RABARI (Rajkot) • 7697667767',
              style: TextStyle(fontSize: 10, color: Color(0xFF58A6FF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(voiceAlertsOn ? Icons.volume_up : Icons.volume_off, color: const Color(0xFF58A6FF)),
            onPressed: () {
              setState(() { voiceAlertsOn = !voiceAlertsOn; });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(voiceAlertsOn ? 'વોઇસ એલર્ટ્સ સક્રિય!' : 'વોઇસ મ્યુટ કર્યું!'),
                duration: const Duration(seconds: 1),
              ));
            },
          ),
          Switch(
            value: masterBotOn,
            activeColor: const Color(0xFF00C087),
            onChanged: (val) {
              setState(() { masterBotOn = val; });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(val ? 'માસ્ટર બોટ સ્કેનિંગ શરૂ!' : 'માસ્ટર બોટ થોભાવ્યો!'),
                duration: const Duration(seconds: 1),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.dangerous, color: Color(0xFFFF3B53)),
            tooltip: 'Emergency Kill Switch (Square-off All)',
            onPressed: _showEmergencyKillDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF2962FF),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF8A99AD),
          tabs: const [
            Tab(icon: Icon(Icons.candlestick_chart), text: 'લાઇવ ચાર્ટ'),
            Tab(icon: Icon(Icons.rule), text: 'SMC Rules'),
            Tab(icon: Icon(Icons.security), text: 'રિસ્ક & એક્ઝિક્યુશન'),
            Tab(icon: Icon(Icons.shield), text: 'ડિસિપ્લિન ગાર્ડ'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'P&L જર્નલ'),
            Tab(icon: Icon(Icons.settings), text: 'કંટ્રોલ પેનલ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveChartTab(),
          _buildSmcRuleManagerTab(),
          _buildRiskExecutionTab(),
          _buildDisciplineGuardTab(),
          _buildPnlJournalTab(),
          _buildControlPanelTab(),
        ],
      ),
    );
  }

  void _showEmergencyKillDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2C),
        title: const Text('🚨 EMERGENCY KILL SWITCH 🚨', style: TextStyle(color: Color(0xFFFF3B53))),
        content: const Text(
          'શું તમે તમામ ઓપન પોઝિશન્સ માત્ર ૦.૧ સેકન્ડમાં એકસાથે બંધ (Square-Off) કરવા માંગો છો?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('રદ કરો')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B53)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { isEmergencyKilled = true; });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('⚡ તમામ પોઝિશન્સ તાત્કાલિક સ્ક્વેર-ઓફ થઈ ગઈ!'),
                backgroundColor: Color(0xFFFF3B53),
              ));
            },
            child: const Text('કન્ફર્મ કરો'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveChartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF161D2B), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMarket,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      dropdownColor: const Color(0xFF161D2B),
                      items: const [
                        DropdownMenuItem(value: 'Crypto (CoinDCX / Binance)', child: Text('🪙 Crypto (CoinDCX/Binance)')),
                        DropdownMenuItem(value: 'Indian Market (Nifty/Bank Nifty)', child: Text('🇮🇳 Indian Market (Nifty/BankNifty)')),
                        DropdownMenuItem(value: 'US Market (NASDAQ/S&P)', child: Text('🇺🇸 US Market (NASDAQ/S&P 500)')),
                        DropdownMenuItem(value: 'Forex (Gold/EURUSD)', child: Text('🌍 Forex (Gold/EURUSD)')),
                      ],
                      onChanged: (val) { if (val != null) setState(() { selectedMarket = val; }); },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF005A3E), borderRadius: BorderRadius.circular(8)),
                child: const Text('API: SYNCED ●', style: TextStyle(color: Color(0xFF00C087), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: ['BTC', 'ETH', 'SOL', 'NEAR'].map((c) {
                  bool act = selectedCoin.startsWith(c);
                  return GestureDetector(
                    onTap: () { setState(() { selectedCoin = '${c}USDT'; }); },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: act ? const Color(0xFF00C087) : const Color(0xFF161D2B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(c, style: TextStyle(color: act ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
              Row(
                children: ['1m', '5m', '15m', '1H', '4H'].map((tf) {
                  bool act = selectedTimeframe == tf;
                  return GestureDetector(
                    onTap: () { setState(() { selectedTimeframe = tf; }); },
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: act ? const Color(0xFF2962FF) : const Color(0xFF161D2B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tf, style: TextStyle(color: act ? Colors.white : const Color(0xFF8A99AD), fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF121721), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF252D3D))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedCoin, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('SMC 146 Slides Engine: Order Block + FVG 50% CE', style: TextStyle(fontSize: 10, color: Color(0xFF8A99AD))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$$livePrice', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C087))),
                    Text('+$liveChange% (Live Ticks)', style: const TextStyle(fontSize: 10, color: Color(0xFF00C087))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 260,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF10141D), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF252D3D))),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.candlestick_chart, size: 48, color: Color(0xFF00C087)),
                      const SizedBox(height: 8),
                      Text('Live Moving Chart ($selectedCoin • $selectedTimeframe)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const Text('Auto-Scale + WebSocket Active', style: TextStyle(fontSize: 10, color: Color(0xFF58A6FF))),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0x332962FF), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF2962FF))),
                        child: const Text('🟦 OB: \$80,150', style: TextStyle(color: Color(0xFF58A6FF), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0x33AB47BC), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFAB47BC))),
                        child: const Text('🟪 FVG 50%: \$80,650', style: TextStyle(color: Color(0xFFD2A8FF), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF121721), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Historical Bar-Replay:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isReplayPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFF00C087)),
                      onPressed: () { setState(() { isReplayPlaying = !isReplayPlaying; }); },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Color(0xFF58A6FF)),
                      onPressed: () {},
                    ),
                    DropdownButton<int>(
                      value: replaySpeed,
                      dropdownColor: const Color(0xFF161D2B),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1x', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 2, child: Text('2x', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 5, child: Text('5x', style: TextStyle(fontSize: 11))),
                      ],
                      onChanged: (v) { if (v != null) setState(() { replaySpeed = v; }); },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmcRuleManagerTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('⚙️ SMC Rule Manager (કસ્ટમાઇઝેશન સ્વિચિસ)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF))),
        const Text('કોઈપણ કોડિંગ વગર સીધા એપમાંથી નિયમો બદલવા માટે:', style: TextStyle(fontSize: 11, color: Color(0xFF8A99AD))),
        const SizedBox(height: 12),
        _buildSwitchTile('Order Block (OB) સ્કેનિંગ', 'સ્લાઇડ ૨૮ & ૪૦ ઓર્ડર બ્લોક આધારિત એન્ટ્રી ચાલુ/બંધ', obFilterOn, (v) => setState(() => obFilterOn = v)),
        _buildSwitchTile('Fair Value Gap (FVG) સ્કેનિંગ', 'સ્લાઇડ ૪૮ FVG ઇમ્બેલેન્સ ઝોન ફિલ્ટર', fvgFilterOn, (v) => setState(() => fvgFilterOn = v)),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: const Color(0xFF121721), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FVG Entry Level Selector: ${fvgEntryLevel.toStringAsFixed(0)}% (CE)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Slider(
                value: fvgEntryLevel,
                min: 0,
                max: 100,
                divisions: 2,
                activeColor: const Color(0xFFAB47BC),
                label: '${fvgEntryLevel.toStringAsFixed(0)}%',
                onChanged: (v) => setState(() => fvgEntryLevel = v),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0% (Open)', style: TextStyle(fontSize: 10, color: Color(0xFF8A99AD))),
                  Text('50% (Consequent Encroachment)', style: TextStyle(fontSize: 10, color: Color(0xFFAB47BC), fontWeight: FontWeight.bold)),
                  Text('100% (Full Fill)', style: TextStyle(fontSize: 10, color: Color(0xFF8A99AD))),
                ],
              ),
            ],
          ),
        ),
        _buildSwitchTile('Liquidity Sweep Filter (સ્લાઇડ ૫૯ & ૧૦૦)', 'Equal Highs / Equal Lows સ્વીપ થયા બાદ જ સિગ્નલ આપશે', liquiditySweepOn, (v) => setState(() => liquiditySweepOn = v)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C087), padding: const EdgeInsets.all(12)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('✔ તમામ SMC નિયમો સેવ થઈ ગયા! બોટ રિસ્ટાર્ટ વગર લાઈવ લાગુ.'),
              backgroundColor: Color(0xFF00C087),
            ));
          },
          child: const Text('Save Rule Changes (સેવ કરો)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildRiskExecutionTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('🛡️ રિસ્ક & ટ્રેડ એક્ઝિક્યુશન', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF))),
        const SizedBox(height: 12),
        _buildSwitchTile('Manual Approval Mode (સેમી-ઓટો)', 'સિગ્નલ આવે ત્યારે તમારી મંજૂરી (Confirm) પછી જ ઓર્ડર પડે', manualApprovalMode, (v) => setState(() => manualApprovalMode = v)),
        _buildSwitchTile('Ghost / Stealth SL Mode', 'સ્ટોપલોસ બ્રોકરની ઓર્ડર બુકમાં ન મોકલતાં એપમાં છુપાવીને રાખશે', ghostSLOn, (v) => setState(() => ghostSLOn = v)),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: const Color(0xFF121721), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Risk Per Trade: $riskPerTradePercent% Capital', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Row(
                children: [0.5, 1.0, 2.0].map((r) {
                  bool act = riskPerTradePercent == r;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: act ? const Color(0xFF2962FF) : const Color(0xFF161D2B)),
                        onPressed: () => setState(() => riskPerTradePercent = r),
                        child: Text('$r%', style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2962FF), padding: const EdgeInsets.all(12)),
          onPressed: () {
            setState(() { breakEvenLocked = true; });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚡ Break-Even Locked! Stop-loss એન્ટ્રી ભાવ પર શિફ્ટ થઈ ગયો.')));
          },
          child: const Text('Break-Even Lock (Zero Risk)', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDisciplineGuardTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('🧠 ડિસિપ્લિન, સાયકોલોજી & પ્રોપ ફર્મ ગાર્ડ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF))),
        const SizedBox(height: 12),
        _buildSwitchTile('Revenge Trading Lock', 'સતત ૨ સ્ટોપલોસ હિટ થાય તો એપ ૧ કલાક માટે લૉક થઈ જશે', revengeTradingLock, (v) => setState(() => revengeTradingLock = v)),
        _buildSwitchTile('Weekend / Profit Target Lock', 'અઠવાડિયાનો ટાર્ગેટ પૂરો થતાં જ બાકીના દિવસો માટે નવો ટ્રેડ બ્લોક', weekendProfitLock, (v) => setState(() => weekendProfitLock = v)),
        _buildSwitchTile('Prop Firm Mode (FTMO/MFF Guard)', 'દૈનિક ૪% મેક્સ ડ્રોડાઉન પહોંચતાં જ ટ્રેડિંગ આપમેળે ફ્રીઝ', propFirmMode, (v) => setState(() => propFirmMode = v)),
      ],
    );
  }

  Widget _buildPnlJournalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF121721), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('નેટ ઉપલબ્ધ મૂડી (Available)', style: TextStyle(fontSize: 11, color: Color(0xFF8A99AD))),
                    Text('આજનો નેટ નફો (Net P&L)', style: TextStyle(fontSize: 11, color: Color(0xFF8A99AD))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('\$10,428.50', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('+\$428.50 (+4.28%)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C087))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C087), minimumSize: const Size.fromHeight(45)),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
            label: const Text('Export Daily PDF Journal (ડાઉનલોડ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📄 દૈનિક PDF જર્નલ રિપોર્ટ જનરેટ થઈ ગયો!')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanelTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('⚙️ ઓટોમેશન & કંટ્રોલ સેટિંગ્સ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF))),
        const SizedBox(height: 12),
        _buildSwitchTile('Floating Bubble Mode (Android)', 'બીજી એપ વાપરતી વખતે સ્ક્રીન પર લાઈવ P&L બબલ ઓન રાખવા', floatingBubbleOn, (v) => setState(() => floatingBubbleOn = v)),
        _buildSwitchTile('Multi-Account Copy Trading', 'માસ્ટર એકાઉન્ટમાંથી બીજા તમામ કનેક્ટેડ એકાઉન્ટમાં ટ્રેડ કોપી કરવા', multiAccountCopyOn, (v) => setState(() => multiAccountCopyOn = v)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool val, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF121721), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF8A99AD))),
              ],
            ),
          ),
          Switch(
            value: val,
            activeColor: const Color(0xFF00C087),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
