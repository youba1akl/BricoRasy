import 'package:flutter/material.dart';

class first_screen_containers extends StatefulWidget {
  const first_screen_containers({super.key});

  @override
  State<first_screen_containers> createState() => _first_screen_containersState();
}

class _first_screen_containersState extends State<first_screen_containers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        
        gradient:  LinearGradient(
          colors: [Color(0xFF145FD6), Color(0xFF1E81CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
       boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 1, blue: 0.5),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/Iconos gratuitos de Lenguaje De Codificación diseñados por Flat Icons.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
         
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // pour le titre
                Text(
                  "Titre",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                // pour la description
                Text(
                  "fjdkdlfjkfd jkfjdkjfdkjfdk fdkdfjkdf",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 4),
                // Localisation
                Text(
                  "Location: bejaia",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Navigation Button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: const Color.fromARGB(255, 129, 126, 126),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(0, 0),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_sharp,
              size: 16,
              color: Color.fromARGB(255, 238, 239, 240),
            ),
          ),
        ],
      ),
    );
  }
}





