import 'package:flutter/material.dart';
import 'Screens/auth/LoginScreen.dart';

void main() => runApp(NitiMulyaApp());

class NitiMulyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'নীতি মূল্য',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.indigo,
      ),
      home: WelcomeScreen(),
      // Optional: Add named routes if you want to use them
      routes: {
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final List<Map<String, String>> data = List.generate(10, (index) => {
    'serial': '${index + 1}',
    'title': 'ঢাকা খুচরা বাজার দর',
    'time': '১২.৩০',
    'date': '২০২৫-০৭-${(12 - index).toString().padLeft(2, '০')}',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.withOpacity(0.8),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  "assets/image/logo.jpeg",
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'নীতি মূল্য',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Updated to navigate to the new LoginScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text("Login"),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://cdn.photoroom.com/v2/image-cache?path=gs://background-7ef44.appspot.com/backgrounds_v3/black/47_-_black.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
            child: Column(
              children: [
                SizedBox(height: 100),
                Text(
                  "প্রতিদিনের খুচরা বাজার দর",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length + 1,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text("ক্রমিক",
                                          style: TextStyle(
                                              color: Colors.white)))),
                              Expanded(
                                  flex: 3,
                                  child: Center(
                                      child: Text("শিরোনাম",
                                          style: TextStyle(
                                              color: Colors.white)))),
                              Expanded(
                                  flex: 2,
                                  child: Center(
                                      child: Text("সময়",
                                          style: TextStyle(
                                              color: Colors.white)))),
                              Expanded(
                                  flex: 2,
                                  child: Center(
                                      child: Text("তারিখ",
                                          style: TextStyle(
                                              color: Colors.white)))),
                              Expanded(
                                  flex: 2,
                                  child: Center(
                                      child: Text("ডাউনলোড",
                                          style: TextStyle(
                                              color: Colors.white)))),
                            ],
                          ),
                        );
                      }

                      final item = data[index - 1];
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        margin: EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(item['serial']!,
                                        style: TextStyle(color: Colors.white)))),
                            Expanded(
                                flex: 3,
                                child: Center(
                                    child: Text(item['title']!,
                                        style: TextStyle(color: Colors.white)))),
                            Expanded(
                                flex: 2,
                                child: Center(
                                    child: Text(item['time']!,
                                        style: TextStyle(color: Colors.white)))),
                            Expanded(
                                flex: 2,
                                child: Center(
                                    child: Text(item['date']!,
                                        style: TextStyle(color: Colors.white)))),
                            Expanded(
                                flex: 2,
                                child: Center(
                                    child: Icon(Icons.picture_as_pdf,
                                        color: Colors.redAccent))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.indigo, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("আরো দেখুন", style: TextStyle(color: Colors.indigo)),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}