import 'package:flutter/material.dart';

class AddAnnoScreen extends StatefulWidget {
  const AddAnnoScreen({super.key});

  @override
  State<AddAnnoScreen> createState() => _AddAnnoScreenState();
}

class _AddAnnoScreenState extends State<AddAnnoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
               backgroundColor: const Color.fromARGB(201, 118, 117, 117), 

        centerTitle: true,
        title: Text(
          
          "Add Annonce",
          style: TextStyle(
            
            color: Color.fromARGB(255, 16, 25, 62),
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(201, 118, 117, 117),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Container(
             color: Color(0xFFF5F5F5), 
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            const AssetImage('assets/images/logo-google.png'),
                            size: 80,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Briclole",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 6, 50, 226),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            const AssetImage('assets/images/logo-google.png'),
                            size: 80,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Professionnel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 6, 50, 226),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            const AssetImage('assets/images/logo-google.png'),
                            size: 80,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Article",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 6, 50, 226),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
